import { useState } from 'react';
import axios from 'axios';
import { useNavigate } from 'react-router-dom';
import '../admin.css';

function AddCategory() {
  const [name, setName] = useState('');
  const [description, setDescription] = useState('');
  const [types, setTypes] = useState([{ name: '', description: '' }]); // Array for category types
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const navigate = useNavigate();

  // Handle changes to category type fields
  const handleTypeChange = (index, field, value) => {
    const updatedTypes = [...types];
    updatedTypes[index][field] = value;
    setTypes(updatedTypes);
  };

  // Add a new type input
  const addType = () => {
    setTypes([...types, { name: '', description: '' }]);
  };

  // Remove a type input
  const removeType = (index) => {
    if (types.length > 1) {
      setTypes(types.filter((_, i) => i !== index));
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setSuccess('');

    // Validate that all types have names
    const invalidTypes = types.some(type => !type.name.trim());
    if (!name.trim() || invalidTypes) {
      setError('Category name and all type names are required');
      return;
    }

    try {
      const token = localStorage.getItem('token');
      const res = await axios.post(
        `${import.meta.env.VITE_API_URL}/categories/create`,
        { 
          name, 
          description, 
          types: types.filter(type => type.name.trim()) // Only send types with names
        },
        {
          headers: { Authorization: `Bearer ${token}` },
          withCredentials: true,
        }
      );

      setSuccess('Category added successfully!');
      setName('');
      setDescription('');
      setTypes([{ name: '', description: '' }]); // Reset to one empty type
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
          <label className="form-label">Category Name:</label>
          <input
            className="form-control"
            type="text"
            value={name}
            onChange={(e) => setName(e.target.value)}
            required
          />
        </div>
        
        <div className="form-group">
          <label className="form-label">Category Description:</label>
          <textarea
            className="form-control"
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            rows="4"
          />
        </div>

        <div className="form-group">
          <label className="form-label">Category Types:</label>
          {types.map((type, index) => (
            <div key={index} className="type-input-group" style={{ marginBottom: '15px' }}>
              <input
                className="form-control"
                type="text"
                value={type.name}
                onChange={(e) => handleTypeChange(index, 'name', e.target.value)}
                placeholder="Type Name"
                required
                style={{ marginBottom: '5px' }}
              />
              <textarea
                className="form-control"
                value={type.description}
                onChange={(e) => handleTypeChange(index, 'description', e.target.value)}
                placeholder="Type Description"
                rows="2"
              />
              {types.length > 1 && (
                <button
                  type="button"
                  className="btn btn-danger"
                  onClick={() => removeType(index)}
                  style={{ marginTop: '5px' }}
                >
                  Remove Type
                </button>
              )}
            </div>
          ))}
          <button
            type="button"
            className="btn btn-secondary"
            onClick={addType}
            style={{ marginTop: '10px' }}
          >
            Add Another Type
          </button>
        </div>
        
        <button type="submit" className="btn btn-primary">
          Add Category
        </button>
      </form>
    </div>
  );
}

export default AddCategory;