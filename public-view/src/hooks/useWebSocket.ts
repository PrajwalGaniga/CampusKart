import { useEffect, useRef, useState, useCallback } from 'react';
import { WS_BASE_URL } from '../config';
import { PulseEvent } from '../types';
import { parseRawEvent } from '../events/pulseEventAdapter';

export function useWebSocket(
  isSimulationEnabled: boolean,
  onEvent: (event: PulseEvent) => void
) {
  const wsRef = useRef<WebSocket | null>(null);
  const [status, setStatus] = useState<'connected' | 'connecting' | 'error'>('connecting');

  const connect = useCallback(() => {
    if (isSimulationEnabled) {
      setStatus('connected'); // Simulator handles events locally
      return;
    }

    setStatus('connecting');
    try {
      const ws = new WebSocket(`${WS_BASE_URL}/ws/public`);
      wsRef.current = ws;

      ws.onopen = () => {
        setStatus('connected');
      };

      ws.onmessage = (event) => {
        try {
          const raw = JSON.parse(event.data);
          const parsedEvent = parseRawEvent(raw);
          if (parsedEvent) {
            onEvent(parsedEvent);
          } else if (raw.event === 'connected') {
            onEvent({
              id: `sys_${Date.now()}`,
              type: 'system_message',
              message: raw.data.message || 'Connected to live relay',
              ts: Date.now()
            });
          }
        } catch (err) {
          console.error("Error parsing WS message", err);
        }
      };

      ws.onclose = () => {
        setStatus('error');
        // Reconnect after 3 seconds
        setTimeout(() => connect(), 3000);
      };

      ws.onerror = () => {
        setStatus('error');
      };
    } catch (err) {
      console.error(err);
      setStatus('error');
    }
  }, [isSimulationEnabled, onEvent]);

  useEffect(() => {
    connect();
    return () => {
      if (wsRef.current) {
        wsRef.current.close();
      }
    };
  }, [connect]);

  return { status };
}
