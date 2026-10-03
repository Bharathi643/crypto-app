# Flutter Environment Setup

The frontend reads the backend URL from `.env`.

Current Chrome/Web setting:
API_BASE_URL=http://localhost:5000/api

Android emulator:
API_BASE_URL=http://10.0.2.2:5000/api

Physical Android phone on the same network:
API_BASE_URL=http://192.168.31.109:5000/api

Do not put the CoinGecko API key in the Flutter `.env`.
The external API key, if needed, belongs only in the Node.js backend `.env`.
