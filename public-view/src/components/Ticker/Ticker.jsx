import React from 'react';
import { Box, Typography } from '@mui/material';

const Ticker = ({ events }) => {
  return (
    <Box sx={{ 
      backgroundColor: '#333', 
      color: '#fff', 
      py: 1, 
      px: 2, 
      overflow: 'hidden',
      whiteSpace: 'nowrap',
      display: 'flex',
      alignItems: 'center'
    }}>
      <Typography variant="body2" sx={{ fontWeight: 'bold', mr: 2, color: '#fdd835' }}>
        LATEST UPDATES:
      </Typography>
      
      <Box sx={{ 
        display: 'inline-block',
        animation: 'ticker 30s linear infinite',
        '@keyframes ticker': {
          '0%': { transform: 'translateX(100%)' },
          '100%': { transform: 'translateX(-100%)' }
        }
      }}>
        {events.length === 0 ? (
          <span style={{ marginRight: '50px' }}>Waiting for updates...</span>
        ) : (
          events.map((event, index) => (
            <span key={index} style={{ marginRight: '50px' }}>
              • {event}
            </span>
          ))
        )}
      </Box>
    </Box>
  );
};

export default Ticker;
