from typing import Any

from sqlalchemy import delete, insert, select, update
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.sql import operators

from .decorators import all, commit_result, scalar


class AsyncSessionPremium(AsyncSession):

    @commit_result
    async def insert(self, obj):
        """
        Inserts an object into the database.

        Args:
            obj: The object to be inserted.

        Returns:
            The result of the database insertion operation.
        """
        filtered_obj_data = {key: value for key, value in obj.__dict__.items() if hasattr(type(obj), key)}
        return await self.execute(insert(type(obj)).values(**filtered_obj_data))

    @commit_result
    async def update(self, obj):
        """
        Update an object in the database.

        Args:
            obj: The object to be updated.

        Returns:
            The result of the update operation.

        """
        filtered_obj_data = {
            key: value for key, value in obj.__dict__.items() if hasattr(type(obj), key) and key != "id"
        }
        return await self.execute(
            update(type(obj)).where(operators.eq(type(obj).id, obj.id)).values(**filtered_obj_data)
        )

    async def insert_or_update_obj(self, obj):
        """
        Inserts the given object into the database if it doesn't exist,
        otherwise updates the existing object.

        Args:
            obj: The object to be inserted or updated.

        Returns:
            None
        """
        res = await self.insert(obj)
        if not res:
            await self.update(obj)

    @scalar
    async def get_by_filter(self, cls: Any, where_stmt: Any) -> Any:
        """
        Retrieves an object from the database based on the given filter.

        Args:
            cls (Any): The class representing the database table.
            where_stmt (Any): The filter condition to apply.

        Returns:
            Any: The retrieved object.

        """
        return await self.execute(select(cls).where(where_stmt))

    @scalar
    async def get_by_id(self, cls: Any, id: Any) -> Any:
        """
        Retrieve an object from the database by its ID.

        Args:
            cls (Any): The class of the object to retrieve.
            id (Any): The ID of the object to retrieve.

        Returns:
            Any: The retrieved object.

        """
        return await self.execute(select(cls).where(operators.eq(cls.id, id)))

    @all
    async def get_all(self, cls: Any, where_stmt: Any = True) -> list[Any]:
        """
        Retrieves a list of objects from the database based on the given class and WHERE statement.

        Args:
            cls (Any): The class representing the database table.
            where_stmt (Any): The WHERE statement used to filter the objects.

        Returns:
            list[Any]: A list of objects retrieved from the database.
        """
        return await self.execute(select(cls).where(where_stmt))

    @all
    async def get_batch(self, cls: Any, where_stmt: Any, offset: int, limit: int) -> list[Any]:
        """
        Retrieves a portion of objects from the database.

        Args:
            cls (Any): The class representing the database table.
            where_stmt (Any): The condition to filter the objects.
            offset (int): The number of objects to skip.
            limit (int): The maximum number of objects to retrieve.

        Returns:
            list[Any]: A list of objects retrieved from the database.
        """
        return await self.execute(select(cls).where(where_stmt).offset(offset).limit(limit))

    @commit_result
    @scalar
    async def insert_return_id(self, cls: Any, **kwargs) -> Any:
        """
        Inserts an object into the database table and returns the generated ID.

        Args:
            cls (Any): The class representing the database table.
            **kwargs: Keyword arguments representing the object's attributes.

        Returns:
            ID type: The generated ID of the inserted object.
        """
        filtered_obj_data = {key: value for key, value in kwargs.items() if hasattr(cls, key)}
        return await self.execute(insert(cls).values(**filtered_obj_data).returning(cls.id))

    @commit_result
    @scalar
    async def insert_return_column(self, obj: Any, column: Any) -> Any:
        """
        Inserts an object into the database table and returns the column.

        Args:
            obj: The object to be inserted.

        Returns:
            Column value.
        """
        filtered_obj_data = {key: value for key, value in obj.__dict__.items() if hasattr(type(obj), key)}
        return await self.execute(insert(type(obj)).values(**filtered_obj_data).returning(column))

    @commit_result
    @scalar
    async def update_return_id(self, cls: Any, where_stmt: Any, **kwargs) -> Any:
        """
        Updates an object in the database table specified by `cls` with the given `where_stmt` and `kwargs`.
        Returns the ID of the updated object.

        Args:
            cls (Any): The class representing the database table.
            where_stmt (Any): The condition to select the object to update.
            **kwargs: The key-value pairs of the columns and their new values to update.

        Returns:
            ID type: The ID of the updated object.
        """
        return await self.execute(update(cls).where(where_stmt).values(**kwargs).returning(cls.id))

    @commit_result
    async def delete_by_filter(self, cls: Any, where_stmt: Any) -> Any:
        """
        Delete an object from the database based on the given filter.

        Args:
            cls (Any): The class representing the database table.
            where_stmt (Any): The filter condition to apply.

        Returns:
            Any: The retrieved object.

        """
        return await self.execute(delete(cls).where(where_stmt))

    @commit_result
    async def delete_by_id(self, cls: Any, id: Any) -> Any:
        """
        Delete an object from the database by its ID.

        Args:
            cls (Any): The class of the object to retrieve.
            id (Any): The ID of the object to retrieve.

        Returns:
            Any: The retrieved object.

        """
        return await self.execute(delete(cls).where(operators.eq(cls.id, id)))

    @commit_result
    async def delete(self, obj: Any) -> Any:
        """
        Delete an object from the database by its ID.

        Args:
            obj: The object to be deleted.

        Returns:
            Any: The retrieved object.

        """
        return await self.execute(delete(type(obj)).where(operators.eq(type(obj).id, obj.id)))
