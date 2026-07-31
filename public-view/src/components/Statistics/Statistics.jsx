import React from 'react';
import { Box, Typography, Paper, Grid } from '@mui/material';

const StatCard = ({ title, value, color }) => (
  <Paper sx={{ p: 2, textAlign: 'center', mb: 2, borderLeft: `4px solid ${color}` }}>
    <Typography variant="body2" color="text.secondary" sx={{ textTransform: 'uppercase', fontWeight: 'bold' }}>
      {title}
    </Typography>
    <Typography variant="h4" sx={{ fontWeight: 'bold', color: color, mt: 1 }}>
      {value}
    </Typography>
  </Paper>
);

const Statistics = ({ stats }) => {
  if (!stats) return null;

  return (
    <Box sx={{ height: '100%' }}>
      <Typography variant="h5" sx={{ mb: 2, fontWeight: 'bold', borderBottom: '2px solid #1976d2', pb: 1, display: 'inline-block' }}>
        Campus Statistics
      </Typography>
      
      <Box sx={{ mt: 2 }}>
        <StatCard title="Open Asks" value={stats.open_asks} color="#2e7d32" />
        <StatCard title="Resolved Today" value={stats.resolved_asks} color="#0288d1" />
        <StatCard title="Locked Asks" value={stats.locked_asks} color="#ed6c02" />
        <StatCard title="Expired" value={stats.expired_asks} color="#d32f2f" />
        
        <Grid container spacing={2} sx={{ mt: 1 }}>
          <Grid item xs={6}>
            <Paper sx={{ p: 1.5, textAlign: 'center', backgroundColor: '#f5f5f5' }}>
              <Typography variant="caption" color="text.secondary" sx={{ display: 'block' }}>Online</Typography>
              <Typography variant="h6" sx={{ fontWeight: 'bold' }}>{stats.online_users}</Typography>
            </Paper>
          </Grid>
          <Grid item xs={6}>
            <Paper sx={{ p: 1.5, textAlign: 'center', backgroundColor: '#f5f5f5' }}>
              <Typography variant="caption" color="text.secondary" sx={{ display: 'block' }}>Events</Typography>
              <Typography variant="h6" sx={{ fontWeight: 'bold' }}>{stats.total_events}</Typography>
            </Paper>
          </Grid>
        </Grid>
        
        <Box sx={{ mt: 3, p: 2, backgroundColor: '#e3f2fd', borderRadius: 1, textAlign: 'center' }}>
          <Typography variant="body2" color="primary" sx={{ fontWeight: 'bold' }}>
            Average Response Time
          </Typography>
          <Typography variant="h5" color="primary" sx={{ mt: 0.5 }}>
            {stats.average_response_time}
          </Typography>
        </Box>
      </Box>
    </Box>
  );
};

export default Statistics;
