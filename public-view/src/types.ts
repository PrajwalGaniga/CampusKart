export type PulseEventType = 
  | 'ask_created' 
  | 'ask_replied' 
  | 'ask_matched' 
  | 'ask_expired' 
  | 'system_message';

export interface PulseEvent {
  id: string; // unique event id for rendering in timeline
  type: PulseEventType;
  askId?: string;
  fromUserId?: string;
  helperId?: string;
  message?: string;
  ts: number;
}

export interface UserStatus {
  id: string;
  name: string;
  username: string;
  avatar?: string;
  isOnline: boolean;
  state: 'idle' | 'helping' | 'waiting' | 'resolved';
  friendsCount: number;
}

export interface DashboardMetrics {
  registeredUsers: number;
  onlineUsers: number;
  openAsks: number;
  resolvedAsks: number;
  repliesToday: number;
  avgResponseTimeMs: number;
}

export interface SystemHealth {
  backend: 'connected' | 'connecting' | 'error';
  mongo: 'connected' | 'connecting' | 'error';
  websocket: 'connected' | 'connecting' | 'error';
  latency: number;
  errorMsg?: string;
}
