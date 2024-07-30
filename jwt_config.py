import jwt

def solicita_token(dato: dict) -> str:
    try:
        token: str = jwt.encode(payload=dato, key='mi_clave', algorithm='HS256')
        return token
    except jwt.PyJWTError as e:
        print(f"Error al generar el token: {e}")
        return ""

def valida_token(token: str) -> dict:
    try:
        dato: dict = jwt.decode(token, key='mi_clave', algorithms=['HS256'])
        return dato
    except jwt.PyJWTError as e:
        print(f"Error al validar el token: {e}")
        return {}
