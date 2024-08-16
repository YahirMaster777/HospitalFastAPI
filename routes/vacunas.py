from fastapi import APIRouter, HTTPException, Depends, Query
from sqlalchemy.orm import Session
from cryptography import fernet
import crud.vacunas, config.db, schemas.vacunas, models.vacunas
from typing import List

vacuna = APIRouter()

models.vacunas.Base.metadata.create_all(bind=config.db.engine)

def get_db():
    db = config.db.SessionLocal()
    try:
        yield db
    finally:
        db.close()
        
@vacuna.get("/vacunas/", response_model=List[schemas.vacunas.Vacuna], tags=['Pediatria'])
def read_vacunas(skip: int = Query(0, alias="page", ge=0), limit: int = Query(10, le=100), db: Session = Depends(get_db)):
    db_vacunas = crud.vacunas.get_vacunas(db=db, skip=skip*limit, limit=limit)
    return db_vacunas

@vacuna.get("/vacunas/{id}/", response_model=schemas.vacunas.Vacuna, tags=  ['Pediatria'])
def read_vacunas(id:int, db:Session = Depends(get_db)):
    db_vacunas = crud.vacunas.get_vacunas_baby(db=db, id=id)
    if db_vacunas is None:
        raise HTTPException(status_code=404, detail="vacunas no encontrado")
    return db_vacunas


@vacuna.post("/vacunas/", response_model=schemas.vacunas.Vacuna, tags=["Pediatria"])
def vacunas(vacuna: schemas.vacunas.VacunaCreate, db: Session = Depends(get_db)):
    db_vacunas = crud.vacunas.get_vacunas_byId(db, id=vacuna.nacimientos_id)
    
    if db_vacunas:
        raise HTTPException(status_code=400, detail=" vacunas ya existe. Intente nuevamente.")
    return crud.vacunas.create_vacuna(db=db, vacuna=vacuna)