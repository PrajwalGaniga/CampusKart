import React from 'react';
import { UserStatus } from '../../types';
import styles from '../../pages/Dashboard.module.css';

interface UserUniverseProps {
  users: UserStatus[];
}

export default function UserUniverse({ users }: UserUniverseProps) {
  const getStatusColor = (state: string, isOnline: boolean) => {
    if (!isOnline) return styles.statusGray;
    switch (state) {
      case 'idle': return styles.statusGreen;
      case 'waiting': return styles.statusOrange;
      case 'helping': return styles.statusBlue;
      case 'resolved': return styles.statusBlue;
      default: return styles.statusGreen;
    }
  };

  const getStatusText = (state: string) => {
    switch (state) {
      case 'idle': return 'Idle';
      case 'waiting': return 'Asking';
      case 'helping': return 'Helping';
      case 'resolved': return 'Done';
      default: return 'Idle';
    }
  };

  return (
    <div className={styles.card}>
      <h2 className={styles.cardTitle}>User Universe</h2>
      <div className={styles.userGrid}>
        {users.map(user => (
          <div key={user.id} className={styles.userCard}>
            <div className={styles.userAvatar}>
              {user.avatar ? (
                <img src={user.avatar} alt={user.name} className={styles.avatarImage} />
              ) : (
                <div className={styles.avatarCircle}>
                  {user.name.charAt(0).toUpperCase()}
                </div>
              )}
              <div className={`${styles.statusIndicator} ${getStatusColor(user.state, user.isOnline)}`} />
            </div>
            <div className={styles.userName}>{user.name}</div>
            <div className={styles.userHandle}>@{user.username}</div>
            <div className={styles.userBadge}>
              {user.isOnline ? getStatusText(user.state) : 'Offline'}
            </div>
          </div>
        ))}
        {users.length === 0 && (
          <div style={{ padding: '2rem', textAlign: 'center', color: '#6B7280', gridColumn: '1 / -1' }}>
            Waiting for users to connect...
          </div>
        )}
      </div>
    </div>
  );
}
