from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from src.models.countries import Country
from src.models.players import Player


async def country_with_vowel_players(session: AsyncSession):
    """
    В какой стране был наибольший процент игроков (из перечисленных в наборе данных), чьи имена начинались с гласной?
    """
    vowel_pattern = "^[AEIOUaeiou]"
    for res in await session.execute(
        select(
            Country.name,
            (
                func.count(Player.player_id).filter(Player.name.op("~")(vowel_pattern))
                / func.count(Player.player_id)
                * 100
            ).label("vowel_player_percentage"),
        )
        .join(Player, Country.country_id == Player.country_id)
        .group_by(Country.name)
        .order_by(func.count(Player.player_id).filter(Player.name.op("~")(vowel_pattern)).desc())
        .limit(1)
    ):
        print(res)
