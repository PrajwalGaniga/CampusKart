import React from 'react';
import { Chip } from '@mui/material';

const StatusChip = ({ status }) => {
  const getStatusProps = (status) => {
    switch (status) {
      case 'OPEN':
        return { color: 'success', label: 'OPEN' };
      case 'LOCKED':
        return { color: 'warning', label: 'LOCKED' };
      case 'RESOLVED':
        return { color: 'info', label: 'RESOLVED' };
      case 'EXPIRED':
        return { color: 'error', label: 'EXPIRED' };
      default:
        return { color: 'default', label: status };
    }
  };

  const props = getStatusProps(status);

  return (
    <Chip
      label={props.label}
      color={props.color}
      size="small"
      sx={{ fontWeight: 'bold' }}
    />
  );
};

export default StatusChip;
