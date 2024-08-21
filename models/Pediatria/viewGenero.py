from sqlalchemy import Column, Integer
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()

class TiposDeNacimiento(Base):
    __tablename__ = 'test'
    total_pacientes = Column(Integer, primary_key=True,index=True)
    total_masculino = Column(Integer)
    total_femenino = Column(Integer)
    pn_masculino = Column(Integer)
    pn_femeninos = Column(Integer)
    c_masculino = Column(Integer)
    c_femenino = Column(Integer)