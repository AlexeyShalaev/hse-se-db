from sqlalchemy import CHAR, Column, Date, ForeignKey, Integer

from src.models import BaseTable


class Olympic(BaseTable):
    __tablename__ = "olympics"

    olympic_id = Column(CHAR(7), primary_key=True)
    country_id = Column(CHAR(3), ForeignKey("countries.country_id"), nullable=False)
    city = Column(CHAR(50), nullable=False)
    year = Column(Integer, nullable=False)
    startdate = Column(Date, nullable=False)
    enddate = Column(Date, nullable=False)
