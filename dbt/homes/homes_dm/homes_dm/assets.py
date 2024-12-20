from dagster import AssetExecutionContext
from dagster_dbt import DbtCliResource, dbt_assets

from .project import homes_project


@dbt_assets(manifest=homes_project.manifest_path)
def homes_dbt_assets(context: AssetExecutionContext, dbt: DbtCliResource):
    yield from dbt.cli(["build"], context=context).stream()
    