import os
from fastapi import FastAPI
import uvicorn
from routes.user import user
from routes.person import person
from routes.rol import rol
from routes.userrol import userrol
from routes.nacimientos import baby
from routes.viewCiudad import view1
from routes.viewGenero import view2
from routes.vacunas import vacuna
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

app.include_router(user, prefix="/api")
app.include_router(person, prefix="/api")
app.include_router(rol, prefix="/api")
app.include_router(userrol, prefix="/api")
app.include_router(baby, prefix="/api")
app.include_router(view1, prefix="/api")
app.include_router(view2, prefix="/api")
app.include_router(vacuna, prefix="/api")
# Para desplegar el proyecto en render 
if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8000))
    uvicorn.run(app, host="0.0.0.0", port=port)