# Terms & Conditions - Flutter + Admin Implementation Plan

## 📋 Overview

**Goal:** Admin can update Terms & Conditions from the web admin panel, and users can view them in the Flutter mobile app.

**Flow:**
1. **Admin (Web)** → Creates/updates terms & conditions
2. **Backend API** → Stores and serves terms & conditions
3. **Flutter App** → Fetches and displays terms to users

---

## 🏗️ Architecture

### **1. Backend (Node.js/Express/MongoDB)**
- Store terms & conditions in database
- API endpoints for admin CRUD
- Public API to fetch active terms

### **2. Admin Panel (React Web)**
- Manage terms versions
- Rich text editor
- Publish/unpublish

### **3. Flutter App**
- View Terms & Conditions screen
- Fetch from API
- Display HTML content
- Link from settings/signup/login

---

## 📂 Implementation Plan

### **Phase 1: Backend API** (30 minutes)

#### **Step 1.1: Create Database Model**

**File:** `D:\Elevate-Backend\backend\models\TermsAndConditions.js`

```javascript
import mongoose from 'mongoose';

const termsAndConditionsSchema = mongoose.Schema(
  {
    title: {
      type: String,
      required: true,
      default: 'Terms and Conditions'
    },
    content: {
      type: String,
      required: true
    },
    version: {
      type: String,
      required: true,
      unique: true
    },
    isActive: {
      type: Boolean,
      default: false
    },
    publishedAt: {
      type: Date,
      default: null
    },
    publishedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true
    },
    effectiveDate: {
      type: Date,
      required: true,
      default: Date.now
    }
  },
  {
    timestamps: true
  }
);

// Ensure only one active version
termsAndConditionsSchema.index({ isActive: 1 });

const TermsAndConditions = mongoose.model('TermsAndConditions', termsAndConditionsSchema);

export default TermsAndConditions;
```

---

#### **Step 1.2: Create Controller**

**File:** `D:\Elevate-Backend\backend\controllers\termsController.js`

```javascript
import asyncHandler from 'express-async-handler';
import TermsAndConditions from '../models/TermsAndConditions.js';

// @desc    Get active terms (Public - for Flutter app)
// @route   GET /api/terms/active
// @access  Public
const getActiveTerms = asyncHandler(async (req, res) => {
  const terms = await TermsAndConditions.findOne({ isActive: true });
  
  if (!terms) {
    res.status(404);
    throw new Error('No active terms found');
  }
  
  res.json(terms);
});

// @desc    Get all terms versions (Admin only)
// @route   GET /api/terms/admin
// @access  Private/Admin
const getAllTermsVersions = asyncHandler(async (req, res) => {
  const terms = await TermsAndConditions.find()
    .populate('publishedBy', 'name email')
    .sort({ createdAt: -1 });
  res.json(terms);
});

// @desc    Create new terms version
// @route   POST /api/terms/admin
// @access  Private/Admin
const createTerms = asyncHandler(async (req, res) => {
  const { title, content, version, effectiveDate } = req.body;
  
  const versionExists = await TermsAndConditions.findOne({ version });
  if (versionExists) {
    res.status(400);
    throw new Error('Version already exists');
  }
  
  const terms = await TermsAndConditions.create({
    title,
    content,
    version,
    publishedBy: req.user._id,
    effectiveDate: effectiveDate || Date.now(),
    isActive: false
  });
  
  res.status(201).json(terms);
});

// @desc    Update terms version
// @route   PUT /api/terms/admin/:id
// @access  Private/Admin
const updateTerms = asyncHandler(async (req, res) => {
  const terms = await TermsAndConditions.findById(req.params.id);
  
  if (!terms) {
    res.status(404);
    throw new Error('Terms version not found');
  }
  
  if (terms.isActive) {
    res.status(400);
    throw new Error('Cannot edit active terms. Create a new version instead.');
  }
  
  terms.title = req.body.title || terms.title;
  terms.content = req.body.content || terms.content;
  terms.version = req.body.version || terms.version;
  terms.effectiveDate = req.body.effectiveDate || terms.effectiveDate;
  
  const updatedTerms = await terms.save();
  res.json(updatedTerms);
});

// @desc    Publish terms version
// @route   PUT /api/terms/admin/:id/publish
// @access  Private/Admin
const publishTerms = asyncHandler(async (req, res) => {
  const terms = await TermsAndConditions.findById(req.params.id);
  
  if (!terms) {
    res.status(404);
    throw new Error('Terms version not found');
  }
  
  // Deactivate all other versions
  await TermsAndConditions.updateMany(
    { isActive: true },
    { isActive: false }
  );
  
  // Activate this version
  terms.isActive = true;
  terms.publishedAt = Date.now();
  terms.publishedBy = req.user._id;
  
  const publishedTerms = await terms.save();
  res.json(publishedTerms);
});

// @desc    Unpublish terms version
// @route   PUT /api/terms/admin/:id/unpublish
// @access  Private/Admin
const unpublishTerms = asyncHandler(async (req, res) => {
  const terms = await TermsAndConditions.findById(req.params.id);
  
  if (!terms) {
    res.status(404);
    throw new Error('Terms version not found');
  }
  
  terms.isActive = false;
  const unpublishedTerms = await terms.save();
  res.json(unpublishedTerms);
});

// @desc    Delete terms version
// @route   DELETE /api/terms/admin/:id
// @access  Private/Admin
const deleteTerms = asyncHandler(async (req, res) => {
  const terms = await TermsAndConditions.findById(req.params.id);
  
  if (!terms) {
    res.status(404);
    throw new Error('Terms version not found');
  }
  
  if (terms.isActive) {
    res.status(400);
    throw new Error('Cannot delete active terms version');
  }
  
  await TermsAndConditions.findByIdAndDelete(req.params.id);
  res.json({ message: 'Terms version deleted successfully' });
});

export {
  getActiveTerms,
  getAllTermsVersions,
  createTerms,
  updateTerms,
  publishTerms,
  unpublishTerms,
  deleteTerms
};
```

