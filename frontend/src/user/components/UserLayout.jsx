import { Outlet, Link, useNavigate } from 'react-router-dom';
import axios from 'axios';
import '../user.css';

function UserLayout() {
  const navigate = useNavigate();

  const handleLogout = async () => {
    await axios.post(`${import.meta.env.VITE_API_URL}/users/logout`, {}, { withCredentials: true });
    navigate('/login');
  };

  return (
    <div>
      <nav>
        <h1>User Panel</h1>
        <ul>
          <li><Link to="/user">Dashboard</Link></li>
          <li><Link to="/user/profile">Profile</Link></li>
          <li><button onClick={handleLogout}>Logout</button></li>
        </ul>
      </nav>
      <div className="user-content">
        <Outlet />
      </div>
    </div>
  );
}

export default UserLayout;