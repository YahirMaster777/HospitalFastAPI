from sqlalchemy import Column, Integer, String, Float, ForeignKey, Date
from sqlalchemy.dialects.mysql import LONGTEXT
from sqlalchemy.orm import relationship
from config.db import Base

class Vacunas(Base):
    __tablename__ = "tbd_vacunas"

    id = Column(Integer, primary_key=True, autoincrement=True)
    nacimientos_id = Column(Integer, ForeignKey("tbb_nacimientos.id"), index=True)
    vacuna_administrada = Column(String(50), nullable=False)
    dosis = Column(Float, nullable=False)
    via_administracion = Column(String(50), nullable=False)
    numero_lote = Column(Integer, nullable=False)
    fecha_administracion = Column(Date, nullable=False)

