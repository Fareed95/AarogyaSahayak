<div align="center">

<img src="client/assets/logo.png" alt="AarogyaSahayak Logo" width="120" />

# 🏥 AarogyaSahayak

### *Your AI-Powered Personal Health Companion*

> **Aarogya** (आरोग्य) — *Health* · **Sahayak** (सहायक) — *Assistant*

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev)
[![Django](https://img.shields.io/badge/Django-4.2-092E20?style=flat-square&logo=django&logoColor=white)](https://djangoproject.com)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.117-009688?style=flat-square&logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com)
[![Groq](https://img.shields.io/badge/Groq-Llama%203.1-F55036?style=flat-square)](https://groq.com)
[![Firebase](https://img.shields.io/badge/Firebase-Messaging-FFCA28?style=flat-square&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?style=flat-square&logo=docker&logoColor=white)](https://docker.com)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Supabase-336791?style=flat-square&logo=postgresql&logoColor=white)](https://supabase.com)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)

</div>

---

## 📖 Table of Contents

- [Overview](#-overview)
- [Key Features](#-key-features)
- [Architecture](#-architecture)
- [Tech Stack](#-tech-stack)
- [Project Structure](#-project-structure)
- [Getting Started](#-getting-started)
  - [Prerequisites](#prerequisites)
  - [Backend (Django)](#backend-django)
  - [AI Microservices (FastAPI)](#ai-microservices-fastapi)
  - [Mobile App (Flutter)](#mobile-app-flutter)
  - [Docker Setup](#docker-setup)
- [API Reference](#-api-reference)
- [Environment Variables](#-environment-variables)
- [Developer](#-developer)
- [Contributing](#-contributing)

---

## 🌟 Overview

**AarogyaSahayak** is a full-stack, AI-powered personal health companion designed specifically for India. It bridges the healthcare accessibility gap by combining cutting-edge AI with a seamless mobile experience — empowering patients, doctors, and community health workers.

From **AI-driven medical report analysis** to **real-time voice consultations with a virtual doctor**, barcode-based **food nutrition analysis**, and **ASHA worker connectivity**, AarogyaSahayak brings a holistic healthcare ecosystem to every smartphone.

---

## ✨ Key Features

### 🤖 AI-Powered Medical Report Analysis
- Upload medical reports (PDF/images) and get instant AI-generated summaries
- Extracts key clinical details (diagnosis, doctor name, hospital) using LangChain agents + GPT-4o-mini
- Auto-generates curated YouTube educational videos relevant to the detected condition
- QR code generation for easy report sharing

### 🎙️ Voice & Chat AI Assistant ("Dr. Sarah")
- **Real-time voice calling** — speak to an AI medical assistant via WebSockets
- **Voice chat** — record audio, get transcription via Groq Whisper, and receive spoken AI responses via gTTS
- **Text chat** — interactive text-based AI health Q&A
- **OCR chat** — upload prescriptions or lab reports; AI reads and explains them
- **Document chatbot** — upload any medical PDF and chat with it (RAG pipeline)

### 🍽️ Nutrition & Diet Analyzer
- Scan any food product barcode to fetch its nutritional data via the **Open Food Facts API**
- Analyzes nutrients against diabetic-specific recommended daily values
- Classifies food as healthy/unhealthy with detailed reasons
- Nutrient breakdown: sugar, carbs, fat, protein, fiber, cholesterol, sodium, vitamins, and more

### 🧘 Yoga Pose Analysis
- Camera-based yoga pose recognition using computer vision
- Real-time feedback on pose correctness

### 🏥 Doctor & Hospital Finder
- **Google Maps integration** to locate nearby hospitals and clinics
- Doctor profiles with specialization and contact details
- ASHA (Accredited Social Health Activist) worker directory with real-time availability

### 💊 Medicine Tracker
- Add medicines with descriptions, manufacturer, and expiry dates
- Schedule and track multiple doses per medicine
- Push notification reminders via **Firebase Cloud Messaging (FCM)**

### 👤 Authentication & Security
- JWT-based authentication with token refresh
- OTP verification via email (SMTP)
- Aadhar number integration
- Role-based access: Patient, Doctor, Medical Store
- Audit logging (login, logout, password reset) with IP tracking
- Secure token storage on device (flutter_secure_storage)

### 📺 Health Education Videos
- Curated YouTube videos on nutrition, wellness, and specific conditions
- Category-based browsing with an in-app YouTube player

### 💬 Community Health
- Community home screen connecting patients with local health workers

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Flutter Mobile App                    │
│          (Android / iOS / Web — cross-platform)          │
└──────────────┬──────────────────────────┬───────────────┘
               │  REST API (JWT)           │  WebSocket
               ▼                          ▼
┌──────────────────────┐    ┌─────────────────────────────┐
│   Django REST API    │    │   FastAPI AI Microservices   │
│   (Main Backend)     │    │                             │
│                      │    │  • ai_assistant  (port 8080) │
│  • authentication    │    │    - OCR + LLM chat          │
│  • userDeets         │    │    - Voice → Text → Voice    │
│  • reports           │    │    - Document RAG            │
│  • diet              │    │                             │
│                      │    │  • calling_agent (port 1000) │
│   PostgreSQL         │    │    - Dr. Sarah voice calls   │
│   (Supabase)         │    │    - WebSocket sessions      │
└──────────┬───────────┘    └─────────────────────────────┘
           │
    ┌──────┴──────┐
    │  Firebase   │
    │  (FCM Push  │
    │ Notifs)     │
    └─────────────┘
```

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| **Mobile Frontend** | Flutter 3.x (Dart), Google Fonts, Camera, Audio Recording |
| **Maps & Location** | Google Maps Flutter, Geolocator, Google Places API |
| **Backend API** | Django 4.2, Django REST Framework, SimpleJWT |
| **AI Microservices** | FastAPI, Uvicorn, WebSockets |
| **LLM / AI** | Groq (Llama 3.1-8B-Instant, Whisper-Large-v3), OpenAI GPT-4o-mini |
| **AI Framework** | LangChain, LangGraph, LangChain-Groq |
| **OCR** | Tesseract (pytesseract), PyMuPDF, Pillow |
| **Text-to-Speech** | gTTS (Google Text-to-Speech) |
| **Speech-to-Text** | Groq Whisper (primary), SpeechRecognition (fallback) |
| **Database** | PostgreSQL via Supabase |
| **Notifications** | Firebase Cloud Messaging (FCM), firebase_messaging |
| **Auth** | JWT (rest_framework_simplejwt), flutter_secure_storage |
| **Food Data** | Open Food Facts API |
| **Containerization** | Docker, Docker Compose |
| **Production Server** | Gunicorn + WhiteNoise (static files) |
| **Deployment** | Render (`codenebula-internal-round-25.onrender.com`) |

---

## 📁 Project Structure

```
AarogyaSahayak/
│
├── client/                          # Flutter mobile application
│   ├── lib/
│   │   ├── main.dart                # App entry point, Firebase init, auth check
│   │   ├── layout.dart              # Bottom navigation & app shell
│   │   ├── screens/
│   │   │   ├── home_screen.dart     # Dashboard, ASHA workers, features
│   │   │   ├── ChatBot_Screen.dart  # AI text + document chatbot
│   │   │   ├── voice_agent.dart     # Voice/audio AI assistant
│   │   │   ├── Doctor_screen.dart   # Doctor listings & profiles
│   │   │   ├── FindHospital_screen.dart  # Google Maps hospital finder
│   │   │   ├── Medical_screen.dart  # Medicine tracker
│   │   │   ├── nutrition.dart       # Nutrition & diet videos
│   │   │   ├── report_instance_screen.dart  # Medical report upload/view
│   │   │   ├── YogaPoseAnalysisScreen.dart  # Yoga pose CV analysis
│   │   │   ├── profile_screen.dart  # User profile management
│   │   │   ├── login_screen.dart    # Login
│   │   │   ├── register_screen.dart # Registration
│   │   │   ├── otp_screen.dart      # OTP verification
│   │   │   └── ...
│   │   ├── services/
│   │   │   ├── secure_storage_service.dart  # JWT secure storage
│   │   │   └── info.dart            # API base URL config
│   │   ├── theme/
│   │   │   └── app_theme.dart       # Light/dark theme config
│   │   └── component/               # Reusable UI components
│   ├── assets/                      # Logo, images
│   └── pubspec.yaml                 # Flutter dependencies
│
├── server/                          # Django REST API backend
│   ├── server/
│   │   ├── settings.py              # Django config, DB, JWT, email
│   │   └── urls.py                  # Root URL routing
│   ├── authentication/              # User auth, OTP, JWT, audit logs
│   │   ├── models.py                # User model (email-based, roles)
│   │   ├── views/                   # Login, register, OTP, FCM
│   │   └── utils.py                 # Email OTP helpers
│   ├── userDeets/                   # User profile, medicines, doses
│   │   └── models.py                # UserDeets, Medicine, Dose
│   ├── reports/                     # Medical report analysis
│   │   ├── agents/
│   │   │   ├── extracting_basic_details.py   # LangChain: extract metadata
│   │   │   ├── extracting_json_details.py    # LangChain: structured JSON
│   │   │   ├── overal_summary.py             # GPT-4o-mini final summary
│   │   │   ├── yoga_prompt.py                # Yoga analysis prompt
│   │   │   └── youtube_scrapping.py          # YouTube video suggestions
│   │   └── models.py                # Report, ReportInstance, ChatBot
│   ├── diet/                        # Barcode food analysis
│   │   ├── diet.py                  # Open Food Facts + nutrient analysis
│   │   ├── scanning.py              # Barcode scanning logic
│   │   └── normal_data.json         # Recommended nutrient values
│   ├── requirements.txt             # Python dependencies
│   └── Dockerfile                   # Django Docker image
│
├── models/                          # FastAPI AI microservices
│   ├── ai_assistant/
│   │   └── app.py                   # OCR, voice, text chat endpoints
│   └── calling_agent/
│       ├── main.py                  # Dr. Sarah voice call service
│       ├── database.py              # Session database
│       └── crud.py                  # Session CRUD operations
│
├── app.py                           # Standalone FastAPI AI service
├── docker-compose.yml               # Multi-service orchestration
└── requirements.txt                 # Root AI service dependencies
```

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (≥ 3.x)
- [Python](https://www.python.org/downloads/) 3.11+
- [Docker & Docker Compose](https://docs.docker.com/get-docker/)
- [PostgreSQL](https://www.postgresql.org/) (or a [Supabase](https://supabase.com) project)
- [Tesseract OCR](https://github.com/tesseract-ocr/tesseract)
- API Keys: [Groq](https://console.groq.com), [OpenAI](https://platform.openai.com), [Google Maps](https://console.cloud.google.com)
- [Firebase project](https://console.firebase.google.com) with FCM enabled

---

### Backend (Django)

```bash
# 1. Navigate to server directory
cd server

# 2. Create and activate virtual environment
python -m venv venv
source venv/bin/activate   # Windows: venv\Scripts\activate

# 3. Install dependencies
pip install -r requirements.txt

# 4. Create .env file (see Environment Variables section)
cp .env.example .env
# Fill in your values

# 5. Run database migrations
python manage.py migrate

# 6. Create superuser (optional)
python manage.py createsuperuser

# 7. Start development server
python manage.py runserver 0.0.0.0:8000
```

The Django API will be available at `http://localhost:8000`.

---

### AI Microservices (FastAPI)

**AI Assistant Service:**

```bash
# From repo root
pip install -r requirements.txt

# Create .env with GROQ_API_KEY
echo "GROQ_API_KEY=your_key_here" > .env

# Start the AI assistant service
uvicorn app:app --host 0.0.0.0 --port 8080 --reload
```

**Voice Calling Agent (Dr. Sarah):**

```bash
cd models/calling_agent

# Start on port 1000
uvicorn main:app --host 0.0.0.0 --port 1000 --reload
```

---

### Mobile App (Flutter)

```bash
# 1. Navigate to client directory
cd client

# 2. Install Flutter dependencies
flutter pub get

# 3. Configure API base URL
# Edit lib/services/info.dart → update the server IP/URL

# 4. Add Firebase config
# Place google-services.json in android/app/
# Place GoogleService-Info.plist in ios/Runner/

# 5. Run on device or emulator
flutter run
```

---

### Docker Setup

Run the full backend stack with Docker Compose:

```bash
# From repo root
docker-compose up --build
```

This starts the Django backend server on port `8000`.

---

## 📡 API Reference

### Django REST Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/authentication/register/` | User registration |
| `POST` | `/api/authentication/login/` | JWT login |
| `POST` | `/api/authentication/otp/` | OTP verification |
| `POST` | `/api/authentication/forgot-password/` | Password reset via email |
| `GET` | `/api/authentication/user` | Get authenticated user |
| `GET/PATCH` | `/api/user/` | User profile / update FCM token |
| `POST` | `/api/reports/` | Upload medical report |
| `GET` | `/api/reports/` | List user's reports |
| `GET` | `/api/reports/<id>/` | Report detail with instances |
| `POST` | `/api/diet/scan/` | Barcode food analysis |
| `GET` | `/` | Health check |

### FastAPI AI Endpoints

| Method | Endpoint | Service | Description |
|--------|----------|---------|-------------|
| `POST` | `/text_chat/` | AI Assistant | Text-based AI chat |
| `POST` | `/process_audio/` | AI Assistant | Audio → transcription + AI response |
| `POST` | `/process_image_ocr/` | AI Assistant | Image OCR → AI analysis |
| `POST` | `/voice_chat/` | AI Assistant | Voice chat (audio in, audio out) |
| `POST` | `/start-call` | Calling Agent | Start Dr. Sarah voice session |
| `POST` | `/voice-chat` | Calling Agent | Send voice to active session |
| `POST` | `/end-call` | Calling Agent | End voice session |
| `WS` | `/ws/voice-call/{session_id}` | Calling Agent | Real-time WebSocket voice call |
| `GET` | `/health` | Both | Health check |

---

## 🔑 Environment Variables

### Django Server (`server/.env`)

```env
# Database (Supabase / PostgreSQL)
DB_NAME=your_db_name
DB_USER=your_db_user
DB_PASSWORD=your_db_password
DB_HOST=your_db_host
DB_PORT=5432

# Email (SMTP for OTP)
EMAIL_HOST_USER=your_email@gmail.com
EMAIL_HOST_PASSWORD=your_app_password

# AI APIs
OPENAI_API_KEY=sk-...
GROQ_API_KEY=gsk_...
```

### AI Services (root `.env`)

```env
GROQ_API_KEY=gsk_...
OPENAI_API_KEY=sk-...   # Used by report summary agents
```

---

## 👨‍💻 Developer

<div align="center">

### **Fareed**

*Full-Stack AI Engineer · Hackathon Builder*

[![GitHub](https://img.shields.io/badge/GitHub-Fareed95-181717?style=for-the-badge&logo=github)](https://github.com/Fareed95)

> *"Building accessible healthcare technology for a billion people."*

</div>

AarogyaSahayak was built as a hackathon project (Team **CodeNebula**), showcasing a complete production-grade health platform with AI at its core — delivered under pressure and with passion for solving real-world healthcare challenges in India.

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!

1. Fork the repository
2. Create your feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

<div align="center">

Made with ❤️ for India's healthcare future

**AarogyaSahayak** · *Healthy India, Happy India*

</div>
