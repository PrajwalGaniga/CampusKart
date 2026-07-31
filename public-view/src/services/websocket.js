import { WS_BASE_URL } from '../config';

class WebSocketService {
  constructor() {
    this.ws = null;
    this.reconnectTimer = null;
    this.onMessageCallback = null;
    this.onStatusChangeCallback = null;
  }

  connect() {
    if (this.ws) {
      this.ws.close();
    }

    this.ws = new WebSocket(`${WS_BASE_URL}/ws/public`);

    this.ws.onopen = () => {
      console.log('WebSocket Connected');
      if (this.onStatusChangeCallback) this.onStatusChangeCallback(true);
      if (this.reconnectTimer) clearTimeout(this.reconnectTimer);
    };

    this.ws.onmessage = (event) => {
      try {
        const data = JSON.parse(event.data);
        if (data.event === 'ping') {
          this.ws.send(JSON.stringify({ event: 'pong' }));
        } else if (this.onMessageCallback) {
          this.onMessageCallback(data);
        }
      } catch (err) {
        console.error('Error parsing WS message', err);
      }
    };

    this.ws.onclose = () => {
      console.log('WebSocket Disconnected');
      if (this.onStatusChangeCallback) this.onStatusChangeCallback(false);
      this.reconnect();
    };

    this.ws.onerror = (err) => {
      console.error('WebSocket Error', err);
      if (this.ws) this.ws.close();
    };
  }

  reconnect() {
    this.reconnectTimer = setTimeout(() => {
      console.log('Attempting to reconnect...');
      this.connect();
    }, 3000);
  }

  onMessage(callback) {
    this.onMessageCallback = callback;
  }

  onStatusChange(callback) {
    this.onStatusChangeCallback = callback;
  }
}

export const wsService = new WebSocketService();
