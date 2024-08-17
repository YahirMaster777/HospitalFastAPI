from typing import List
from fastapi import Depends, APIRouter,HTTPException
from sqlalchemy.orm import Session
import crud.viewGenero, models.viewGenero, schemas.viewGenero, config.db


models.viewGenero.Base.metadata.create_all(bind=config.db.engine)

view2 = APIRouter()

# Dependencia de base de datos
def get_db():
    db = config.db.SessionLocal()
    try:
        yield db
    finally:
        db.close()

@view2.get("/nacimientogenero/", response_model=List[schemas.viewGenero.TiposDeNacimiento], tags=["Pediatria"])
def read_tipo_nacimiento(skip: int = 0, limit: int = 10, db: Session = Depends(get_db)):
    nacimientos = crud.viewGenero.get_tipo_nacimientos(db, skip=skip, limit=limit)
    return nacimientos