from sqlalchemy import Column, Integer, CHAR, ForeignKey, CheckConstraint

from src.models import BaseTable


class Event(BaseTable):
    __tablename__ = "events"

    event_id = Column(CHAR(7), primary_key=True)
    name = Column(CHAR(40), nullable=False)
    eventtype = Column(CHAR(20), nullable=False)
    olympic_id = Column(CHAR(7), ForeignKey("olympics.olympic_id"), nullable=False)
    is_team_event = Column(Integer, CheckConstraint("is_team_event IN (0, 1)", name="events_is_team_event_check"), nullable=False)
    num_players_in_team = Column(Integer, nullable=True)
    result_noted_in = Column(CHAR(100), nullable=True)
