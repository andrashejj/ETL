from dagster import Definitions
from dagster_dbt import DbtCliResource
from .assets import homes_dbt_assets
from .project import homes_project
from .schedules import schedules

defs = Definitions(
    assets=[homes_dbt_assets],
    schedules=schedules,
    resources={
        "dbt": DbtCliResource(project_dir=homes_project),
    },
)