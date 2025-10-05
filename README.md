# 🚀 AstroLens

**Your AI-Powered Space Research Companion**

AstroLens is a modern Flutter application that makes space biology research accessible to everyone. Browse curated research papers, get AI-powered summaries, and chat with an intelligent research assistant that helps you understand complex space science topics.

## 🌐 Live Demo

**Web App**: [astrolens.pages.web](https://astrolens.pages.web)  
**API Documentation**: [astrolens.mohamedayman.org](https://astrolens.mohamedayman.org)

---

## ✨ Features

### 📱 Flutter Mobile & Web App
- **Modern Space-Themed UI** - Beautiful cosmic color scheme with dark mode
- **Research Paper Browser** - Explore curated space biology research papers
- **Advanced Search** - Search by title, summary, or keywords
- **Paper Details** - Comprehensive paper information with external links
- **AI Research Assistant** - Chat interface powered by Google's Generative AI
- **Cross-Platform** - Works on Android, iOS, Web, Windows, and macOS

### 🤖 AI-Powered Chat Assistant
- **Conversational Interface** - Natural language queries about space research
- **Intelligent Responses** - AI generates contextual answers based on research papers
- **Paper Recommendations** - Get direct links to relevant research papers
- **Real-time Processing** - Instant responses from deployed API

### 🛠️ FastAPI Backend
- **Paper Summarization** - AI-powered research paper analysis
- **Chat Endpoint** - Intelligent query processing with paper matching
- **CORS Enabled** - Ready for web application integration
- **Auto-generated Documentation** - Interactive API docs at `/docs`
<!-- 
---

## 🎨 Design & Theme

AstroLens features a modern space-inspired design:

- **Primary**: Cosmic Blue (#00D4FF) - Vibrant cyan-blue
- **Secondary**: Electric Purple (#7C4DFF) - Modern purple accent
- **Tertiary**: Emerald Teal (#00BFA5) - Sophisticated teal
- **Background**: Midnight Black (#0F1419) - Deep space background
- **Typography**: Inter and Orbitron fonts for modern, readable text -->

---

## 🏗️ Project Structure

```
astrolens/
├── lib/                          # Flutter application code
│   ├── main.dart                # App entry point and theme configuration
│   ├── models/                  # Data models
│   │   ├── research_paper.dart  # Research paper model
│   │   └── chat_message.dart    # Chat message model
│   ├── pages/                   # Application screens
│   │   ├── home_page.dart       # Main research papers browser
│   │   ├── paper_detail_page.dart # Individual paper details
│   │   └── chat_page.dart       # AI chat interface
│   └── services/               # Business logic
│       └── paper_service.dart   # Paper data management
├── api/                         # FastAPI backend
│   ├── main.py                 # API server with AI integration
│   ├── requirements.txt        # Python dependencies
│   └── README.md              # API documentation
├── assets/                     # App assets
│   ├── papers.json            # Research papers database
│   └── logo.png               # App logo
├── test/                      # Unit and widget tests
└── pubspec.yaml              # Flutter dependencies
```

---

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK** 3.9.2 or higher
- **Python** 3.8+ (for API development)
- **Google API Key** (for AI features)

### 📱 Flutter App Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/MAyman007/AstroLens.git
   cd astrolens
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # For development
   flutter run
   
   # For web
   flutter run -d chrome
   
   # For specific platform
   flutter run -d windows  # or macos, linux
   ```

### 🔧 API Setup (Optional)

The app uses the deployed API by default, but you can run it locally:

1. **Navigate to API directory**
   ```bash
   cd api
   ```

2. **Install Python dependencies**
   ```bash
   pip install -r requirements.txt
   ```

3. **Set environment variables**
   ```bash
   export GOOGLE_API_KEY="your_google_api_key_here"
   export NCBI_API_KEY="your_ncbi_api_key_here"  # Optional
   ```

4. **Run the API server**
   ```bash
   python main.py
   # API available at http://localhost:9000
   ```

---

## 🧠 AI Integration

### Google Generative AI
- **Model**: Gemini 2.0 Flash Experimental
- **Features**: Conversational responses, paper summarization
- **Prompting**: Specialized prompts for space biology research

### Chat Assistant Capabilities
- **Paper Matching**: Advanced similarity matching using `difflib.SequenceMatcher`
- **Contextual Responses**: AI generates relevant answers based on research content
- **Link Integration**: Provides direct access to full research papers
- **Error Handling**: Graceful fallbacks for API failures

---

## 📊 Research Paper Database

The app includes 608 curated research papers covering a wide range of space biology topics, for example:

1. **Animal Studies** - Mouse experiments in space missions
2. **Bone Health** - Microgravity effects on bone density and cellular processes
3. **Stem Cell Research** - Tissue regeneration in space environments
4. **Gene Expression** - RNA analysis and genetic studies on the ISS
5. **Space Biology** - Various aspects of life sciences in microgravity

Each paper includes:
- Full title and summary
- Direct links to PMC articles
- Relevant keywords for searching
- AI-generated simplified explanations

---

## 🔗 API Endpoints

### Chat Assistant
```http
GET /chat?message={query}
```
**Response**:
```json
{
  "response": "AI-generated conversational response...",
  "link": "https://pmc.ncbi.nlm.nih.gov/articles/PMC..."
}
```

### Paper Summarization
```http
POST /summarize
GET /summarize-get?url={paper_url}
```

### Health Check
```http
GET /health
```

---

## 📱 Supported Platforms

- ✅ **Android** - Native mobile experience
- ✅ **Web** - Responsive web application
- ✅ **Windows** - Desktop application
- ✅ **Linux** - Desktop application

---

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run specific test files
flutter test test/models/research_paper_test.dart
flutter test test/services/paper_service_test.dart
```

---

## 🚀 Deployment

### Releases
Platform-specific builds (mobile and desktop) are provided on the project's GitHub Releases page. Look for the latest release to download:
- Mobile
  - Android: APK / AAB packages
- Desktop
  - Windows: MSI / EXE build
  - Linux: AppImage / DEB / RPM (when provided)

Visit the Releases page for binaries and installation instructions:
https://github.com/MAyman007/AstroLens/releases

### Web Deployment
The app is deployed at [astrolens.pages.web](https://astrolens.pages.web) using Flutter Web.

### API Deployment
The backend API is deployed at [astrolens.mohamedayman.org](https://astrolens.mohamedayman.org) with full CORS support.

## 🛠️ Dependencies

### Flutter Dependencies
- **google_fonts** ^6.1.0 - Modern typography (Inter & Orbitron)
- **url_launcher** ^6.2.2 - External link handling
- **http** ^1.1.0 - API communication
- **cupertino_icons** ^1.0.8 - iOS-style icons

### API Dependencies
- **FastAPI** - Modern Python web framework
- **Google Generative AI** - AI-powered responses
- **BeautifulSoup** - HTML parsing for paper content
- **Uvicorn** - ASGI server

## 👥 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

<!-- ## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

--- -->

## 🙏 Acknowledgments

- **NASA** and **PMC** for providing access to space research papers
- **Google** for Generative AI capabilities
- **Flutter** team for the amazing cross-platform framework
- **FastAPI** for the modern Python web framework

<!-- ---

## 📧 Contact

**Mohamed Ayman** - [GitHub](https://github.com/MAyman007)

**Project Link**: [https://github.com/MAyman007/AstroLens](https://github.com/MAyman007/AstroLens) -->

<!-- ---

<div align="center">

**Made with ❤️ for space enthusiasts and researchers worldwide**

⭐ Star this repository if you find it helpful!

</div> -->
