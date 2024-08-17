from typing import List, Union,Literal
from pydantic import BaseModel
from datetime import datetime, date

class VacunaBase(BaseModel):
    nacimientos_id: int
    vacuna_administrada: str
    dosis: float
    via_administracion: str
    numero_lote: int
    fecha_administracion: date

class VacunaCreate(VacunaBase):
    pass

class VacunaUpdate(VacunaBase):
    pass

class Vacuna(VacunaBase):
    id: int
    class Config:
        orm_mode = True

    

