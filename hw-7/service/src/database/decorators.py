from functools import wraps

from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.ext.asyncio import AsyncSession


def atomic(func):
    @wraps(func)
    async def wrapper(*args, **kwargs):
        result = await func(*args, **kwargs)
        for v in kwargs.values():
            if isinstance(v, AsyncSession):
                await v.commit()
                break
        else:
            raise RuntimeError(
                f"Atomic function requires AsyncSession in kwargs. Please request developer to fix {func}."
            )
        return result

    return wrapper


def commit_result(func):
    """
    Decorator that commits the changes made by the decorated function to the database.

    Args:
        func (callable): The function to be decorated.

    Returns:
        callable: The decorated function.

    """

    @wraps(func)
    async def wrapper(db: AsyncSession, *args, commit: bool = True, **kwargs):
        try:
            result = await func(db, *args, **kwargs)
            if commit:
                await db.commit()
            return result
        except SQLAlchemyError:
            await db.rollback()
            raise

    return wrapper


def scalar(func):
    """
    Decorator that executes the given function with a database session and returns the scalar result.

    Args:
        func: the function to be decorated.

    Returns:
        The scalar result of the function.
    """

    @wraps(func)
    async def wrapper(db: AsyncSession, *args, **kwargs):
        result = await func(db, *args, **kwargs)
        return result.scalar()

    return wrapper


def scalars(func):
    """
    A decorator that converts the result of a database query to scalars.

    Args:
        func: The function to be decorated.

    Returns:
        The decorated function.

    """

    @wraps(func)
    async def wrapper(db: AsyncSession, *args, **kwargs):
        result = await func(db, *args, **kwargs)
        return result.scalars()

    return wrapper


def all(func):
    """
    Decorator that executes the wrapped function with the provided AsyncSession
    and returns the result as a list of scalars.

    Args:
        func: The function to be wrapped.

    Returns:
        The result of the wrapped function as a list of scalars.
    """

    @wraps(func)
    async def wrapper(db: AsyncSession, *args, **kwargs):
        result = await func(db, *args, **kwargs)
        return result.scalars().all()

    return wrapper
