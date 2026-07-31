import React from 'react';
import TopNavbar from './TopNavbar';
import { SystemHealth } from '../../types';
import styles from '../../pages/Dashboard.module.css';

interface DashboardLayoutProps {
  children: React.ReactNode;
  isSimulationEnabled: boolean;
  onSimulationToggle: (enabled: boolean) => void;
  systemHealth: SystemHealth;
}

export default function DashboardLayout({ children, isSimulationEnabled, onSimulationToggle, systemHealth }: DashboardLayoutProps) {
  return (
    <div className={styles.dashboardContainer}>
      <div className={styles.dashboardMain}>
        <TopNavbar 
          isSimulationEnabled={isSimulationEnabled} 
          onSimulationToggle={onSimulationToggle} 
          health={systemHealth} 
        />
        <div className={styles.dashboardScroll}>
          {children}
        </div>
      </div>
    </div>
  );
}
