from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from src.models.events import Event
from src.models.players import Player
from src.models.results import Result


async def players_with_medals(session: AsyncSession):
    """
    Найдите всех игроков, которые выиграли хотя бы одну медаль (GOLD, SILVER и BRONZE) на одной Олимпиаде. (player-name, olympic-id).
    """
    for res in await session.execute(
        select(Player.name, Event.olympic_id)
        .join(Result, Player.player_id == Result.player_id)
        .join(Event, Result.event_id == Event.event_id)
        .where(Result.medal.isnot(None))
        .group_by(Player.name, Event.olympic_id)
        .limit(10)  # IMPORTANT: не относится к заданию, но добавлено для удобства проверки
    ):
        print(res)
