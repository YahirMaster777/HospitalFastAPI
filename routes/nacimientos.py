from fastapi import APIRouter, HTTPException, Depends, Query
from sqlalchemy.orm import Session
from cryptography import fernet
import crud.nacimientos, config.db, schemas.nacimientos, models.nacimientos
from typing import List

baby = APIRouter()

models.nacimientos.Base.metadata.create_all(bind=config.db.engine)

def get_db():
    db = config.db.SessionLocal()
    try:
        yield db
    finally:
        db.close()

@baby.get("/nacimientos/", response_model=List[schemas.nacimientos.Baby], tags=['Nacimientos'])
def read_nacimientos(skip: int = Query(0, alias="page", ge=0), limit: int = Query(10, le=100), db: Session = Depends(get_db)):
    db_nacimientos = crud.nacimientos.get_babys(db=db, skip=skip*limit, limit=limit)
    return db_nacimientos

@baby.get("/nacimiento/{id}/", response_model=schemas.nacimientos.Baby, tags=  ['Nacimientos'])
def read_nacimiento(id:int, db:Session = Depends(get_db)):
    db_nacimientos = crud.nacimientos.get_nacimiento(db=db, id=id)
    if db_nacimientos is None:
        raise HTTPException(status_code=404, detail="Nacimiento no encontrado")
    return db_nacimientos

@baby.post("/nacimiento/", response_model=schemas.nacimientos.Baby, tags=["Nacimientos"])
def create_nacimiento(baby: schemas.nacimientos.BabyCreate, db: Session = Depends(get_db)):
    db_nacimiento = crud.nacimientos.get_nacimiento_by_fecha_y_padre(db, fecha_nacimiento=baby.fecha_nacimiento, nombre_padre=baby.nombre_padre)
    
    if db_nacimiento:
        raise HTTPException(status_code=400, detail="El nacimiento ya existe. Intente nuevamente.")
    
    return crud.nacimientos.create_nacimiento(db=db, baby=baby)

@baby.put("/nacimientoput/{id}", response_model=schemas.nacimientos.Baby, tags=["Nacimientos"])
def update_nacimiento(id: int, baby_update: schemas.nacimientos.BabyUpdate, db: Session = Depends(get_db)):
    db_nacimiento = crud.nacimientos.update_nacimiento(db=db, id=id, baby_update=baby_update)
    if db_nacimiento is None:
        raise HTTPException(status_code=404, detail="El nacimiento no existe")
    return db_nacimiento


# @baby.put("/nacimiento/{id}", response_model=schemas.nacimientos.Baby, tags=["Nacimientos"])
# def update_nacimiento(id: int, baby: schemas.nacimientos.BabyUpdate, db: Session = Depends(get_db)):
#     db_nacimiento = crud.nacimientos.update_nacimiento(db=db, id=id, baby_update=baby)
#     if db_nacimiento is None:
#         raise HTTPException(status_code=404, detail="El nacimiento no existe")
#     return db_nacimiento



@baby.delete("/nacimientodelete/{id}", response_model=schemas.nacimientos.Baby, tags=["Nacimientos"])
def delete_nacimiento(id: int, db: Session = Depends(get_db)):
    db_nacimiento = crud.nacimientos.delete_nacimiento(db=db, id=id)
    if db_nacimiento is None:
        raise HTTPException(status_code=404, detail="El nacimiento no existe, no se pudo eliminar")
    return db_nacimiento

