const API_BASE = '/api';

export function getAuthToken() {
  return localStorage.getItem('token');
}

export function setAuthToken(token) {
  if (token) {
    localStorage.setItem('token', token);
  } else {
    localStorage.removeItem('token');
  }
}

export async function fetchApi(endpoint, options = {}) {
  const token = getAuthToken();
  const headers = {
    'Content-Type': 'application/json',
    ...(options.headers || {}),
  };

  if (token) {
    headers['Authorization'] = `Bearer ${token}`;
  }

  const response = await fetch(`${API_BASE}${endpoint}`, {
    ...options,
    headers,
  });

  let data;
  try {
    data = await response.json();
  } catch (err) {
    data = null;
  }

  if (!response.ok) {
    const errorMsg = data?.detail || data?.message || `HTTP Error ${response.status}`;
    const error = new Error(errorMsg);
    error.status = response.status;
    error.data = data;
    throw error;
  }

  return data;
}

// Auth API
export const authApi = {
  signup: (payload) => fetchApi('/auth/signup', { method: 'POST', body: JSON.stringify(payload) }),
  login: (payload) => fetchApi('/auth/login', { method: 'POST', body: JSON.stringify(payload) }),
  getMe: () => fetchApi('/auth/me'),
};

// Friends API
export const friendsApi = {
  getFriends: () => fetchApi('/friends'),
  getRequests: () => fetchApi('/friends/requests'),
  search: (query) => fetchApi(`/friends/search?query=${encodeURIComponent(query)}`),
  request: (friendId) => fetchApi('/friends/request', { method: 'POST', body: JSON.stringify({ friend_id: friendId }) }),
  accept: (requestId) => fetchApi('/friends/accept', { method: 'POST', body: JSON.stringify({ request_id: requestId }) }),
  reject: (requestId) => fetchApi('/friends/reject', { method: 'POST', body: JSON.stringify({ request_id: requestId }) }),
  getQr: () => fetchApi('/friends/qr'),
  addByQr: (qrCode) => fetchApi('/friends/qr-add', { method: 'POST', body: JSON.stringify({ qr_code: qrCode }) }),
};

// Asks API
export const asksApi = {
  createAsk: (payload) => fetchApi('/asks', { method: 'POST', body: JSON.stringify(payload) }),
  getFeed: () => fetchApi('/asks/feed'),
  replyToAsk: (askId, text) => fetchApi(`/asks/${askId}/reply`, { method: 'POST', body: JSON.stringify({ text }) }),
  resolveAsk: (askId) => fetchApi(`/asks/${askId}/resolve`, { method: 'POST' }),
  getHistory: () => fetchApi('/asks/history'),
  clearHistory: () => fetchApi('/asks/history', { method: 'DELETE' }),
};

// Public Board API
export const boardApi = {
  getBoard: () => fetchApi('/board'),
};

// Seed API
export const seedApi = {
  runSeed: () => fetchApi('/seed', { method: 'POST' }),
};
