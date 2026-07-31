import React, { useState } from 'react';
import DashboardLayout from '../components/layout/DashboardLayout';
import LiveMetrics from '../components/widgets/LiveMetrics';
import UserUniverse from '../components/widgets/UserUniverse';
import LiveClusterWorkspace from '../components/widgets/LiveClusterWorkspace';
import EventTimeline from '../components/widgets/EventTimeline';
import SystemHealth from '../components/widgets/SystemHealth';
import { useDashboardData } from '../hooks/useDashboardData';

export default function Dashboard() {
  const [isSimulationEnabled, setIsSimulationEnabled] = useState(false);
  const { events, users, metrics, health, activeClusters } = useDashboardData(isSimulationEnabled);

  return (
    <DashboardLayout 
      isSimulationEnabled={isSimulationEnabled} 
      onSimulationToggle={setIsSimulationEnabled}
      systemHealth={health}
    >
      <div style={{ display: 'flex', flexDirection: 'column', gap: '1.5rem', height: '100%' }}>
        {/* Section 1: Top Metrics Row */}
        <div>
          <LiveMetrics metrics={metrics} />
        </div>
        
        {/* Main Content Split */}
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(350px, 1fr))', gap: '1.5rem', flex: 1 }}>
          
          {/* Left Column: Visualizations */}
          <div style={{ display: 'flex', flexDirection: 'column', gap: '1.5rem', gridColumn: 'span 2' }}>
            {/* Section 3: The Hero */}
            <LiveClusterWorkspace activeClusters={activeClusters} users={users} />
            
            {/* Section 2: User Roster */}
            <UserUniverse users={users} />
          </div>

          {/* Right Column: Logs and Status */}
          <div style={{ display: 'flex', flexDirection: 'column', gap: '1.5rem' }}>
            {/* Section 4: Live Event Feed */}
            <EventTimeline events={events} />
            
            {/* Section 5: System Monitors */}
            <SystemHealth health={health} />
          </div>

        </div>
      </div>
    </DashboardLayout>
  );
}