---

#### **Step 1.3: Create Routes**

**File:** `D:\Elevate-Backend\backend\routes\termsRoutes.js`

```javascript
import express from 'express';
import {
  getActiveTerms,
  getAllTermsVersions,
  createTerms,
  updateTerms,
  publishTerms,
  unpublishTerms,
  deleteTerms
} from '../controllers/termsController.js';
import { protect } from '../middleware/authMiddleware.js';
import { adminOnly } from '../middleware/adminMiddleware.js';

const router = express.Router();

// Public route (for Flutter app)
router.get('/active', getActiveTerms);

// Admin routes (for web admin panel)
router.get('/admin', protect, adminOnly, getAllTermsVersions);
router.post('/admin', protect, adminOnly, createTerms);
router.put('/admin/:id', protect, adminOnly, updateTerms);
router.put('/admin/:id/publish', protect, adminOnly, publishTerms);
router.put('/admin/:id/unpublish', protect, adminOnly, unpublishTerms);
router.delete('/admin/:id', protect, adminOnly, deleteTerms);

export default router;
```

---

#### **Step 1.4: Register Routes in Server**

**File:** `D:\Elevate-Backend\backend\server.js`

Add import:
```javascript
import termsRoutes from './routes/termsRoutes.js';
```

Add route:
```javascript
app.use('/api/terms', termsRoutes);
```

---

### **Phase 2: Admin Panel (React)** (45 minutes)

**Create:** `D:\Elevate admin front-end\frontend\src\admin\pages\ManageTermsConditions.jsx`

*(See full implementation in TERMS_CONDITIONS_IMPLEMENTATION_PLAN.md)*

**Key Features:**
- ✅ Create/Edit terms
- ✅ HTML editor
- ✅ Preview
- ✅ Publish/Unpublish
- ✅ Version control

---

### **Phase 3: Flutter App** (30 minutes)

#### **Step 3.1: Create Terms Screen**

