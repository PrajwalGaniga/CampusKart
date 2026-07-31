import React, { useState, useEffect } from 'react';
import { AppBar, Toolbar, Typography, Chip, Box } from '@mui/material';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';
import ErrorIcon from '@mui/icons-material/Error';

const Header = ({ backendConnected, wsConnected }) => {
  const [time, setTime] = useState(new Date());

  useEffect(() => {
    const timer = setInterval(() => setTime(new Date()), 1000);
    return () => clearInterval(timer);
  }, []);

  return (
    <AppBar position="static" sx={{ backgroundColor: '#1976d2' }}>
      <Toolbar>
        <Typography variant="h5" component="div" sx={{ flexGrow: 1, fontWeight: 'bold' }}>
          CampusPulse
          <Typography variant="subtitle1" component="span" sx={{ ml: 2, opacity: 0.8 }}>
            Live Campus Activity
          </Typography>
        </Typography>
        
        <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
          <Typography variant="h6" sx={{ mr: 2 }}>
            {time.toLocaleTimeString()}
          </Typography>
          
          <Chip
            icon={backendConnected ? <CheckCircleIcon /> : <ErrorIcon />}
            label="Backend"
            color={backendConnected ? "success" : "error"}
            variant="filled"
          />
          <Chip
            icon={wsConnected ? <CheckCircleIcon /> : <ErrorIcon />}
            label="WebSocket"
            color={wsConnected ? "success" : "error"}
            variant="filled"
          />
        </Box>
      </Toolbar>
    </AppBar>
  );
};

export default Header;
