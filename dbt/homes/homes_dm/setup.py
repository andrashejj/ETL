from setuptools import find_packages, setup

setup(
    name="homes_dm",
    version="0.0.1",
    packages=find_packages(),
    package_data={
        "homes_dm": [
            "dbt-project/**/*",
        ],
    },
    install_requires=[
        "dagster",
        "dagster-cloud",
        "dagster-dbt",
        "dbt-postgres<1.9",
    ],
    extras_require={
        "dev": [
            "dagster-webserver",
        ]
    },
)