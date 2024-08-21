from pydantic import BaseModel

class TiposDeNacimiento(BaseModel):
    total_pacientes : int
    total_masculino:int
    total_femenino : int
    pn_masculino :int 
    pn_femeninos : int
    c_masculino : int
    c_femenino :int 

class Config: 
    from_attributes= True