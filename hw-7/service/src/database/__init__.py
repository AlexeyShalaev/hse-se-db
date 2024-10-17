from typing import AsyncGenerator

from loguru import logger
from sqlalchemy import NullPool, text
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.ext.asyncio import create_async_engine
from sqlalchemy.orm import sessionmaker

from src.core.config import settings
from src.database.base import AsyncSessionPremium


class SessionManager:
    """
    A class that implements the necessary functionality for working with the database:
    issuing sessions, storing and updating connection settings.
    """

    def __init__(self) -> None:
        self.refresh()

    def __new__(cls):
        if not hasattr(cls, "instance"):
            cls.instance = super(SessionManager, cls).__new__(cls)
        return cls.instance  # noqa

    def get_session_maker(self) -> sessionmaker:
        return sessionmaker(self.engine, class_=AsyncSessionPremium, expire_on_commit=False)

    def refresh(self) -> None:
        self.engine = create_async_engine(
            str(settings.DATABASE_URL), echo=settings.DATABASE_ECHO, future=True, poolclass=NullPool
        )


async def get_session() -> AsyncGenerator[AsyncSessionPremium, None]:
    """
    Returns an asynchronous session object.

    This function creates an asynchronous session using the sessionmaker function
    with the provided engine and AsyncSessionPremium class. The session is then yielded
    for use in a context manager.

    Returns:
        AsyncSessionPremium: An asynchronous session object.

    """
    async_session = SessionManager().get_session_maker()
    async with async_session() as session:
        yield session


async def check_database_connection():
    """
    Checks the connection to the database by executing a simple query.

    Returns:
        bool: True if the connection is successful, False otherwise.
    """
    try:
        # Execute a simple query to check the connection
        db_session = await anext(get_session())
        await db_session.execute(text("SELECT 1"))
        logger.info("Database connection is OK")
        return True
    except SQLAlchemyError as e:
        # Handle any exceptions that occur
        logger.info(f"Database connection error: {e}")
        return False
