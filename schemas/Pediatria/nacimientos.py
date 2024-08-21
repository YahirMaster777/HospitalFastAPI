from typing import List, Optional
from pydantic import BaseModel, Field
from datetime import date, time

class BabyBase(BaseModel):
    fecha_nacimiento : date
    hora_nacimiento : time
    lugar_nacimiento : str
    peso: float
    longitud : float
    nombre_padre : str
    nombre_madre : str
    telefono_contacto : str
    email_contacto : str
    observaciones : str
    tipo_nacimiento : str
    frecuencia_cardiaca : int
    temperatura : float
    presion_arterial_sistolica : float
    presion_arterial_diastolica : float
    sexo : str

class BabyUpdate(BaseModel):
    fecha_nacimiento: Optional[date] = None
    hora_nacimiento: Optional[time] = None
    lugar_nacimiento: Optional[str] = None
    peso: Optional[float] = Field(None, gt=0)
    longitud: Optional[float] = Field(None, gt=0)
    nombre_padre: Optional[str] = None
    nombre_madre: Optional[str] = None
    telefono_contacto: Optional[str] = None
    email_contacto: Optional[str] = None
    observaciones: Optional[str] = None
    tipo_nacimiento : str
    frecuencia_cardiaca: Optional[int] = Field(None, gt=0)
    temperatura: Optional[float] = Field(None, gt=0)
    presion_arterial_sistolica: Optional[int] = Field(None, gt=0)
    presion_arterial_diastolica: Optional[int] = Field(None, gt=0)
    sexo: Optional[str] = None

    class Config:
        orm_mode = True

class BabyCreate(BabyBase):
    pass


class Baby(BabyBase):
    id: int
    #owner_id: int clave foranea
    class Config:
        orm_mode = True
        
class PaginationResponse(BaseModel):
    items: List[Baby]
    total: int