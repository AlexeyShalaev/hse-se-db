from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from src.models.events import Event
from src.models.olympics import Olympic
from src.models.players import Player
from src.models.results import Result


async def olympics_2004(session: AsyncSession):
    """
    Для Олимпийских игр 2004 года сгенерируйте список (год рождения, количество игроков, количество золотых медалей),
    содержащий годы, в которые родились игроки, количество игроков, родившихся в каждый из этих лет,
    которые выиграли по крайней мере одну золотую медаль, и количество золотых медалей, завоеванных игроками, родившимися в этом году.
    """
    for res in await session.execute(
        select(
            func.extract("year", Player.birthdate).label("birth_year"),
            func.count(Player.player_id).label("player_count"),
            func.count(Result.medal).label("gold_medal_count"),
        )
        .join(Result, Player.player_id == Result.player_id)
        .join(Event, Result.event_id == Event.event_id)
        .join(Olympic, Event.olympic_id == Olympic.olympic_id)
        .where(Olympic.year == 2004)
        .where(Result.medal == "GOLD")
        .group_by(func.extract("year", Player.birthdate))
        .order_by(func.extract("year", Player.birthdate))
    ):
        print(res)