**File:** `lib/View/Screens/TermsConditions_Screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../utlis/api_constants.dart';
import '../Widgets/Gradient_Container.dart';

class TermsConditionsScreen extends StatefulWidget {
  const TermsConditionsScreen({Key? key}) : super(key: key);

  @override
  State<TermsConditionsScreen> createState() => _TermsConditionsScreenState();
}

class _TermsConditionsScreenState extends State<TermsConditionsScreen> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _terms;

  @override
  void initState() {
    super.initState();
    _fetchTerms();
  }

  Future<void> _fetchTerms() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await http.get(
        Uri.parse('${ApiConstants.resolvedApiUrl}/terms/active'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _terms = data;
          _isLoading = false;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _error = 'No terms and conditions available at this time.';
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load terms and conditions');
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading terms: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: GradientContainer(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        'Terms & Conditions',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(screenWidth * 0.04),
                  padding: EdgeInsets.all(screenWidth * 0.05),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: _buildContent(screenWidth),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(double screenWidth) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: screenWidth * 0.15,
              color: Colors.red,
            ),
            SizedBox(height: screenWidth * 0.04),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: screenWidth * 0.04),
            ElevatedButton(
              onPressed: _fetchTerms,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    if (_terms == null) {
      return const Center(
        child: Text('No terms available'),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            _terms!['title'] ?? 'Terms and Conditions',
            style: TextStyle(
              fontSize: screenWidth * 0.06,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          
          SizedBox(height: screenWidth * 0.02),

          // Version and Date Info
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.03,
              vertical: screenWidth * 0.02,
            ),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline,
                  size: screenWidth * 0.04,
                  color: Colors.black54,
                ),
                SizedBox(width: screenWidth * 0.02),
                Text(
                  'Version ${_terms!['version']} • Effective ${_formatDate(_terms!['effectiveDate'])}',
                  style: TextStyle(
                    fontSize: screenWidth * 0.032,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: screenWidth * 0.06),

          // HTML Content
          Html(
            data: _terms!['content'] ?? '',
            style: {
              "body": Style(
                fontSize: FontSize(screenWidth * 0.04),
                lineHeight: const LineHeight(1.6),
                color: Colors.black87,
              ),
              "h1": Style(
                fontSize: FontSize(screenWidth * 0.055),
                fontWeight: FontWeight.bold,
                color: Colors.black,
                margin: Margins.only(top: 16, bottom: 8),
              ),
              "h2": Style(
                fontSize: FontSize(screenWidth * 0.05),
                fontWeight: FontWeight.bold,
                color: Colors.black,
                margin: Margins.only(top: 14, bottom: 7),
              ),
              "h3": Style(
                fontSize: FontSize(screenWidth * 0.045),
                fontWeight: FontWeight.bold,
                color: Colors.black,
                margin: Margins.only(top: 12, bottom: 6),
              ),
              "p": Style(
                fontSize: FontSize(screenWidth * 0.04),
                margin: Margins.only(bottom: 12),
              ),
              "ul": Style(
                margin: Margins.only(left: 20, bottom: 12),
              ),
              "ol": Style(
                margin: Margins.only(left: 20, bottom: 12),
              ),
              "li": Style(
                margin: Margins.only(bottom: 6),
              ),
            },
          ),

          SizedBox(height: screenWidth * 0.04),

          // Last Updated
          Center(
            child: Text(
              'Last updated: ${_formatDate(_terms!['updatedAt'])}',
              style: TextStyle(
                fontSize: screenWidth * 0.03,
                color: Colors.black38,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

          SizedBox(height: screenWidth * 0.04),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }
}
```

---

#### **Step 3.2: Add Flutter HTML Package**

**File:** `pubspec.yaml`

Add dependency:
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_html: ^3.0.0-beta.2  # Add this line
  # ... other dependencies
```

Run:
```bash
flutter pub get
```

---

#### **Step 3.3: Add Navigation Links**

**Option 1: From Login Screen**

**File:** `lib/View/Screens/Login_Screen.dart`

Add below the login button:
```dart
SizedBox(height: screenHeight * 0.02),

