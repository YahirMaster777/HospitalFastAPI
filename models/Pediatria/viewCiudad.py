from sqlalchemy import Column, Integer, String
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()

class NacimientosPorCiudad(Base):
    __tablename__ = 'vw_nacimientos_por_ciudad'
    id = Column(Integer, primary_key=True, index=True)
    lugar_nacimiento = Column(String(100), index=True)
    cantidad_nacimientos = Column(Integer)