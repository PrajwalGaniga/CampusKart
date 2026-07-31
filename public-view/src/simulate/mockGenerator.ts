import { PulseEvent, UserStatus, DashboardMetrics, SystemHealth } from '../types';

const MOCK_USERS = [
  { id: 'u1', name: 'Prajwal G', username: 'prajwal', isOnline: true },
  { id: 'u2', name: 'Amrita R', username: 'amrita', isOnline: true },
  { id: 'u3', name: 'Pavithra S', username: 'pavithra', isOnline: true },
  { id: 'u4', name: 'Kiran M', username: 'kiran', isOnline: false },
  { id: 'u5', name: 'Arjun K', username: 'arjun', isOnline: true },
  { id: 'u6', name: 'Sneha L', username: 'sneha', isOnline: true },
  { id: 'u7', name: 'Vikram D', username: 'vikram', isOnline: false },
  { id: 'u8', name: 'Anjali P', username: 'anjali', isOnline: true },
  { id: 'u9', name: 'Rahul V', username: 'rahul', isOnline: true },
  { id: 'u10', name: 'Neha B', username: 'neha', isOnline: false }
];

export const getMockUsers = (): UserStatus[] => {
  const avatars = [
    '/avatars/1.jpg',
    '/avatars/2.jpg',
    '/avatars/3.jpg',
    '/avatars/4.jpg',
    '/avatars/5.jpg',
    '/avatars/6.jpg',
    '/avatars/7.jpg'
  ];
  
  return Array.from({ length: 25 }, (_, i) => ({
    id: `u${i + 1}`,
    name: `User ${i + 1}`,
    username: `user${i + 1}`,
    avatar: avatars[Math.floor(Math.random() * avatars.length)],
    isOnline: Math.random() > 0.2,
    state: 'idle',
    friendsCount: Math.floor(Math.random() * 50)
  }));
};

export function getMockMetrics(): DashboardMetrics {
  return {
    registeredUsers: 142,
    onlineUsers: 48,
    openAsks: 3,
    resolvedAsks: 12,
    repliesToday: 34,
    avgResponseTimeMs: 42000
  };
}

export function getMockHealth(): SystemHealth {
  return {
    backend: 'connected',
    mongo: 'connected',
    websocket: 'connected',
    latency: Math.floor(Math.random() * 40) + 15
  };
}

// Emits events randomly to simulate a live system
export class MockSimulator {
  private timer: any = null;
  private onEvent: (event: PulseEvent) => void;
  private users: UserStatus[];
  private activeAsks: Map<string, { asker: string, repliers: string[] }> = new Map();

  constructor(onEvent: (event: PulseEvent) => void) {
    this.onEvent = onEvent;
    this.users = getMockUsers();
  }

  start() {
    this.timer = setInterval(() => this.tick(), 3500);
  }

  stop() {
    if (this.timer) {
      clearInterval(this.timer);
      this.timer = null;
    }
  }

  private tick() {
    const rand = Math.random();
    const now = Date.now();
    
    // Clean up expired asks (simulated 30 seconds)
    
    if (this.activeAsks.size > 0 && rand < 0.4) {
      // Pick a random ask
      const askIds = Array.from(this.activeAsks.keys());
      const askId = askIds[Math.floor(Math.random() * askIds.length)];
      const askData = this.activeAsks.get(askId)!;
      
      if (askData.repliers.length > 0 && rand < 0.15) {
        // Resolve it
        const helper = askData.repliers[Math.floor(Math.random() * askData.repliers.length)];
        this.onEvent({
          id: `evt_${now}`,
          type: 'ask_matched',
          askId,
          helperId: helper,
          ts: now
        });
        this.activeAsks.delete(askId);
      } else if (askData.repliers.length < 4) {
        // Add a reply
        const available = this.users.filter(u => u.isOnline && u.id !== askData.asker && !askData.repliers.includes(u.id));
        if (available.length > 0) {
          const replier = available[Math.floor(Math.random() * available.length)].id;
          askData.repliers.push(replier);
          this.onEvent({
            id: `evt_${now}`,
            type: 'ask_replied',
            askId,
            fromUserId: replier,
            ts: now
          });
        }
      }
    } else if (this.activeAsks.size < 4 && rand < 0.7) {
      // Create new ask
      const online = this.users.filter(u => u.isOnline);
      const asker = online[Math.floor(Math.random() * online.length)];
      const askId = `ask_${now}`;
      this.activeAsks.set(askId, { asker: asker.id, repliers: [] });
      
      this.onEvent({
        id: `evt_${now}`,
        type: 'ask_created',
        askId,
        fromUserId: asker.id,
        message: 'Need help with assignment',
        ts: now
      });
    }
  }
}
