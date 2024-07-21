from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
#configuracion de la base de datosm en aiven 
SQLALCHEMY_DATABASE_URL = "mysql+pymysql://avnadmin:AVNS_QDzr-PDwiMpIOLI-1MV@hospital-yahirperez141002-6d00.h.aivencloud.com:17563/test"
engine = create_engine(SQLALCHEMY_DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()
