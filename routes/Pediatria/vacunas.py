from fastapi import APIRouter, HTTPException, Depends, Query
from sqlalchemy.orm import Session
from cryptography.fernet import Fernet
import crud.Pediatria.vacunas, config.db, schemas.Pediatria.vacunas, models.Pediatria.vacunas
from typing import List
from jwt_config import solicita_token
from portadortoken import Portador
key=Fernet.generate_key()
f = Fernet(key)

vacuna = APIRouter()

models.Pediatria.vacunas.Base.metadata.create_all(bind=config.db.engine)

def get_db():
    db = config.db.SessionLocal()
    try:
        yield db
    finally:
        db.close()
        
@vacuna.get("/vacunas/", response_model=List[schemas.Pediatria.vacunas.Vacuna], tags=['Pediatria'],dependencies=[Depends(Portador())])
def read_vacunas(skip: int = Query(0, alias="page", ge=0), limit: int = Query(10, le=100), db: Session = Depends(get_db)):
    db_vacunas = crud.Pediatria.vacunas.get_vacunas(db=db, skip=skip*limit, limit=limit)
    return db_vacunas

@vacuna.get("/vacunas/{id}/", response_model=List[schemas.Pediatria.vacunas.Vacuna], tags=['Pediatria'],dependencies=[Depends(Portador())])
def read_vacunas(id: int, skip: int = Query(0, alias="page", ge=0), limit: int = Query(10, le=100), db: Session = Depends(get_db)):
    # Se obtiene una lista de vacunas asociadas al nacimiento con el ID proporcionado
    db_vacunas = crud.Pediatria.vacunas.get_vacunas_by_nacimientos_id(db=db, nacimientos_id=id, skip=skip, limit=limit)
    
    if not db_vacunas:
        raise HTTPException(status_code=404, detail="No se encontraron vacunas para este nacimiento")
    
    return db_vacunas


@vacuna.post("/vacunas/", response_model=schemas.Pediatria.vacunas.Vacuna, tags=["Pediatria"],dependencies=[Depends(Portador())])
def vacunas(vacuna: schemas.Pediatria.vacunas.VacunaCreate, db: Session = Depends(get_db)):
    db_vacuna_existente = crud.Pediatria.vacunas.get_vacunas_by_name_and_nacimientos_id(
        db, nombre=vacuna.vacuna_administrada, nacimientos_id=vacuna.nacimientos_id
    )
    if db_vacuna_existente:
        raise HTTPException(status_code=400, detail="Vacuna ya existe para este nacimiento.")
    return crud.Pediatria.vacunas.create_vacuna(db=db, vacuna=vacuna)
