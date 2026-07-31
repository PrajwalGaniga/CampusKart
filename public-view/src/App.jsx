import React, { useState, useEffect, useCallback } from 'react';
import { Box, Container, Grid, CssBaseline, Typography } from '@mui/material';
import Header from './components/Header/Header';
import LiveFeed from './components/LiveFeed/LiveFeed';
import Statistics from './components/Statistics/Statistics';
import Ticker from './components/Ticker/Ticker';
import { getPublicFeed, getPublicStats, checkHealth } from './services/api';
import { wsService } from './services/websocket';

function App() {
  const [asks, setAsks] = useState([]);
  const [stats, setStats] = useState(null);
  const [tickerEvents, setTickerEvents] = useState([]);
  const [backendConnected, setBackendConnected] = useState(false);
  const [wsConnected, setWsConnected] = useState(false);

  const addTickerEvent = useCallback((eventStr) => {
    setTickerEvents((prev) => [eventStr, ...prev].slice(0, 10)); // Keep last 10
  }, []);

  const fetchInitialData = async () => {
    try {
      await checkHealth();
      setBackendConnected(true);
      
      const [feedData, statsData] = await Promise.all([
        getPublicFeed(),
        getPublicStats()
      ]);
      
      setAsks(feedData);
      setStats(statsData);
    } catch (err) {
      console.error('Failed to fetch initial data:', err);
      setBackendConnected(false);
    }
  };

  useEffect(() => {
    fetchInitialData();
    
    // Poll API health
    const healthInterval = setInterval(async () => {
      try {
        await checkHealth();
        setBackendConnected(true);
      } catch (err) {
        setBackendConnected(false);
      }
    }, 10000);

    // Setup WebSocket
    wsService.onStatusChange(setWsConnected);
    
    wsService.onMessage((data) => {
      if (data.event === 'connected') {
        addTickerEvent('System connected to live feed');
      } 
      else if (data.event === 'ASK_CREATED') {
        const newAsk = data.data;
        setAsks((prev) => [newAsk, ...prev]);
        addTickerEvent(`New ask created: ${newAsk.title}`);
        
        // Optimistic stats update
        setStats(prev => prev ? {
          ...prev, 
          open_asks: prev.open_asks + 1,
          total_events: prev.total_events + 1
        } : null);
      }
      else if (data.event === 'REPLY_ADDED') {
        const { ask_id } = data.data;
        setAsks((prev) => prev.map(ask => 
          ask.id === ask_id ? { ...ask, reply_count: ask.reply_count + 1 } : ask
        ));
        addTickerEvent('New reply added to an ask');
      }
      else if (data.event === 'ASK_LOCKED') {
        const { ask_id } = data.data;
        setAsks((prev) => prev.map(ask => 
          ask.id === ask_id ? { ...ask, status: 'LOCKED' } : ask
        ));
        addTickerEvent('Ask locked due to max replies');
        
        setStats(prev => prev ? {
          ...prev, 
          open_asks: Math.max(0, prev.open_asks - 1),
          locked_asks: prev.locked_asks + 1
        } : null);
      }
      else if (data.event === 'ASK_RESOLVED') {
        const { ask_id } = data.data;
        setAsks((prev) => prev.map(ask => 
          ask.id === ask_id ? { ...ask, status: 'RESOLVED' } : ask
        ));
        addTickerEvent('Ask resolved successfully');
        
        setStats(prev => prev ? {
          ...prev, 
          open_asks: Math.max(0, prev.open_asks - 1),
          resolved_asks: prev.resolved_asks + 1
        } : null);
      }
    });

    wsService.connect();

    return () => {
      clearInterval(healthInterval);
      if (wsService.ws) {
        wsService.ws.close();
      }
    };
  }, [addTickerEvent]);

  return (
    <Box sx={{ height: '100vh', display: 'flex', flexDirection: 'column', overflow: 'hidden' }}>
      <CssBaseline />
      <Header backendConnected={backendConnected} wsConnected={wsConnected} />
      
      <Box sx={{ flexGrow: 1, p: 3, overflow: 'hidden' }}>
        {!backendConnected && (
          <Box sx={{ position: 'absolute', top: '50%', left: '50%', transform: 'translate(-50%, -50%)', zIndex: 999, textAlign: 'center', backgroundColor: 'rgba(255,255,255,0.9)', p: 4, borderRadius: 2, boxShadow: 3 }}>
            <Typography variant="h4" color="error" gutterBottom>Backend Offline</Typography>
            <Typography>Attempting to reconnect...</Typography>
          </Box>
        )}
        
        <Grid container spacing={4} sx={{ height: '100%' }}>
          <Grid item xs={9} sx={{ height: '100%' }}>
            <LiveFeed asks={asks} />
          </Grid>
          <Grid item xs={3} sx={{ height: '100%' }}>
            <Statistics stats={stats} />
          </Grid>
        </Grid>
      </Box>
      
      <Ticker events={tickerEvents} />
    </Box>
  );
}

export default App;
