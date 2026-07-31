import React from 'react';
import { Activity, Database, Server, Clock, Sun, Moon } from 'lucide-react';
import { SystemHealth } from '../../types';
import styles from '../../pages/Dashboard.module.css';

interface TopNavbarProps {
  isSimulationEnabled: boolean;
  onSimulationToggle: (enabled: boolean) => void;
  health: SystemHealth;
}

export default function TopNavbar({ isSimulationEnabled, onSimulationToggle, health }: TopNavbarProps) {
  const [time, setTime] = React.useState(new Date());

  React.useEffect(() => {
    const timer = setInterval(() => setTime(new Date()), 1000);
    return () => clearInterval(timer);
  }, []);

  return (
    <div className={styles.topbar}>
      <div className={styles.topbarLeft}>
        <div className={styles.topbarTitle}>Overview</div>
        <div className={styles.systemStatus}>
          <div className={styles.statusItem}>
            <Activity size={14} color={health.backend === 'connected' ? '#16A34A' : '#DC2626'} />
            <span>API {health.latency}ms</span>
          </div>
          <div className={styles.statusItem}>
            <Database size={14} color={health.mongo === 'connected' ? '#16A34A' : '#DC2626'} />
            <span>Mongo</span>
          </div>
          <div className={styles.statusItem}>
            <Server size={14} color={health.websocket === 'connected' ? '#16A34A' : '#DC2626'} />
            <span>Relay</span>
          </div>
        </div>
      </div>
      
      <div className={styles.topbarRight}>
        <div className={styles.timeDisplay}>
          <Clock size={14} />
          <span>{time.toLocaleTimeString()}</span>
        </div>
        
        <div className={styles.simulationToggle} onClick={() => onSimulationToggle(!isSimulationEnabled)}>
          <div className={`${styles.toggleOption} ${!isSimulationEnabled ? styles.active : ''}`}>
            Live
          </div>
          <div className={`${styles.toggleOption} ${isSimulationEnabled ? styles.active : ''}`}>
            Simulate
          </div>
        </div>
      </div>
    </div>
  );
}