// Terms & Conditions Link
TextButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TermsConditionsScreen(),
      ),
    );
  },
  child: Text(
    "Terms & Conditions",
    style: TextStyle(
      color: Colors.white.withOpacity(0.8),
      fontSize: screenWidth * 0.03,
      decoration: TextDecoration.underline,
    ),
  ),
),
```

**Option 2: From Signup Screen**

**File:** `lib/View/Screens/Signup_Screen.dart`

Add before the signup button:
```dart
// Agree to Terms Checkbox
Row(
  children: [
    Checkbox(
      value: _agreeToTerms,
      onChanged: (value) {
        setState(() {
          _agreeToTerms = value ?? false;
        });
      },
      activeColor: Colors.black,
      checkColor: Colors.white,
    ),
    Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TermsConditionsScreen(),
            ),
          );
        },
        child: Text(
          "I agree to the Terms & Conditions",
          style: TextStyle(
            color: Colors.white,
            fontSize: screenWidth * 0.035,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    ),
  ],
),
```

**Option 3: From Settings/Profile**

Create a settings screen or add to profile:
```dart
ListTile(
  leading: const Icon(Icons.description),
  title: const Text('Terms & Conditions'),
  trailing: const Icon(Icons.arrow_forward_ios),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TermsConditionsScreen(),
      ),
    );
  },
),
```

---

## 🧪 Testing Checklist

### **Backend:**
- [ ] Create terms via admin API
- [ ] Update terms via admin API
- [ ] Publish terms
- [ ] Fetch active terms (public API)
- [ ] Only one active version at a time

### **Admin Panel:**
- [ ] Create new terms version
- [ ] Edit draft version
- [ ] Preview terms
- [ ] Publish terms
- [ ] Unpublish terms
- [ ] Delete draft version

### **Flutter App:**
- [ ] Fetch and display terms
- [ ] HTML content renders properly
- [ ] Show version and date
- [ ] Handle no terms available
- [ ] Handle network errors
- [ ] Refresh functionality
- [ ] Navigation works

---

## 📊 Data Flow

```
┌─────────────────┐
│  Admin Panel    │
│  (React Web)    │
└────────┬────────┘
         │ Create/Update
         │ Publish
         ▼
┌─────────────────┐
│  Backend API    │
│  (Node.js)      │
└────────┬────────┘
         │ GET /api/terms/active
         ▼
┌─────────────────┐
│  Flutter App    │
│  (Mobile)       │
└─────────────────┘
```

---

## 🎯 Features Summary

### **Admin (Web) Can:**
- ✅ Create multiple versions
- ✅ Edit HTML content
- ✅ Preview before publishing
- ✅ Publish to make active
- ✅ Track version history

### **Users (Flutter) Can:**
- ✅ View current terms
- ✅ See version info
- ✅ Read formatted HTML
- ✅ Access from login/signup/settings

### **Backend Provides:**
- ✅ Public API for active terms
- ✅ Admin API for management
- ✅ Version control
- ✅ Only one active version

---

## 🚀 Implementation Timeline

| Phase | Task | Time |
|-------|------|------|
| **Phase 1** | Backend API | 30 min |
| **Phase 2** | Admin Panel | 45 min |
| **Phase 3** | Flutter App | 30 min |
| **Testing** | Full flow | 15 min |
| **Total** | | **2 hours** |

---

## 📝 Important Notes

1. **HTML Support:** Admin can use HTML for formatting (bold, italic, lists, headers)
2. **Version Control:** Only one version can be active at a time
3. **Public API:** `/api/terms/active` is public - no auth required
4. **Admin API:** All admin endpoints require authentication
5. **Flutter Package:** Uses `flutter_html` to render HTML content

---

## 🎨 UI/UX

### **Flutter Screen:**
- White content area on gradient background
- Back button
- Title and version info badge
- Scrollable HTML content
- Professional formatting
- Last updated timestamp

### **Admin Panel:**
- Rich text editor
- Preview functionality
- Version management
- Publish/Unpublish buttons

---

Ready to implement? I'll start with the backend! 🚀

