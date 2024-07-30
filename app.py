import os
from fastapi import FastAPI
import uvicorn
from routes.user import user
from routes.person import person
from routes.rol import rol
from routes.userrol import userrol
from fastapi.middleware.cors import CORSMiddleware

app=FastAPI(
    title="Privilege Care S.A. de C.V.",
    description="API para un Hospital"
)

origins = [
    "http://localhost:8080",
    "http://127.0.0.1:8080",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(user)
app.include_router(person)
app.include_router(rol)
app.include_router(userrol)

# Para desplegar el proyecto en render 
if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8000))
    uvicorn.run(app, host="0.0.0.0", port=port)