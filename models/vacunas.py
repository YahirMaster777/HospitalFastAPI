from sqlalchemy import Column, Integer, String, Boolean, DateTime, ForeignKey, Enum
from sqlalchemy.dialects.mysql import LONGTEXT
from sqlalchemy.orm import relationship
from config.db import Base
import models.persons
import enum

class Vacunas(Base):
    __tablename__ = "tbd_vacunas"

    ID = Column(Integer, primary_key=True, index=True)
    nacimientos_id = Column(Integer, ForeignKey("tbb_nacimientos.id"))
    vacuna_administrada = Column(String(50))
    numero_lote = (Integer)
    fecha_admistracion = Column(DateTime)
    # Clave foránea para la relación uno a uno con User
    

