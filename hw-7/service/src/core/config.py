from pydantic import PostgresDsn
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    ALEMBIC_CFG: str = "/app/alembic.ini"
    DATABASE_URL: PostgresDsn
    DATABASE_ECHO: bool = False
    DEBUG: bool = False


settings = Settings()
