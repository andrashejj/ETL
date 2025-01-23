FROM python:3.11-slim

RUN apt-get update

RUN apt-get install -y --no-install-recommends curl

RUN pip install uv 

RUN uv pip install --system \
    dagster \
    dagster-dbt \
    dagster-duckdb \
    dagster-airbyte \
    dagster-postgres \
    dagster-webserver \
    dbt-core \
    dbt-duckdb \
    dbt-postgres \
    duckdb \
    pydantic \
    watchdog

WORKDIR /homes

RUN echo '#!/bin/bash\n\
if [ ! -d "/homes/homes_dm" ]; then\n\
    echo "Scaffolding new project..."\n\
    dagster-dbt project scaffold --project-name homes_dm\n\
    # cd /homes/homes_dm\n\
    dbt deps\n\
    dbt compile --profiles-dir profiles/ --project-dir . \n\
else\n\
    echo "Project already exists, skipping scaffolding"\n\
    cd /homes/homes_dm\n\
fi\n\
exec dagster-webserver -h 0.0.0.0\n\
' > /entrypoint.sh && chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]