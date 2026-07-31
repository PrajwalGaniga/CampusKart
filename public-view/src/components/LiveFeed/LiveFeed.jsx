import React from 'react';
import { Box, Typography } from '@mui/material';
import ActivityCard from '../ActivityCard/ActivityCard';

const LiveFeed = ({ asks }) => {
  return (
    <Box sx={{ height: '100%', display: 'flex', flexDirection: 'column' }}>
      <Typography variant="h5" sx={{ mb: 2, fontWeight: 'bold', borderBottom: '2px solid #1976d2', pb: 1, display: 'inline-block' }}>
        Live Activity Feed
      </Typography>
      
      <Box sx={{ flexGrow: 1, overflowY: 'auto', pr: 2, '&::-webkit-scrollbar': { width: '8px' }, '&::-webkit-scrollbar-thumb': { backgroundColor: '#ccc', borderRadius: '4px' } }}>
        {asks.length === 0 ? (
          <Typography variant="body1" color="text.secondary" sx={{ textAlign: 'center', mt: 4 }}>
            Waiting for activity...
          </Typography>
        ) : (
          asks.map((ask) => (
            <ActivityCard key={ask.id} ask={ask} />
          ))
        )}
      </Box>
    </Box>
  );
};

export default LiveFeed;
