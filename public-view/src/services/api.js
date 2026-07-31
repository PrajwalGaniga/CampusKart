import axios from 'axios';
import { API_BASE_URL } from '../config';

const api = axios.create({
  baseURL: API_BASE_URL,
});

export const getPublicFeed = async () => {
  const response = await api.get('/api/v1/public/feed');
  return response.data;
};

export const getPublicStats = async () => {
  const response = await api.get('/api/v1/public/stats');
  return response.data;
};

export const checkHealth = async () => {
  const response = await api.get('/health');
  return response.data;
};
