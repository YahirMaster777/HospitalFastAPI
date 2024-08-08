from sqlalchemy import Column, Integer, String, Text, Enum, Float, Time, Date
from config.db import Base
from sqlalchemy.dialects.mysql import LONGTEXT

class Baby(Base):
    __tablename__ = "babys_born"
    
    id = Column(Integer, primary_key=True, index=True)
    fecha_nacimiento = Column(Date, nullable=False)
    hora_nacimiento = Column(Time, nullable=False)
    lugar_nacimiento = Column(String(100), nullable=False)
    peso = Column(Float, nullable=False)
    longitud = Column(Float, nullable=False)
    nombre_padre = Column(String(100), nullable=False)
    nombre_madre = Column(String(100), nullable=False)
    telefono_contacto = Column(String(20), nullable=False)
    email_contacto = Column(String(254), nullable=False)
    observaciones = Column(LONGTEXT, nullable=False) # type: ignore
    tipo_nacimiento = Column(Enum("Normal", "Cesarea"))
    frecuencia_cardiaca = Column(Integer, nullable=False)
    temperatura = Column(Float, nullable=False)
    presion_arterial_sistolica = Column(Integer, nullable=False)
    presion_arterial_diastolica = Column(Integer, nullable=False)
    sexo = Column(Enum('Femenino', 'Masculino'), nullable=False)
