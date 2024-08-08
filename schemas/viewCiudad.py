from pydantic import BaseModel

class NacimientosPorCiudad(BaseModel):
    id: int
    lugar_nacimiento: str
    cantidad_nacimientos: int

    class Config:
        orm_mode = True
