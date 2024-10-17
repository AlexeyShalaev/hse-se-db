import asyncio

from loguru import logger

from src.core.config import settings
from src.core.setup import FillDatabase, run_migrations
from src.database import get_session


async def main() -> None:
    logger.info("Service started.")
    run_migrations(settings.ALEMBIC_CFG)
    async for db_session in get_session():
        await FillDatabase(db_session).run()
        logger.debug("Database filled.")
        break


if __name__ == "__main__":
    asyncio.run(main())