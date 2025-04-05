import { useState } from 'react';
import axios from 'axios';
import { useNavigate } from 'react-router-dom';
import '../admin.css';

function AddCategory() {
  const [name, setName] = useState('');
  const [description, setDescription] = useState('');
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setSuccess('');

    try {
      const token = localStorage.getItem('token');

      const res = await axios.post(
        `${import.meta.env.VITE_API_URL}/categories/create`,
        { name, description },
        {
          headers: { Authorization: `Bearer ${token}` },
          withCredentials: true,
        }
      );

      setSuccess('Category added successfully!');
      setName('');
      setDescription('');
    } catch (err) {
      setError(err.response?.data?.message || 'Failed to add category');
    }
  };

  return (
    <div className="card">
      <h2 className="card-title">Add Category</h2>
      {error && <div className="error-message">{error}</div>}
      {success && <div className="success-message">{success}</div>}
      
      <form onSubmit={handleSubmit}>
        <div className="form-group">
          <label className="form-label">Name:</label>
          <input
            className="form-control"
            type="text"
            value={name}
            onChange={(e) => setName(e.target.value)}
            required
          />
        </div>
        
        <div className="form-group">
          <label className="form-label">Description:</label>
          <textarea
            className="form-control"
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            required
            rows="4"
          />
        </div>
        
        <button type="submit" className="btn btn-primary">
          Add Category
        </button>
      </form>
    </div>
  );
}

export default AddCategory;