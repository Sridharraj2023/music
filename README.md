# Elevate Music Admin Dashboard

A modern React.js admin dashboard for managing the Elevate Music application, featuring professional toast notifications and comprehensive admin functionality.

## 🚀 Features

- **Modern UI/UX** - Clean, responsive design with professional styling
- **Toast Notifications** - React Toastify for professional user feedback
- **User Management** - Complete user administration system
- **Music Management** - Upload, edit, and manage music tracks
- **Category Management** - Organize music with categories and types
- **Subscription Plans** - Dynamic subscription plan management
- **Authentication** - Secure login/logout with JWT tokens
- **Responsive Design** - Works on desktop, tablet, and mobile

## 🛠️ Tech Stack

- **Frontend**: React.js 19, Vite
- **Routing**: React Router DOM
- **HTTP Client**: Axios
- **Notifications**: React Toastify
- **Icons**: React Icons
- **Styling**: CSS3 with modern features

## 📦 Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/elevate-music-admin.git
   cd elevate-music-admin
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Set up environment variables**
   ```bash
   # Create .env file
   echo "VITE_API_URL=https://your-backend-domain.com/api" > .env
   ```

4. **Start development server**
   ```bash
   npm run dev
   ```

## 🌐 Deployment

### Netlify Deployment

1. **Connect to Netlify**
   - Go to [Netlify](https://netlify.com)
   - Click "New site from Git"
   - Connect your GitHub repository

2. **Configure Build Settings**
   - **Base directory**: `/` (root)
   - **Build command**: `npm run build`
   - **Publish directory**: `dist`

3. **Set Environment Variables**
   - `VITE_API_URL`: `https://your-backend-domain.com/api`

4. **Deploy**
   - Click "Deploy site"
   - Your admin dashboard will be live!

### Manual Deployment

```bash
# Build for production
npm run build

# The dist folder contains your production files
# Upload the contents to your hosting provider
```

## 🔧 Configuration

### Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `VITE_API_URL` | Backend API URL | `https://api.elevate-music.com/api` |

### API Endpoints

The admin dashboard connects to these backend endpoints:

- **Authentication**: `/api/users/auth`, `/api/users/logout`
- **Users**: `/api/users`, `/api/users/profile`
- **Music**: `/api/music`, `/api/music/create`
- **Categories**: `/api/categories`
- **Subscription Plans**: `/api/subscription-plans`

## 📁 Project Structure

```
src/
├── admin/                 # Admin-specific components
│   ├── components/        # Admin layout components
│   └── pages/            # Admin pages (Dashboard, Users, Music, etc.)
├── components/           # Shared components
│   ├── Login.jsx         # Login page
│   ├── Signup.jsx        # Registration page
│   └── ProtectedRoute.jsx # Route protection
├── user/                 # User-specific components
├── utils/                # Utility functions
│   └── toast.js          # Toast notification service
├── App.jsx               # Main app component
└── main.jsx             # App entry point
```

## 🎨 Features Overview

### Admin Dashboard
- **Dashboard**: Overview of system statistics
- **User Management**: View, edit, delete users
- **Music Management**: Upload, edit, delete music tracks
- **Category Management**: Organize music with categories
- **Subscription Plans**: Manage pricing and features

### User Interface
- **Login/Signup**: Secure authentication
- **User Dashboard**: Basic user interface
- **Profile Management**: User profile settings

### Toast Notifications
- **Success Messages**: Green toast for successful operations
- **Error Messages**: Red toast for errors
- **Warning Messages**: Orange toast for warnings
- **Info Messages**: Blue toast for information
- **Auto-dismiss**: Configurable auto-close timing

## 🔒 Security

- JWT token authentication
- Protected routes for admin access
- Secure API communication
- Input validation and sanitization

## 🚀 Getting Started

1. **Start the development server**
   ```bash
   npm run dev
   ```

2. **Open your browser**
   - Navigate to `http://localhost:5173`

3. **Login as admin**
   - Use your admin credentials
   - Access the full admin dashboard

## 📝 Available Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run preview` - Preview production build
- `npm run lint` - Run ESLint
- `npm run deploy` - Build and prepare for deployment

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is proprietary software for the Elevate Music application.

## 🆘 Support

For support and questions:
- Check the deployment guide in `DEPLOYMENT.md`
- Review the build logs in Netlify
- Verify environment variables are set correctly
- Ensure your backend API is accessible

---

**Built with ❤️ for Elevate Music**