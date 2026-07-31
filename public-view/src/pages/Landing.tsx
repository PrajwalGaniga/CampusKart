import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { motion, AnimatePresence } from 'framer-motion';
import styles from './Landing.module.css';

const tasks = [
  'Checking Backend',
  'Connecting WebSocket',
  'Connecting MongoDB',
  'Loading Public Feed',
  'Loading Analytics',
];

export default function Landing() {
  const [currentTask, setCurrentTask] = useState(0);
  const [isReady, setIsReady] = useState(false);
  const navigate = useNavigate();

  useEffect(() => {
    if (currentTask < tasks.length) {
      const timer = setTimeout(() => {
        setCurrentTask(prev => prev + 1);
      }, 600); // 600ms per task for the animation effect
      return () => clearTimeout(timer);
    } else {
      setTimeout(() => setIsReady(true), 400);
    }
  }, [currentTask]);

  return (
    <div className={styles.container}>
      <motion.div 
        className={styles.logoContainer}
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.8, ease: 'easeOut' }}
      >
        <div className={styles.logo}>CampusPulse</div>
        <div className={styles.subtitle}>Operations Control Center</div>
      </motion.div>

      <div className={styles.tasksList}>
        {tasks.map((task, index) => {
          const isDone = currentTask > index;
          const isActive = currentTask === index;
          const isPending = currentTask < index;

          return (
            <motion.div 
              key={task} 
              className={styles.taskItem}
              initial={{ opacity: 0, x: -10 }}
              animate={{ opacity: isPending ? 0.4 : 1, x: 0 }}
              transition={{ delay: index * 0.1 }}
            >
              <span className={isActive || isDone ? styles.taskLabelActive : styles.taskLabel}>
                {task}
              </span>
              <div className={styles.taskStatus}>
                <div className={`${styles.statusIndicator} ${
                  isDone ? styles.statusIndicatorDone : 
                  isActive ? styles.statusIndicatorLoading : ''
                }`} />
              </div>
            </motion.div>
          );
        })}
      </div>

      <AnimatePresence>
        {isReady && (
          <motion.div
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -10 }}
            style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '1.5rem' }}
          >
            <div style={{ color: 'var(--text-secondary)', fontSize: '0.875rem' }}>
              Welcome, Prajwal
            </div>
            <button 
              className={styles.enterButton}
              onClick={() => navigate('/dashboard')}
            >
              Enter Control Center
            </button>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}
