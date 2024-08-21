from fastapi import APIRouter, HTTPException, Depends, Query
from sqlalchemy.orm import Session
from cryptography.fernet import Fernet
import crud.Pediatria.nacimientos, config.db, schemas.Pediatria.nacimientos, models.Pediatria.nacimientos
from typing import List
from jwt_config import solicita_token
from portadortoken import Portador
key=Fernet.generate_key()
f = Fernet(key)


baby = APIRouter()

models.Pediatria.nacimientos.Base.metadata.create_all(bind=config.db.engine)

def get_db():
    db = config.db.SessionLocal()
    try:
        yield db
    finally:
        db.close()

@baby.get("/nacimientos/", response_model=List[schemas.Pediatria.nacimientos.Baby], tags=['Nacimientos'],dependencies=[Depends(Portador())])
def read_nacimientos(skip: int = Query(0, alias="page", ge=0), limit: int = Query(10, le=100), db: Session = Depends(get_db)):
    db_nacimientos = crud.Pediatria.nacimientos.get_babys(db=db, skip=skip*limit, limit=limit)
    return db_nacimientos

@baby.get("/nacimiento/{id}/", response_model=schemas.Pediatria.nacimientos.Baby, tags=  ['Nacimientos'],dependencies=[Depends(Portador())])
def read_nacimiento(id:int, db:Session = Depends(get_db)):
    db_nacimientos = crud.Pediatria.nacimientos.get_nacimiento(db=db, id=id)
    if db_nacimientos is None:
        raise HTTPException(status_code=404, detail="Nacimiento no encontrado")
    return db_nacimientos

@baby.post("/nacimiento/", response_model=schemas.Pediatria.nacimientos.Baby, tags=["Nacimientos"],dependencies=[Depends(Portador())])
def create_nacimiento(baby: schemas.Pediatria.nacimientos.BabyCreate, db: Session = Depends(get_db)):
    db_nacimiento = crud.Pediatria.nacimientos.get_nacimiento_by_fecha_y_padre(db, fecha_nacimiento=baby.fecha_nacimiento, nombre_padre=baby.nombre_padre)
    
    if db_nacimiento:
        raise HTTPException(status_code=400, detail="El nacimiento ya existe. Intente nuevamente.")
    
    return crud.Pediatria.nacimientos.create_nacimiento(db=db, baby=baby)

@baby.put("/nacimientoput/{id}", response_model=schemas.Pediatria.nacimientos.Baby, tags=["Nacimientos"],dependencies=[Depends(Portador())])
def update_nacimiento(id: int, baby_update: schemas.Pediatria.nacimientos.BabyUpdate, db: Session = Depends(get_db)):
    db_nacimiento = crud.Pediatria.nacimientos.update_nacimiento(db=db, id=id, baby_update=baby_update)
    if db_nacimiento is None:
        raise HTTPException(status_code=404, detail="El nacimiento no existe")
    return db_nacimiento


# @baby.put("/nacimiento/{id}", response_model=schemas.nacimientos.Baby, tags=["Nacimientos"])
# def update_nacimiento(id: int, baby: schemas.nacimientos.BabyUpdate, db: Session = Depends(get_db)):
#     db_nacimiento = crud.nacimientos.update_nacimiento(db=db, id=id, baby_update=baby)
#     if db_nacimiento is None:
#         raise HTTPException(status_code=404, detail="El nacimiento no existe")
#     return db_nacimiento



@baby.delete("/nacimiento/{id}", response_model=schemas.Pediatria.nacimientos.Baby, tags=["Nacimientos"],dependencies=[Depends(Portador())])
def delete_nacimiento(id: int, db: Session = Depends(get_db)):
    db_nacimiento = crud.Pediatria.nacimientos.delete_nacimiento(db=db, id=id)
    if db_nacimiento is None:
        raise HTTPException(status_code=404, detail="El nacimiento no existe, no se pudo eliminar")
    return db_nacimiento

