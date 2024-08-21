from typing import List
from fastapi import Depends, APIRouter,HTTPException
from sqlalchemy.orm import Session
from cryptography.fernet import Fernet
import crud.Pediatria.viewGenero, models.Pediatria.viewGenero, schemas.Pediatria.viewGenero, config.db
from jwt_config import solicita_token
from portadortoken import Portador
key=Fernet.generate_key()
f = Fernet(key)


models.Pediatria.viewGenero.Base.metadata.create_all(bind=config.db.engine)

view2 = APIRouter()

# Dependencia de base de datos
def get_db():
    db = config.db.SessionLocal()
    try:
        yield db
    finally:
        db.close()

@view2.get("/nacimientogenero/", response_model=List[schemas.Pediatria.viewGenero.TiposDeNacimiento], tags=['Pediatria'],dependencies=[Depends(Portador())])
def read_tipo_nacimiento(skip: int = 0, limit: int = 10, db: Session = Depends(get_db)):
    nacimientos = crud.Pediatria.viewGenero.get_tipo_nacimientos(db, skip=skip, limit=limit)
    return nacimientos