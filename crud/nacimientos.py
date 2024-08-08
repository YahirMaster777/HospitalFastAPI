import models.nacimientos 
import schemas.nacimientos 
from sqlalchemy.orm import Session

def create_nacimiento(db: Session, baby: schemas.nacimientos.BabyCreate):
    db_baby = models.nacimientos.Baby(**baby.dict())
    db.add(db_baby)
    db.commit()
    db.refresh(db_baby)
    return db_baby

def get_nacimiento(db: Session, id: int):
    return db.query(models.nacimientos.Baby).filter(models.nacimientos.Baby.id == id).first()

def get_nacimiento_by_fecha_y_padre(db: Session, fecha_nacimiento: str, nombre_padre: str):
    return db.query(models.nacimientos.Baby).filter(
        models.nacimientos.Baby.fecha_nacimiento == fecha_nacimiento, 
        models.nacimientos.Baby.nombre_padre == nombre_padre
    ).first()

def get_babys(db: Session, skip: int = 0, limit: int = 10):
    return db.query(models.nacimientos.Baby).offset(skip).limit(limit).all()

# def get_babys(db: Session, skip: int = 0, limit: int = 10):
#     return db.query(models.nacimientos.Baby).offset(skip).limit(limit).all()


def update_nacimiento(db: Session, id: int, baby_update: schemas.nacimientos.BabyUpdate):
    db_nacimiento = db.query(models.nacimientos.Baby).filter(models.nacimientos.Baby.id == id).first()
    if db_nacimiento:
        for key, value in baby_update.dict(exclude_unset=True).items():
            setattr(db_nacimiento, key, value)
        db.commit()
        db.refresh(db_nacimiento)
        return db_nacimiento
    return None

def delete_nacimiento(db: Session, id: int):
    db_nacimiento = db.query(models.nacimientos.Baby).filter(models.nacimientos.Baby.id == id).first()
    if db_nacimiento:
        db.delete(db_nacimiento)
        db.commit()
    return db_nacimiento
