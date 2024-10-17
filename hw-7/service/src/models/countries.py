from sqlalchemy import CHAR, Column, Integer

from src.models import BaseTable


class Country(BaseTable):
    __tablename__ = "countries"

    country_id = Column(CHAR(3), primary_key=True)
    name = Column(CHAR(40), nullable=False)
    area_sqkm = Column(Integer, nullable=True)
    population = Column(Integer, nullable=True)
