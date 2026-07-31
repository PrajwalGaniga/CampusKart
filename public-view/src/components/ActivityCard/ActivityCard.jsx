import React from 'react';
import { Card, CardContent, Typography, Box } from '@mui/material';
import SchoolIcon from '@mui/icons-material/School';
import RestaurantIcon from '@mui/icons-material/Restaurant';
import CategoryIcon from '@mui/icons-material/Category';
import DirectionsBusIcon from '@mui/icons-material/DirectionsBus';
import WarningIcon from '@mui/icons-material/Warning';
import EventIcon from '@mui/icons-material/Event';
import LocationOnIcon from '@mui/icons-material/LocationOn';
import MoreHorizIcon from '@mui/icons-material/MoreHoriz';
import StatusChip from '../StatusChip/StatusChip';

const getCategoryIcon = (category) => {
  switch (category?.toUpperCase()) {
    case 'ACADEMIC': return <SchoolIcon fontSize="large" color="primary" />;
    case 'FOOD': return <RestaurantIcon fontSize="large" color="error" />;
    case 'ITEMS': return <CategoryIcon fontSize="large" color="secondary" />;
    case 'TRANSPORT': return <DirectionsBusIcon fontSize="large" color="info" />;
    case 'EMERGENCY': return <WarningIcon fontSize="large" color="warning" />;
    case 'EVENT': return <EventIcon fontSize="large" color="success" />;
    case 'LOCATION': return <LocationOnIcon fontSize="large" color="primary" />;
    default: return <MoreHorizIcon fontSize="large" color="action" />;
  }
};

const formatTimeAgo = (dateString) => {
  const date = new Date(dateString);
  const now = new Date();
  const diffInSeconds = Math.floor((now - date) / 1000);
  
  if (diffInSeconds < 60) return 'Just now';
  if (diffInSeconds < 3600) return `${Math.floor(diffInSeconds / 60)} mins ago`;
  if (diffInSeconds < 86400) return `${Math.floor(diffInSeconds / 3600)} hours ago`;
  return `${Math.floor(diffInSeconds / 86400)} days ago`;
};

const ActivityCard = ({ ask }) => {
  return (
    <Card sx={{ 
      mb: 2, 
      backgroundColor: '#f8f9fa',
      transition: 'all 0.3s ease',
      animation: 'fadeIn 0.5s ease-in-out',
      '@keyframes fadeIn': {
        '0%': { opacity: 0, transform: 'translateY(-10px)' },
        '100%': { opacity: 1, transform: 'translateY(0)' }
      }
    }}>
      <CardContent>
        <Box sx={{ display: 'flex', alignItems: 'flex-start', mb: 2 }}>
          <Box sx={{ mr: 2, p: 1, backgroundColor: '#fff', borderRadius: '50%', boxShadow: 1 }}>
            {getCategoryIcon(ask.category)}
          </Box>
          <Box sx={{ flexGrow: 1 }}>
            <Typography variant="h6" sx={{ fontWeight: 'bold' }}>
              {ask.title}
            </Typography>
            <Typography variant="body1" color="text.secondary" sx={{ mb: 1 }}>
              {ask.requester_name}
            </Typography>
          </Box>
          <Box sx={{ textAlign: 'right' }}>
            <StatusChip status={ask.status} />
            <Typography variant="body2" color="text.secondary" sx={{ mt: 1 }}>
              {formatTimeAgo(ask.created_at)}
            </Typography>
          </Box>
        </Box>
        
        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mt: 2, pt: 2, borderTop: '1px solid #eee' }}>
          <Box sx={{ display: 'flex', alignItems: 'center', color: 'text.secondary' }}>
            <LocationOnIcon fontSize="small" sx={{ mr: 0.5 }} />
            <Typography variant="body2">{ask.location}</Typography>
          </Box>
          
          <Typography variant="body2" sx={{ fontWeight: 'bold', color: 'primary.main' }}>
            Replies: {ask.reply_count} / {ask.max_replies}
          </Typography>
        </Box>
      </CardContent>
    </Card>
  );
};

export default ActivityCard;
