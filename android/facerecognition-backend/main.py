from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app import router

app = FastAPI()

# ✅ Middleware biar bisa diakses Flutter / Android Studio
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Daftarkan semua endpoint dari app.py
app.include_router(router)

@app.get("/")
async def root():
    return {"message": "Face Ticketing API running"}
