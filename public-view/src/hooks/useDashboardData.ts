import { useState, useEffect, useCallback, useMemo } from 'react';
import axios from 'axios';
import { PulseEvent, UserStatus, DashboardMetrics, SystemHealth } from '../types';
import { useWebSocket } from './useWebSocket';
import { MockSimulator, getMockMetrics, getMockHealth, getMockUsers } from '../simulate/mockGenerator';
import { API_BASE_URL } from '../config';

export function useDashboardData(isSimulationEnabled: boolean) {
  const [events, setEvents] = useState<PulseEvent[]>([]);
  const [openAsks, setOpenAsks] = useState<any[]>([]);
  const [users, setUsers] = useState<UserStatus[]>([]);
  const [metrics, setMetrics] = useState<DashboardMetrics>({
    registeredUsers: 0, onlineUsers: 0, openAsks: 0, resolvedAsks: 0, repliesToday: 0, avgResponseTimeMs: 0
  });
  const [health, setHealth] = useState<SystemHealth>({
    backend: 'connecting', mongo: 'connecting', websocket: 'connecting', latency: 0
  });
  
  const [simulator, setSimulator] = useState<MockSimulator | null>(null);

  const handleEvent = useCallback((event: PulseEvent) => {
    setEvents(prev => [event, ...prev].slice(0, 100)); // Keep last 100 events

    // Update metrics and user status based on events
    if (event.type === 'ask_created') {
      setMetrics(m => ({ ...m, openAsks: m.openAsks + 1 }));
      setUsers(u => u.map(user => user.id === event.fromUserId ? { ...user, state: 'waiting' } : user));
    } else if (event.type === 'ask_replied') {
      setMetrics(m => ({ ...m, repliesToday: m.repliesToday + 1 }));
      setUsers(u => u.map(user => user.id === event.fromUserId ? { ...user, state: 'helping' } : user));
    } else if (event.type === 'ask_matched') {
      setMetrics(m => ({ ...m, openAsks: Math.max(0, m.openAsks - 1), resolvedAsks: m.resolvedAsks + 1 }));
    }
  }, []);

  const { status: wsStatus } = useWebSocket(isSimulationEnabled, handleEvent);

  useEffect(() => {
    if (isSimulationEnabled) {
      setUsers(getMockUsers());
      setMetrics(getMockMetrics());
      setHealth(getMockHealth());
      
      const sim = new MockSimulator(handleEvent);
      sim.start();
      setSimulator(sim);
      
      return () => {
        sim.stop();
      };
    } else {
      if (simulator) {
        simulator.stop();
        setSimulator(null);
      }
    }
  }, [isSimulationEnabled, handleEvent]); // Notice no 'simulator' or 'users.length'

  useEffect(() => {
    if (isSimulationEnabled) return;
      
      setHealth(h => ({ ...h, websocket: wsStatus }));
      
      // Fetch live data including events every 1 second
      const fetchLive = async () => {
        try {
          // If endpoints exist on backend, they would be called here.
          // Fallback to empty/placeholder if not available on backend for public view.
          const res = await axios.get(`${API_BASE_URL}/api/v1/public/stats`, {
            headers: { 'ngrok-skip-browser-warning': 'true' }
          }).catch(() => null);
          if (res && res.data) {
            setMetrics({
              registeredUsers: res.data.total_users || 0,
              onlineUsers: res.data.online_users || 0,
              openAsks: res.data.open_asks || 0,
              resolvedAsks: res.data.resolved_asks || 0,
              repliesToday: res.data.total_events || 0,
              avgResponseTimeMs: parseInt(res.data.average_response_time) || 0
            });
          }
          
          const healthRes = await axios.get(`${API_BASE_URL}/api/v1/public/health`, {
            headers: { 'ngrok-skip-browser-warning': 'true' }
          }).catch((err) => {
            console.error("Health check failed:", err);
            setHealth(h => ({ 
              ...h, 
              backend: 'error', 
              mongo: 'error', 
              errorMsg: err.message || "Network Error: Could not reach backend API"
            }));
            return null;
          });
          
          if (healthRes && healthRes.data) {
            setHealth({
              backend: healthRes.data.api_status === 'operational' ? 'connected' : 'error',
              mongo: healthRes.data.db_status === 'operational' ? 'connected' : 'error',
              websocket: wsStatus,
              latency: parseInt(healthRes.data.api_latency) || 0,
              errorMsg: undefined
            });
          }
          
          const usersRes = await axios.get(`${API_BASE_URL}/api/v1/public/users`, {
            headers: { 'ngrok-skip-browser-warning': 'true' }
          }).catch(() => null);
          if (usersRes && Array.isArray(usersRes.data)) {
            setUsers(usersRes.data);
          }
          
          const eventsRes = await axios.get(`${API_BASE_URL}/api/v1/public/events`, {
            headers: { 'ngrok-skip-browser-warning': 'true' }
          }).catch(() => null);
          if (eventsRes && Array.isArray(eventsRes.data)) {
            setEvents(prev => {
              if (prev.length > 0) {
                const existingIds = new Set(prev.map(e => e.id));
                const newEvents = eventsRes.data.filter((e: any) => !existingIds.has(e.id));
                if (newEvents.length === 0) return prev;
                return [...prev, ...newEvents].sort((a, b) => b.ts - a.ts).slice(0, 100);
              }
              return eventsRes.data.slice(0, 100);
            });
          }
          
          const feedRes = await axios.get(`${API_BASE_URL}/api/v1/public/feed`, {
            headers: { 'ngrok-skip-browser-warning': 'true' }
          }).catch(() => null);
          if (feedRes && Array.isArray(feedRes.data)) {
            setOpenAsks(feedRes.data);
          }
        } catch (e) {
          console.error(e);
        }
      };
      
      fetchLive();
      const interval = setInterval(fetchLive, 1000);
      return () => clearInterval(interval);
  }, [isSimulationEnabled, wsStatus]);

  // Compute Active Clusters dynamically from actual open asks and events
  const activeClusters = useMemo(() => {
    const asks = new Map<string, { asker: string; replies: string[]; resolvedHelper?: string; timestamp: number }>();
    
    // First, populate clusters with ALL open asks directly from the database feed
    if (!isSimulationEnabled) {
      openAsks.forEach(ask => {
        asks.set(ask.id, { 
          asker: ask.requester_id, 
          replies: [], 
          timestamp: new Date(ask.created_at).getTime() 
        });
      });
    }
    
    // Then process events chronologically (reverse the reverse) to add repliers and handle state
    [...events].reverse().forEach(e => {
      if (e.type === 'ask_created' && e.askId) {
        if (!asks.has(e.askId)) {
           asks.set(e.askId, { asker: e.fromUserId || 'Unknown', replies: [], timestamp: e.ts });
        }
      } else if (e.type === 'ask_replied' && e.askId) {
        const ask = asks.get(e.askId);
        if (ask && e.fromUserId && !ask.replies.includes(e.fromUserId)) {
          ask.replies.push(e.fromUserId);
        }
      } else if (e.type === 'ask_matched' && e.askId) {
        const ask = asks.get(e.askId);
        if (ask) {
          ask.resolvedHelper = e.helperId;
          ask.timestamp = e.ts; // update timestamp for expiration
        }
      } else if (e.type === 'ask_expired' && e.askId) {
        asks.delete(e.askId);
      }
    });

    const now = Date.now();
    for (const [askId, ask] of asks.entries()) {
      if (ask.resolvedHelper && (now - ask.timestamp) > 5000) {
        // Remove resolved asks after 5 seconds to simulate shrinking and disappearing
        asks.delete(askId);
      }
    }

    return asks;
  }, [events, openAsks, isSimulationEnabled]);

  return { events, users, metrics, health, activeClusters };
}
