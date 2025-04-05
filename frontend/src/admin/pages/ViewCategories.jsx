import { useState, useEffect } from 'react';
import axios from 'axios';
import '../admin.css';

function ViewCategories() {
  const [categories, setCategories] = useState([]);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [editingId, setEditingId] = useState(null);
  const [editName, setEditName] = useState('');
  const [editDescription, setEditDescription] = useState('');

  useEffect(() => {
    const fetchCategories = async () => {
      try {
        const token = localStorage.getItem('token');
        const res = await axios.get(`${import.meta.env.VITE_API_URL}/categories`, {
          headers: { Authorization: `Bearer ${token}` },
          withCredentials: true,
        });
        setCategories(res.data);
      } catch (err) {
        setError(err.response?.data?.message || 'Failed to fetch categories');
      }
    };
    fetchCategories();
  }, []);

  const handleDelete = async (id) => {
    if (!confirm('Are you sure you want to delete this category?')) return;
    try {
      const token = localStorage.getItem('token');
      await axios.delete(`${import.meta.env.VITE_API_URL}/categories/${id}`, {
        headers: { Authorization: `Bearer ${token}` },
        withCredentials: true,
      });
      setCategories(categories.filter(cat => cat._id !== id));
      setSuccess('Category deleted successfully!');
      setTimeout(() => setSuccess(''), 3000);
    } catch (err) {
      setError(err.response?.data?.message || 'Failed to delete category');
    }
  };

  const handleEdit = (category) => {
    setEditingId(category._id);
    setEditName(category.name);
    setEditDescription(category.description);
  };

  const handleUpdate = async (id) => {
    try {
      const token = localStorage.getItem('token');
      const res = await axios.put(
        `${import.meta.env.VITE_API_URL}/categories/${id}`,
        { name: editName, description: editDescription },
        {
          headers: { Authorization: `Bearer ${token}` },
          withCredentials: true,
        }
      );
      setCategories(categories.map(cat => (cat._id === id ? res.data : cat)));
      setEditingId(null);
      setSuccess('Category updated successfully!');
      setTimeout(() => setSuccess(''), 3000);
    } catch (err) {
      setError(err.response?.data?.message || 'Failed to update category');
    }
  };

  return (
    <div className="card">
      <h2 className="card-title">Manage Categories</h2>
      {error && <div className="error-message">{error}</div>}
      {success && <div className="success-message">{success}</div>}

      {categories.length === 0 ? (
        <p>No categories found.</p>
      ) : (
        <table className="data-table">
          <thead>
            <tr>
              <th>Name</th>
              <th>Description</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {categories.map(category => (
              <tr key={category._id}>
                {editingId === category._id ? (
                  <>
                    <td>
                      <input
                        className="form-control"
                        type="text"
                        value={editName}
                        onChange={(e) => setEditName(e.target.value)}
                      />
                    </td>
                    <td>
                      <input
                        className="form-control"
                        type="text"
                        value={editDescription}
                        onChange={(e) => setEditDescription(e.target.value)}
                      />
                    </td>
                    <td>
                      <div className="form-group" style={{ display: 'flex', gap: '0.5rem' }}>
                        <button className="btn btn-success" onClick={() => handleUpdate(category._id)}>
                          Update
                        </button>
                        <button className="btn btn-warning" onClick={() => setEditingId(null)}>
                          Cancel
                        </button>
                      </div>
                    </td>
                  </>
                ) : (
                  <>
                    <td>{category.name}</td>
                    <td>{category.description}</td>
                    <td>
                      <div className="form-group" style={{ display: 'flex', gap: '0.5rem' }}>
                        <button className="btn btn-primary" onClick={() => handleEdit(category)}>
                          Edit
                        </button>
                        <button className="btn btn-danger" onClick={() => handleDelete(category._id)}>
                          Delete
                        </button>
                      </div>
                    </td>
                  </>
                )}
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </div>
  );
}

export default ViewCategories;