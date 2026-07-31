import React from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { UserStatus } from '../../types';
import styles from '../../pages/Dashboard.module.css';

interface LiveClusterWorkspaceProps {
  activeClusters: Map<string, { asker: string; replies: string[]; resolvedHelper?: string; timestamp: number }>;
  users: UserStatus[];
}

export default function LiveClusterWorkspace({ activeClusters, users }: LiveClusterWorkspaceProps) {
  const clusters = Array.from(activeClusters.entries());

  // Helper to find a user by ID
  const getUser = (id: string) => users.find(u => u.id === id);

  // Dynamic zoom effect based on number of active clusters
  const scale = Math.max(0.4, 1 - (clusters.length * 0.1));

  return (
    <div className={styles.card} style={{ flex: 1, display: 'flex', flexDirection: 'column' }}>
      <h2 className={styles.cardTitle}>Live Cluster Workspace</h2>
      
      <div className={styles.workspaceContainer}>
        {clusters.length === 0 ? (
          <div className={styles.workspaceEmpty}>
            <div style={{ width: '4rem', height: '4rem', borderRadius: '50%', border: '2px dashed #9CA3AF', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <span style={{ fontSize: '1.5rem', color: '#9CA3AF' }}>?</span>
            </div>
            <p>Awaiting live asks to form clusters...</p>
          </div>
        ) : (
          <div 
            className={styles.workspaceGrid} 
            style={{ transform: `scale(${scale})` }}
          >
            <AnimatePresence>
              {clusters.map(([askId, cluster]) => {
                const askerUser = getUser(cluster.asker);
                
                return (
                  <motion.div
                    key={askId}
                    initial={{ scale: 0, opacity: 0 }}
                    animate={{ scale: 1, opacity: 1 }}
                    exit={{ scale: 0, opacity: 0 }}
                    transition={{ type: 'spring', stiffness: 200, damping: 20 }}
                    className={styles.clusterNode}
                  >
                    {/* Background SVG lines for this specific cluster */}
                    <svg className={styles.svgLines}>
                      <AnimatePresence>
                        {cluster.replies.map((replierId, index) => {
                          const angle = (index * (360 / Math.max(1, cluster.replies.length))) * (Math.PI / 180);
                          const radius = 90;
                          const isMatched = cluster.resolvedHelper === replierId;
                          
                          return (
                            <motion.line
                              key={`${askId}-${replierId}-line`}
                              initial={{ pathLength: 0, opacity: 0 }}
                              animate={{ pathLength: 1, opacity: 1 }}
                              exit={{ opacity: 0 }}
                              x1="50%"
                              y1="50%"
                              x2={`calc(50% + ${Math.cos(angle) * radius}px)`}
                              y2={`calc(50% + ${Math.sin(angle) * radius}px)`}
                              className={`${styles.connectionLine} ${isMatched ? styles.connectionLineMatched : ''}`}
                            />
                          );
                        })}
                      </AnimatePresence>
                    </svg>

                    <div className={styles.clusterCenter}>
                      {askerUser?.avatar ? (
                        <img src={askerUser.avatar} alt={askerUser.name} className={styles.clusterCenterImage} />
                      ) : (
                        askerUser?.name.charAt(0).toUpperCase() || '?'
                      )}
                    </div>
                    
                    <AnimatePresence>
                      {cluster.replies.map((replierId, index) => {
                        const replierUser = getUser(replierId);
                        const angle = (index * (360 / Math.max(1, cluster.replies.length))) * (Math.PI / 180);
                        const radius = 90;
                        const isMatched = cluster.resolvedHelper === replierId;
                        
                        return (
                          <motion.div
                            key={replierId}
                            initial={{ scale: 0, opacity: 0 }}
                            animate={{ 
                              scale: 1, 
                              opacity: 1,
                              x: Math.cos(angle) * radius,
                              y: Math.sin(angle) * radius
                            }}
                            className={`${styles.clusterReplier} ${isMatched ? styles.clusterReplierMatched : ''}`}
                            style={{ top: '50%', left: '50%' }}
                          >
                            {replierUser?.avatar ? (
                              <img src={replierUser.avatar} alt={replierUser.name} className={styles.clusterReplierImage} />
                            ) : (
                              replierUser?.name.charAt(0).toUpperCase() || '?'
                            )}
                          </motion.div>
                        );
                      })}
                    </AnimatePresence>
                  </motion.div>
                );
              })}
            </AnimatePresence>
          </div>
        )}
      </div>
    </div>
  );
}
