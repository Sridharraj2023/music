import { Navigate } from 'react-router-dom';
import { useEffect, useState } from 'react';
import axios from 'axios';

function ProtectedRoute({ children, requiredRole }) {
  const [isAuthenticated, setIsAuthenticated] = useState(null);

  useEffect(() => {
    const checkAuth = async () => {
      try {
        const res = await axios.get(`${import.meta.env.VITE_API_URL}/users/profile`, {
          headers: { Authorization: `Bearer ${localStorage.getItem('token')}` },
        });
        console.log('ProtectedRoute response:', res.data);
        setIsAuthenticated(res.data.role === requiredRole);
      } catch (error) {
        console.error('ProtectedRoute error:', error.response?.data);
        setIsAuthenticated(false);
      }
    };
    checkAuth();
  }, [requiredRole]);

  if (isAuthenticated === null) return <div>Loading...</div>;
  return isAuthenticated ? children : <Navigate to="/login" />;
}

export default ProtectedRoute;