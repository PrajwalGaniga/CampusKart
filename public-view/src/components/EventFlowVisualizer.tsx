import React from 'react';
import { motion } from 'framer-motion';
import { Smartphone, Server, Database, Globe } from 'lucide-react';
import styles from '../pages/Dashboard.module.css';

export default function EventFlowVisualizer() {
  return (
    <div className={styles.card} style={{ gridColumn: 'span 12', height: '200px' }}>
      <div className={styles.cardHeader}>Event Data Flow Visualization</div>
      
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', height: '100%', padding: '0 4rem', position: 'relative' }}>
        {/* Connection Line */}
        <div style={{ position: 'absolute', top: '50%', left: '4rem', right: '4rem', height: '2px', backgroundColor: 'var(--border-color)', zIndex: 0 }} />
        
        {/* Animated Particles */}
        <motion.div 
          style={{ position: 'absolute', top: 'calc(50% - 4px)', left: '4rem', width: '8px', height: '8px', backgroundColor: 'var(--accent-color)', borderRadius: '50%', zIndex: 1, boxShadow: '0 0 10px var(--accent-color)' }}
          animate={{ left: ['4rem', 'calc(100% - 4rem)'] }}
          transition={{ duration: 3, repeat: Infinity, ease: 'linear' }}
        />
        <motion.div 
          style={{ position: 'absolute', top: 'calc(50% - 4px)', left: '4rem', width: '8px', height: '8px', backgroundColor: 'var(--accent-success)', borderRadius: '50%', zIndex: 1, boxShadow: '0 0 10px var(--accent-success)' }}
          animate={{ left: ['4rem', 'calc(100% - 4rem)'] }}
          transition={{ duration: 3, repeat: Infinity, ease: 'linear', delay: 1.5 }}
        />

        {/* Nodes */}
        <Node icon={<Smartphone size={24} />} label="Flutter App" />
        <Node icon={<Server size={24} />} label="FastAPI Backend" />
        <Node icon={<Database size={24} />} label="MongoDB" />
        <Node icon={<Globe size={24} />} label="Public Dashboard" />
      </div>
    </div>
  );
}

function Node({ icon, label }: { icon: React.ReactNode, label: string }) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '1rem', zIndex: 2 }}>
      <div style={{ width: '64px', height: '64px', borderRadius: '50%', backgroundColor: 'var(--bg-main)', border: '2px solid var(--border-color)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--text-primary)' }}>
        {icon}
      </div>
      <div style={{ fontSize: '0.875rem', color: 'var(--text-secondary)', fontWeight: 500 }}>{label}</div>
    </div>
  );
}
