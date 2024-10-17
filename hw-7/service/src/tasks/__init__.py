import inspect

from sqlalchemy.ext.asyncio import AsyncSession

from .task_1 import olympics_2004
from .task_2 import non_team_ties
from .task_3 import players_with_medals
from .task_4 import country_with_vowel_players
from .task_5 import countries_lowest_team_medals_ratio


async def run_tasks(session: AsyncSession) -> None:
    tasks = [
        olympics_2004,
        non_team_ties,
        players_with_medals,
        country_with_vowel_players,
        countries_lowest_team_medals_ratio,
    ]
    for idx, task in enumerate(tasks, start=1):
        print('----------------------------------')
        print(f'{idx}. {inspect.getdoc(task) or ''}')
        await task(session)
