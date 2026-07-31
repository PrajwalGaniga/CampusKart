import React from 'react';
import { LayoutDashboard, Radio, Users, Activity, ShieldAlert, Info, Command } from 'lucide-react';
import styles from '../../pages/Dashboard.module.css';

export default function LeftSidebar() {
  const navItems = [
    { icon: LayoutDashboard, label: 'Dashboard', active: true },
    { icon: Radio, label: 'Live Network' },
    { icon: Activity, label: 'Cluster Monitor' },
    { icon: Users, label: 'Users' },
    { icon: ShieldAlert, label: 'System Health' },
    { icon: Info, label: 'About' },
  ];

  return (
    <div className={styles.sidebar}>
      <div className={styles.sidebarHeader}>
        <Command size={24} color="#2563EB" />
        CampusPulse
      </div>
      
      <div className={styles.sidebarNav}>
        {navItems.map((item, index) => (
          <div key={index} className={`${styles.navItem} ${item.active ? styles.active : ''}`}>
            <item.icon size={18} />
            <span>{item.label}</span>
          </div>
        ))}
      </div>
    </div>
  );
}
