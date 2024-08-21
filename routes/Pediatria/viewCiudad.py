from typing import List
from fastapi import Depends, APIRouter,HTTPException
from sqlalchemy.orm import Session
from cryptography.fernet import Fernet

import crud.Pediatria.viewCiudad, models.Pediatria.viewCiudad, schemas.Pediatria.viewCiudad, config.db
from typing import List
from jwt_config import solicita_token
from portadortoken import Portador
key=Fernet.generate_key()
f = Fernet(key)


models.Pediatria.viewCiudad.Base.metadata.create_all(bind=config.db.engine)

view1 = APIRouter()

# Dependencia de base de datos
def get_db():
    db = config.db.SessionLocal()
    try:
        yield db
    finally:
        db.close()

@view1.get("/nciudad/", response_model=List[schemas.Pediatria.viewCiudad.NacimientosPorCiudad], tags=['Pediatria'],dependencies=[Depends(Portador())])
def read_nacimientos_por_ciudad(skip: int = 0, limit: int = 10, db: Session = Depends(get_db)):
    nacimientos = crud.Pediatria.viewCiudad.get_nacimientos_por_ciudad(db, skip=skip, limit=limit)
    return nacimientos