from datetime import datetime
from alembic import command
from alembic.config import Config
from loguru import logger
from faker import Faker

from src.database.base import AsyncSessionPremium
from src.models.countries import Country
from src.models.olympics import Olympic
from src.models.players import Player
from src.models.events import Event
from src.models.results import Result


def run_migrations(alembic_cfg_path: str, revision: str = "head") -> None:
    alembic_cfg = Config(alembic_cfg_path)
    command.upgrade(alembic_cfg, revision)
    logger.info("Database migrated.")
    

class FillDatabase:
    """
    A class responsible for filling the database with generated data.

    Args:
        db_session (AsyncSessionPremium): The database session object.

    Attributes:
        db (AsyncSessionPremium): The database session object.
    """

    def __init__(self, db_session: AsyncSessionPremium) -> None:
        self._db: AsyncSessionPremium = db_session
        self._faker = Faker()

    async def run(self, 
                  countries: int = 100,
                  olympics: int = 50,
                  players: int = 200,
                  events: int = 100,
                  results: int = 300) -> None:
        await self.seed_countries(countries)
        await self.seed_olympics(olympics)
        await self.seed_players(players)
        await self.seed_events(events)
        await self.seed_results(results)

    async def seed_countries(self, n):
        try:
            for _ in range(n):
                country = Country(
                    name=self._faker.country(),
                    country_id=self._faker.unique.country_code(),
                    area_sqkm=self._faker.random_int(min=1000, max=1000000),
                    population=self._faker.random_int(min=100000, max=500000000)
                )
                await self._db.insert(country, commit=False)
            await self._db.commit()
        except Exception as e:
            logger.debug(e)

    async def seed_olympics(self, n):
        try:
            countries = await self._db.get_all(Country)
            for _ in range(n):
                now_year = datetime.now().year
                year = self._faker.random_int(min=1900, max=now_year)
                startdate = self._faker.date(before_today=False, after_today=True) if year == now_year else self._faker.date_this_century()
                startdate = startdate.replace(year=year)
                enddate = self._faker.date_between_dates(date_start=startdate, date_end=datetime(year, 12, 31))

                olympic = Olympic(
                    olympic_id=self._faker.unique.lexify('???????'),
                    country_id=self._faker.random.choice(countries).country_id,
                    city=self._faker.city(),
                    year=year,
                    startdate=startdate,
                    enddate=enddate,
                )
                await self._db.insert(olympic, commit=False)
            await self._db.commit()
        except Exception as e:
            logger.debug(e)

    async def seed_players(self, n):
        try:
            countries = await self._db.get_all(Country)
            for _ in range(n):
                player = Player(
                    name=self._faker.name(),
                    player_id=self._faker.unique.lexify('??????????'),
                    country_id=self._faker.random.choice(countries).country_id,
                    birthdate=self._faker.date_of_birth(minimum_age=18, maximum_age=40)
                )
                await self._db.insert(player, commit=False)
            await self._db.commit()
        except Exception as e:
            logger.debug(e)

    async def seed_events(self, n):
        try:
            olympics = await self._db.get_all(Olympic)
            for _ in range(n):
                event = Event(
                    event_id=self._faker.unique.lexify('???????'),
                    name=self._faker.sentence(nb_words=3),
                    eventtype=self._faker.word(ext_word_list=["Individual", "Team"]),
                    olympic_id=self._faker.random.choice(olympics).olympic_id,
                    is_team_event=self._faker.random_int(min=0, max=1),
                    num_players_in_team=self._faker.random_int(min=2, max=5) if self._faker.random_int(min=0, max=1) == 1 else None,
                    result_noted_in=self._faker.word(ext_word_list=["seconds", "meters", "points"])
                )
                await self._db.insert(event, commit=False)
            await self._db.commit()
        except Exception as e:
            logger.debug(e)

    async def seed_results(self, n):
        try:
            players: list[Player] = await self._db.get_all(Player)
            events: list[Event] = await self._db.get_all(Event)
            existing_pairs = set()

            for _ in range(n):
                event: Event = self._faker.random.choice(events)
                olympic: Olympic = await self._db.get_by_filter(Olympic, Olympic.olympic_id == event.olympic_id)
                valid_players: list[Player] = [p for p in players if p.birthdate.year <= olympic.year]  # Players who were born before the event's year

                if not valid_players:
                    continue  # Skip if no valid players for this event

                player = self._faker.random.choice(valid_players)

                # Ensure the player hasn't been assigned to this event already
                if (event.event_id, player.player_id) in existing_pairs:
                    continue  # Skip if this pair is already present
                
                existing_pairs.add((event.event_id, player.player_id))

                result = Result(
                    event_id=event.event_id,
                    player_id=player.player_id,
                    medal=self._faker.random.choice([None, "GOLD", "SILVER", "BRONZE"]),
                    result=self._faker.random.uniform(9.0, 100.0)
                )
                await self._db.insert(result, commit=False)
            await self._db.commit()

        except Exception as e:
            logger.debug(e)
