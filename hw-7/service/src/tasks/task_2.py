from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from src.models.events import Event
from src.models.results import Result


async def non_team_ties(session: AsyncSession):
    """
    Перечислите все индивидуальные (не групповые) соревнования, в которых была ничья в счете, и два или более игрока выиграли золотую медаль.
    """
    for res in await session.execute(
        select(Event.name, func.count(Result.player_id).label("gold_winners"))
        .join(Result, Event.event_id == Result.event_id)
        .where(Event.is_team_event == 0)
        .where(Result.medal == "GOLD")
        .group_by(Event.name, Result.result)
        .having(func.count(Result.player_id) > 1)
        .order_by(func.count(Result.player_id).desc())
    ):
        print(res)
