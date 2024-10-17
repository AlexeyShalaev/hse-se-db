from sqlalchemy import CHAR, Column, Date, ForeignKey

from src.models import BaseTable


class Player(BaseTable):
    __tablename__ = "players"

    player_id = Column(CHAR(10), primary_key=True)
    name = Column(CHAR(40), nullable=False)
    country_id = Column(CHAR(3), ForeignKey("countries.country_id"), nullable=False)
    birthdate = Column(Date, nullable=False)
