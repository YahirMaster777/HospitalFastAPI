from typing import List
from fastapi import Depends, APIRouter,HTTPException
from sqlalchemy.orm import Session
import crud.viewCiudad, models.viewCiudad, schemas.viewCiudad, config.db


models.viewCiudad.Base.metadata.create_all(bind=config.db.engine)

view1 = APIRouter()

# Dependencia de base de datos
def get_db():
    db = config.db.SessionLocal()
    try:
        yield db
    finally:
        db.close()

@view1.get("/nciudad/", response_model=List[schemas.viewCiudad.NacimientosPorCiudad])
def read_nacimientos_por_ciudad(skip: int = 0, limit: int = 10, db: Session = Depends(get_db)):
    nacimientos = crud.viewCiudad.get_nacimientos_por_ciudad(db, skip=skip, limit=limit)
    return nacimientos