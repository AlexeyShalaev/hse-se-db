from sqlalchemy import CHAR, Column, Float, ForeignKeyConstraint, PrimaryKeyConstraint

from src.models import BaseTable


class Result(BaseTable):
    __tablename__ = "results"

    event_id = Column(CHAR(7))
    player_id = Column(CHAR(10))
    medal = Column(CHAR(7), nullable=True)
    result = Column(Float, nullable=True)

    __table_args__ = (
        PrimaryKeyConstraint("event_id", "player_id", name="results_event_id_player_id_pkey"),
        ForeignKeyConstraint(["event_id"], ["events.event_id"], name="results_event_id_fkey"),
        ForeignKeyConstraint(["player_id"], ["players.player_id"], name="results_player_id_fkey"),
    )
