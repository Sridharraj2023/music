import { useState } from 'react';
import axios from 'axios';
import { useNavigate } from 'react-router-dom';
import './Signup.css';

function Signup({ setUserRole }) {
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError(''); // Clear previous errors
    
    try {
      console.log('Signup attempt:', { name, email });
      
      // Use absolute URL in development, relative in production
      const apiUrl = import.meta.env.DEV 
        ? 'http://localhost:5000/api' 
        : '/api';
      
      const res = await axios.post(
        `${apiUrl}/users`,
        { name, email, password },
        { 
          withCredentials: true,
          headers: {
            'Content-Type': 'application/json'
          }
        }
      );
      
      console.log('Signup response:', res.data);
      
      if (res.data.token) {
        localStorage.setItem('token', res.data.token);
        console.log('Token stored in localStorage');
        
        if (res.data.role) {
          console.log('Setting user role:', res.data.role);
          setUserRole(res.data.role);
          
          if (res.data.role === 'admin') {
            console.log('Navigating to /admin');
            navigate('/admin');
          } else {
            console.log('Navigating to /user');
            navigate('/user');
          }
        } else {
          console.error('No role in response');
          throw new Error('No role received from server');
        }
      } else {
        console.error('No token in response');
        throw new Error('No authentication token received');
      }
    } catch (err) {
      console.error('Signup error:', err);
      console.error('Error response:', err.response?.data);
      
      if (err.response) {
        if (err.response.status === 400 && err.response.data?.message === 'User already exists') {
          setError('This email is already registered. Please log in instead.');
        } else if (err.response.data?.message) {
          setError(err.response.data.message);
        } else {
          setError(`Server error: ${err.response.status}`);
        }
      } else if (err.request) {
        setError('Cannot connect to the server. Please check your connection.');
      } else {
        setError('An error occurred. Please try again.');
      }
    }
  };

  return (
    <div className="signup-container">
      <div className="signup-card">
        <h2>Sign Up</h2>
        {error && <p className="error">{error}</p>}
        <form onSubmit={handleSubmit}>
          <div>
            <label>Name:</label> <br />
            <input
              type="text"
              value={name}
              onChange={(e) => setName(e.target.value)}
              required
            />
          </div>
          <div>
            <label>Email:</label> <br />
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
            />
          </div>
          <div>
            <label>Password:</label> <br />
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
            />
          </div>
          <button type="submit">Sign Up</button>
        </form>
        <p>
          Already have an account? <a href="/login">Login here</a>
        </p>
      </div>
    </div>
  );
}

export default Signup;