# Netlify Deployment Guide

## 🚀 Deploy React Admin Frontend to Netlify

### Prerequisites
- GitHub repository with the code
- Netlify account
- Backend API deployed and accessible

### Step 1: Prepare Your Backend
1. Deploy your backend API to a hosting service (Render, Heroku, AWS, etc.)
2. Note down your backend URL (e.g., `https://your-backend.herokuapp.com`)

### Step 2: Configure Environment Variables
1. Update the `VITE_API_URL` in `netlify.toml` with your actual backend URL
2. Or set it in Netlify's environment variables section

### Step 3: Deploy to Netlify

#### Option A: Connect GitHub Repository
1. Go to [Netlify](https://netlify.com)
2. Click "New site from Git"
3. Choose "GitHub" and select your repository
4. Set build settings:
   - **Base directory**: `music/frontend`
   - **Build command**: `npm run build`
   - **Publish directory**: `music/frontend/dist`
5. Add environment variable:
   - **Key**: `VITE_API_URL`
   - **Value**: `https://your-backend-domain.com/api`
6. Click "Deploy site"

#### Option B: Manual Deploy
1. Build the project locally:
   ```bash
   cd music/frontend
   npm install
   npm run build
   ```
2. Drag and drop the `dist` folder to Netlify

### Step 4: Configure Custom Domain (Optional)
1. In Netlify dashboard, go to "Domain settings"
2. Add your custom domain
3. Configure DNS settings as instructed

### Step 5: Environment Variables in Netlify
1. Go to Site settings > Environment variables
2. Add:
   - `VITE_API_URL`: `https://your-backend-domain.com/api`

### Troubleshooting

#### Build Fails
- Check Node.js version (should be 18+)
- Ensure all dependencies are in `package.json`
- Check for TypeScript errors

#### API Calls Fail
- Verify `VITE_API_URL` is correct
- Check CORS settings on your backend
- Ensure backend is accessible from Netlify

#### Routing Issues
- The `_redirects` file should handle SPA routing
- Check that `netlify.toml` redirects are configured

### Production Checklist
- [ ] Backend API is deployed and accessible
- [ ] Environment variables are set correctly
- [ ] CORS is configured on backend
- [ ] SSL certificates are working
- [ ] Custom domain is configured (if needed)

### Support
If you encounter issues:
1. Check Netlify build logs
2. Verify environment variables
3. Test API endpoints manually
4. Check browser console for errors
