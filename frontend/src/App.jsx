import { Routes, Route, useNavigate, useLocation } from 'react-router-dom';
import { useEffect, useState } from 'react';
import axios from 'axios';
import Login from './components/Login.jsx';
import Signup from './components/Signup.jsx';
import AdminLayout from './admin/components/AdminLayout.jsx';
import Dashboard from './admin/pages/Dashboard.jsx';
import AddCategory from './admin/pages/AddCategory.jsx';
import AddMusic from './admin/pages/AddMusic.jsx';
import ViewUsers from './admin/pages/ViewUsers.jsx';
import ViewCategories from './admin/pages/ViewCategories.jsx'; // New
import ViewMusic from './admin/pages/ViewMusic.jsx'; // New
import UserLayout from './user/components/UserLayout.jsx';
import UserDashboard from './user/pages/Dashboard.jsx';
import Profile from './user/pages/Profile.jsx';
import ProtectedRoute from './components/ProtectedRoute.jsx';

function App() {
  const [userRole, setUserRole] = useState(null);
  const navigate = useNavigate();
  const location = useLocation();

  useEffect(() => {
    const checkAuth = async () => {
      // Skip if on login, signup, or valid admin/user sub-routes
      if (
        location.pathname === '/login' ||
        location.pathname === '/signup' ||
        location.pathname.startsWith('/admin') ||
        location.pathname.startsWith('/user')
      ) {
        return;
      }

      try {
        const res = await axios.get(`${import.meta.env.VITE_API_URL}/users/profile`, {
          headers: { Authorization: `Bearer ${localStorage.getItem('token')}` },
          withCredentials: true, // Add this if needed for cookies
        });
        console.log('App auth check:', res.data);
        setUserRole(res.data.role);
        if (res.data.role === 'admin') {
          navigate('/admin');
        } else {
          navigate('/user');
        }
      } catch (error) {
        console.log('Not authenticated', error.response?.data);
        navigate('/login');
      }
    };
    checkAuth();
  }, [navigate, location.pathname]);

  return (
    <div className="container">
      <Routes>
        <Route path="/login" element={<Login setUserRole={setUserRole} />} />
        <Route path="/signup" element={<Signup setUserRole={setUserRole} />} />
        <Route
          path="/admin/*"
          element={
            <ProtectedRoute requiredRole="admin">
              <AdminLayout />
            </ProtectedRoute>
          }
        >
          <Route index element={<Dashboard />} />
          <Route path="manage-categories" element={<Dashboard />} /> {/* Dashboard handles sub-options */}
          <Route path="manage-music" element={<Dashboard />} /> {/* Dashboard handles sub-options */}
          <Route path="manage-users" element={<ViewUsers />} /> {/* Redirects to ViewUsers */}
          <Route path="add-category" element={<AddCategory />} />
          <Route path="add-music" element={<AddMusic />} />
          <Route path="view-categories" element={<ViewCategories />} />
          <Route path="view-music" element={<ViewMusic />} />
          <Route path="view-users" element={<ViewUsers />} /> {/* Kept for consistency */}
        </Route>
        <Route
          path="/user/*"
          element={
            <ProtectedRoute requiredRole="user">
              <UserLayout />
            </ProtectedRoute>
          }
        >
          <Route index element={<UserDashboard />} />
          <Route path="profile" element={<Profile />} />
        </Route>
        <Route path="/" element={<Login setUserRole={setUserRole} />} />
      </Routes>
    </div>
  );
}

export default App;