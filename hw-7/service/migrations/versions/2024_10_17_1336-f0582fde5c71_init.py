"""init

Revision ID: f0582fde5c71
Revises: 
Create Date: 2024-10-17 13:36:48.698495

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'f0582fde5c71'
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # ### commands auto generated by Alembic - please adjust! ###
    op.create_table('countries',
    sa.Column('country_id', sa.CHAR(length=3), nullable=False),
    sa.Column('name', sa.CHAR(length=40), nullable=False),
    sa.Column('area_sqkm', sa.Integer(), nullable=True),
    sa.Column('population', sa.Integer(), nullable=True),
    sa.PrimaryKeyConstraint('country_id', name=op.f('countries_pkey'))
    )
    op.create_table('olympics',
    sa.Column('olympic_id', sa.CHAR(length=7), nullable=False),
    sa.Column('country_id', sa.CHAR(length=3), nullable=False),
    sa.Column('city', sa.CHAR(length=50), nullable=False),
    sa.Column('year', sa.Integer(), nullable=False),
    sa.Column('startdate', sa.Date(), nullable=False),
    sa.Column('enddate', sa.Date(), nullable=False),
    sa.ForeignKeyConstraint(['country_id'], ['countries.country_id'], name=op.f('olympics_country_id_fkey')),
    sa.PrimaryKeyConstraint('olympic_id', name=op.f('olympics_pkey'))
    )
    op.create_table('players',
    sa.Column('player_id', sa.CHAR(length=10), nullable=False),
    sa.Column('name', sa.CHAR(length=40), nullable=False),
    sa.Column('country_id', sa.CHAR(length=3), nullable=False),
    sa.Column('birthdate', sa.Date(), nullable=False),
    sa.ForeignKeyConstraint(['country_id'], ['countries.country_id'], name=op.f('players_country_id_fkey')),
    sa.PrimaryKeyConstraint('player_id', name=op.f('players_pkey'))
    )
    op.create_table('events',
    sa.Column('event_id', sa.CHAR(length=7), nullable=False),
    sa.Column('name', sa.CHAR(length=40), nullable=False),
    sa.Column('eventtype', sa.CHAR(length=20), nullable=False),
    sa.Column('olympic_id', sa.CHAR(length=7), nullable=False),
    sa.Column('is_team_event', sa.Integer(), nullable=False),
    sa.Column('num_players_in_team', sa.Integer(), nullable=True),
    sa.Column('result_noted_in', sa.CHAR(length=100), nullable=True),
    sa.ForeignKeyConstraint(['olympic_id'], ['olympics.olympic_id'], name=op.f('events_olympic_id_fkey')),
    sa.PrimaryKeyConstraint('event_id', name=op.f('events_pkey'))
    )
    op.create_table('results',
    sa.Column('event_id', sa.CHAR(length=7), nullable=False),
    sa.Column('player_id', sa.CHAR(length=10), nullable=False),
    sa.Column('medal', sa.CHAR(length=7), nullable=True),
    sa.Column('result', sa.Float(), nullable=True),
    sa.ForeignKeyConstraint(['event_id'], ['events.event_id'], name='results_event_id_fkey'),
    sa.ForeignKeyConstraint(['player_id'], ['players.player_id'], name='results_player_id_fkey'),
    sa.PrimaryKeyConstraint('event_id', 'player_id', name='results_event_id_player_id_pkey')
    )
    # ### end Alembic commands ###


def downgrade() -> None:
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_table('results')
    op.drop_table('events')
    op.drop_table('players')
    op.drop_table('olympics')
    op.drop_table('countries')
    # ### end Alembic commands ###