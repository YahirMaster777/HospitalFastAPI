from sqlalchemy.orm import Session
import models.Pediatria.viewGenero

def get_tipo_nacimientos(db: Session, skip: int = 0, limit: int = 10):
    return db.query(models.Pediatria.viewGenero.TiposDeNacimiento).offset(skip).limit(limit).all()