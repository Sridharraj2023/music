import { useState, useEffect, useRef } from 'react';
import axios from 'axios';
import '../admin.css';
import './ViewMusic.css';

function ViewMusic() {
  const [musicList, setMusicList] = useState([]);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [editingId, setEditingId] = useState(null);
  const [editTitle, setEditTitle] = useState('');
  const [editArtist, setEditArtist] = useState('');
  const [editThumbnail, setEditThumbnail] = useState(null);
  const [editAudio, setEditAudio] = useState(null);
  const [playingId, setPlayingId] = useState(null);
  const [currentTimes, setCurrentTimes] = useState({});
  const [durations, setDurations] = useState({});
  const audioRefs = useRef({});

  const fetchMusic = async () => {
    try {
      const token = localStorage.getItem('token');
      if (!token) {
        setError('Please log in to view music');
        return;
      }
      const res = await axios.get(`${import.meta.env.VITE_API_URL}/music`, {
        headers: { Authorization: `Bearer ${token}` },
        withCredentials: true,
      });
      
      setMusicList(res.data);
      setCurrentTimes(prev => ({
        ...prev,
        ...res.data.reduce((acc, music) => {
          if (!(music._id in prev)) acc[music._id] = 0;
          return acc;
        }, {})
      }));
      setDurations(prev => ({
        ...prev,
        ...res.data.reduce((acc, music) => {
          if (!(music._id in prev)) acc[music._id] = 0;
          return acc;
        }, {})
      }));
    } catch (err) {
      console.error('Fetch music error:', err);
      setError(err.response?.data?.message || 'Failed to fetch music. Please try again later.');
    }
  };

  useEffect(() => {
    fetchMusic();
  }, []);

  const handleDelete = async (id) => {
    if (!confirm('Are you sure you want to delete this music?')) return;
    try {
      const token = localStorage.getItem('token');
      await axios.delete(`${import.meta.env.VITE_API_URL}/music/${id}`, {
        headers: { Authorization: `Bearer ${token}` },
        withCredentials: true,
      });
      setMusicList(musicList.filter(music => music._id !== id));
      setSuccess('Music deleted successfully!');
      setTimeout(() => setSuccess(''), 3000);
    } catch (err) {
      setError(err.response?.data?.message || 'Failed to delete music');
    }
  };

  const handleEdit = (music) => {
    setEditingId(music._id);
    setEditTitle(music.title);
    setEditArtist(music.artist);
    setEditThumbnail(null);
    setEditAudio(null);
  };

  const handleUpdate = async (id) => {
    try {
      const token = localStorage.getItem('token');
      const formData = new FormData();
      
      formData.append('title', editTitle);
      formData.append('artist', editArtist);
      if (editThumbnail) formData.append('thumbnail', editThumbnail);
      if (editAudio) formData.append('audio', editAudio);

      await axios.put(
        `${import.meta.env.VITE_API_URL}/music/${id}`,
        formData,
        {
          headers: { 
            Authorization: `Bearer ${token}`,
            'Content-Type': 'multipart/form-data'
          },
          withCredentials: true,
        }
      );

      await fetchMusic();
      setEditingId(null);
      setEditThumbnail(null);
      setEditAudio(null);
      setSuccess('Music updated successfully!');
      setTimeout(() => setSuccess(''), 3000);
    } catch (err) {
      setError(err.response?.data?.message || 'Failed to update music');
    }
  };

  const togglePlayPause = (id) => {
    const audio = audioRefs.current[id];
    if (!audio) return;

    if (playingId === id) {
      audio.pause();
      setPlayingId(null);
    } else {
      if (playingId) {
        audioRefs.current[playingId].pause();
        setCurrentTimes(prev => ({ ...prev, [playingId]: audioRefs.current[playingId].currentTime }));
      }
      audio.play().catch(err => console.error('Playback error:', err));
      setPlayingId(id);
    }
  };

  const handleTimeUpdate = (id) => {
    const audio = audioRefs.current[id];
    if (audio) {
      setCurrentTimes(prev => ({ ...prev, [id]: audio.currentTime }));
    }
  };

  const handleLoadedMetadata = (id) => {
    const audio = audioRefs.current[id];
    if (audio && !isNaN(audio.duration) && audio.duration > 0) {
      setDurations(prev => ({ ...prev, [id]: audio.duration }));
    }
  };

  const formatTime = (time) => {
    if (!time || isNaN(time)) return '0:00';
    const minutes = Math.floor(time / 60);
    const seconds = Math.floor(time % 60);
    return `${minutes}:${seconds < 10 ? '0' : ''}${seconds}`;
  };

  const placeholderImage = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8DwHwAFBQIAjWjB1QAAAABJRU5ErkJggg==';

  return (
    <div className="view-music">
      <h2>View Music</h2>
      {error && <p className="error">{error}</p>}
      {success && <p className="success">{success}</p>}
      {musicList.length === 0 ? (
        <p>No music found.</p>
      ) : (
        <div className="music-card-container">
          {musicList.map(music => (
            <div key={music._id} className="music-card">
              {editingId === music._id ? (
                <div className="edit-form">
                  <div className="thumbnail-preview">
                    <img
                      src={
                        editThumbnail 
                          ? URL.createObjectURL(editThumbnail)
                          : music.thumbnailUrl || placeholderImage
                      }
                      alt="Thumbnail preview"
                      className="music-thumbnail"
                      onError={(e) => {
                        e.target.onerror = null;
                        e.target.src = placeholderImage;
                      }}
                    />
                  </div>
                  
                  <input
                    type="text"
                    value={editTitle}
                    onChange={(e) => setEditTitle(e.target.value)}
                    placeholder="Title"
                  />
                  
                  <input
                    type="text"
                    value={editArtist}
                    onChange={(e) => setEditArtist(e.target.value)}
                    placeholder="Artist"
                  />

                  <div className="file-inputs">
                    <div className="file-input-group">
                      <label>Update Thumbnail:</label>
                      <input
                        type="file"
                        accept="image/*"
                        onChange={(e) => setEditThumbnail(e.target.files[0])}
                      />
                    </div>
                    
                    <div className="file-input-group">
                      <label>Update Audio File:</label>
                      <input
                        type="file"
                        accept="audio/*"
                        onChange={(e) => setEditAudio(e.target.files[0])}
                      />
                      {music.fileUrl && !editAudio && (
                        <small>Current file: {music.fileUrl.split('/').pop()}</small>
                      )}
                    </div>
                  </div>

                  <div className="edit-buttons">
                    <button onClick={() => handleUpdate(music._id)}>Update</button>
                    <button onClick={() => {
                      setEditingId(null);
                      setEditThumbnail(null);
                      setEditAudio(null);
                    }}>
                      Cancel
                    </button>
                  </div>
                </div>
              ) : (
                <>
                  <img
                    src={music.thumbnailUrl || placeholderImage}
                    alt={music.title}
                    className="music-thumbnail"
                    onError={(e) => {
                      console.log('Thumbnail failed:', music.thumbnailUrl);
                      e.target.onerror = null;
                      e.target.src = placeholderImage;
                    }}
                  />
                  <h3>{music.title}</h3>
                  <p>Artist: {music.artist}</p>
                  <div className="custom-player">
                    <button
                      className="play-pause-btn"
                      onClick={() => togglePlayPause(music._id)}
                      disabled={!music.fileUrl}
                    >
                      {playingId === music._id ? '❚❚' : '▶'}
                    </button>
                    <span className="time-display">
                      {formatTime(currentTimes[music._id])} / {formatTime(durations[music._id])}
                    </span>
                    <input
                      type="range"
                      min="0"
                      max={durations[music._id] || 0}
                      value={currentTimes[music._id] || 0}
                      onChange={(e) => {
                        const audio = audioRefs.current[music._id];
                        if (audio) {
                          audio.currentTime = e.target.value;
                          setCurrentTimes(prev => ({ 
                            ...prev, 
                            [music._id]: parseFloat(e.target.value) 
                          }));
                        }
                      }}
                      className="progress-bar"
                      disabled={!music.fileUrl}
                    />
                    {music.fileUrl ? (
                      <audio
                        ref={(el) => (audioRefs.current[music._id] = el)}
                        onTimeUpdate={() => handleTimeUpdate(music._id)}
                        onLoadedMetadata={() => handleLoadedMetadata(music._id)}
                        onError={(e) => console.log('Audio failed:', music.fileUrl, e)}
                      >
                        <source src={music.fileUrl} type="audio/mpeg" />
                        Your browser does not support the audio element.
                      </audio>
                    ) : (
                      <p>Audio file not available</p>
                    )}
                  </div>
                  <div className="action-buttons">
                    <button onClick={() => handleEdit(music)}>Update</button>
                    <button onClick={() => handleDelete(music._id)}>Delete</button>
                  </div>
                </>
              )}
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

export default ViewMusic;