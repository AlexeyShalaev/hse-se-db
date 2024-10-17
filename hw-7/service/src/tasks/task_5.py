from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from src.models.countries import Country
from src.models.events import Event
from src.models.olympics import Olympic
from src.models.players import Player
from src.models.results import Result


async def countries_lowest_team_medals_ratio(session: AsyncSession):
    """
    Для Олимпийских игр 2000 года найдите 5 стран с минимальным соотношением количества групповых медалей к численности населения.
    """
    for res in await session.execute(
        select(
            Country.name,
            (func.count(Result.medal).filter(Event.is_team_event == 1) / Country.population).label("team_medal_ratio"),
        )
        .join(Player, Country.country_id == Player.country_id)
        .join(Result, Player.player_id == Result.player_id)
        .join(Event, Result.event_id == Event.event_id)
        .join(Olympic, Event.olympic_id == Olympic.olympic_id)
        .where(Olympic.year == 2000)
        .group_by(Country.name, Country.population)
        .order_by((func.count(Result.medal).filter(Event.is_team_event == 1) / Country.population))
        .limit(5)
    ):
        print(res)
