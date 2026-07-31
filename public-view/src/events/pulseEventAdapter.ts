import { PulseEvent } from '../types';

export function parseRawEvent(raw: any): PulseEvent | null {
  if (!raw || !raw.event) return null;
  const ts = Date.now();
  const eventName = raw.event.toUpperCase();
  
  switch (eventName) {
    case 'ASK_CREATED': {
      return { 
        id: raw.data.ask_id + '_created',
        type: 'ask_created', 
        askId: raw.data.ask_id, 
        fromUserId: raw.data.requester_name || raw.data.requester_id || 'Anonymous', 
        message: raw.data.description || 'New ask',
        ts 
      };
    }
    case 'REPLY_ADDED': {
      return { 
        id: raw.data.reply_id + '_replied',
        type: 'ask_replied', 
        askId: raw.data.ask_id, 
        fromUserId: raw.data.replier_name || raw.data.replier_id || 'Someone', 
        ts 
      };
    }
    case 'ASK_RESOLVED': {
      return { 
        id: raw.data.ask_id + '_resolved',
        type: 'ask_matched', 
        askId: raw.data.ask_id, 
        helperId: raw.data.helper_name || raw.data.helper_id || 'Someone', 
        ts 
      };
    }
    default:
      return null;
  }
}
