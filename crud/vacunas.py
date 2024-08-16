import models.vacunas
import schemas.vacunas
from sqlalchemy.orm import Session
import models, schemas


def get_vacunas_byId(db:Session, id:int):
    return db.query(models.vacunas.Vacunas).filter(models.vacunas.Vacunas.ID == id).first()

def get_vacunas_baby(db:Session, id:int):
    return db.query(models.vacunas.Vacunas).filter(models.vacunas.Vacunas.nacimientos_id == id).first()

def get_vacunas(db: Session, skip: int = 0, limit: int = 10):
    return db.query(models.vacunas.Vacunas).offset(skip).limit(limit).all()

def create_vacuna(db: Session, vacuna: schemas.vacunas.VacunaCreate):
    db_vacuna = models.vacunas.Vacunas(**vacuna.dict())
    db.add(db_vacuna)
    db.commit()
    db.refresh(db_vacuna)
    return db_vacuna
