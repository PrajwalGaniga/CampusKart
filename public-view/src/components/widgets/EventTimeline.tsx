import React from 'react';
import { PulseEvent } from '../../types';
import { MessageCircle, CheckCircle2, HandHeart } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import styles from '../../pages/Dashboard.module.css';

interface EventTimelineProps {
  events: PulseEvent[];
}

export default function EventTimeline({ events }: EventTimelineProps) {
  const getEventIcon = (type: string) => {
    switch (type) {
      case 'ask_created': return <MessageCircle size={16} />;
      case 'ask_replied': return <HandHeart size={16} />;
      case 'ask_matched': return <CheckCircle2 size={16} />;
      default: return <MessageCircle size={16} />;
    }
  };

  const getEventIconClass = (type: string) => {
    switch (type) {
      case 'ask_created': return styles.timelineIconCreated;
      case 'ask_replied': return styles.timelineIconReplied;
      case 'ask_matched': return styles.timelineIconMatched;
      default: return styles.timelineIconCreated;
    }
  };

  const getEventTitle = (event: PulseEvent) => {
    if (event.type === 'ask_created') return 'New Ask';
    if (event.type === 'ask_replied') return 'Reply Offered';
    if (event.type === 'ask_matched') return 'Match Made';
    if (event.type === 'ask_expired') return 'Ask Expired';
    return event.type;
  };

  return (
    <div className={styles.card} style={{ flex: 1, minWidth: '300px' }}>
      <h2 className={styles.cardTitle}>Event Timeline</h2>
      <div className={styles.timelineContainer}>
        <AnimatePresence initial={false}>
          {events.map((event, i) => (
            <motion.div
              key={`${event.ts}-${i}`}
              initial={{ opacity: 0, y: -20, scale: 0.95 }}
              animate={{ opacity: 1, y: 0, scale: 1 }}
              transition={{ duration: 0.3 }}
              className={styles.timelineEvent}
            >
              <div className={`${styles.timelineIcon} ${getEventIconClass(event.type)}`}>
                {getEventIcon(event.type)}
              </div>
              <div className={styles.timelineContent}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
                  <div className={styles.timelineTitle}>{getEventTitle(event)}</div>
                  <div className={styles.timelineTime}>
                    {new Date(event.ts).toLocaleTimeString()}
                  </div>
                </div>
                <div className={styles.timelineDesc}>
                  {event.type.split('_').map(w => w.charAt(0).toUpperCase() + w.slice(1)).join(' ')} - User {event.fromUserId || 'System'}
                </div>
              </div>
            </motion.div>
          ))}
        </AnimatePresence>
        
        {events.length === 0 && (
          <div style={{ padding: '2rem', textAlign: 'center', color: '#6B7280' }}>
            No events yet. Waiting for live data...
          </div>
        )}
      </div>
    </div>
  );
}
