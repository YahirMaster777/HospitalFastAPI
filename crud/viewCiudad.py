from sqlalchemy.orm import Session
import models.viewCiudad

def get_nacimientos_por_ciudad(db: Session, skip: int = 0, limit: int = 10):
    return db.query(models.viewCiudad.NacimientosPorCiudad).offset(skip).limit(limit).all()