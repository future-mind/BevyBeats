from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
import os
from dotenv import load_dotenv

# Import routers
from api.youtube import router as youtube_router
from api.ai import router as ai_router

# Load environment variables
load_dotenv()

# Initialize FastAPI app
app = FastAPI(
    title="BevyBeats API",
    description="Backend API for BevyBeats music streaming application",
    version="0.1.0"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Adjust for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(youtube_router)
app.include_router(ai_router)

# Root endpoint
@app.get("/")
async def root():
    return {"message": "Welcome to BevyBeats API", "status": "online"}

# Health check endpoint
@app.get("/health")
async def health_check():
    return {"status": "healthy"}

# Run the application with uvicorn
if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True) 