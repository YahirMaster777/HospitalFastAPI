from typing import List, Union,Literal
from pydantic import BaseModel
from datetime import datetime, date

class VacunaBase(BaseModel):
    nacimientos_id: int
    vacuna_administrada: str
    numero_lote: str
    fecha_admistracion: date

class VacunaCreate(VacunaBase):
    pass

class VacunaUpdate(VacunaBase):
    pass

class Vacuna(VacunaBase):
    ID: int
    class Config:
        orm_mode = True

    

