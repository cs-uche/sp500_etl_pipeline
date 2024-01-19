#!/usr/bin/env python3
# IMPORTS
from datetime import date
from dotenv import load_dotenv
import pandas as pd
import os
from airflow.operators.python import PythonOperator
from airflow.operators.bash import BashOperator
from airflow import DAG
from airflow.utils.dates import days_ago

# Path to the .env file
ENV_PATH = '/workspaces/sp500_etl_pipeline/.env'
# Load the environment variables from the .env file
load_dotenv(ENV_PATH)

# db credentials
TABLE_NAME =os.getenv('TABLE_NAME')
# directories
FILES_PATH = os.getenv('FILES_PATH')
DB_PATH = os.getenv('DB_PATH')


def transform_data():
    """
    Transforms the data by extracting the sector and count of each sector occurrence from a CSV file.

    Reads an input CSV file containing S&P 500 data and groups the records by sector. It then calculates
    the count of occurrences for each sector. The transformed data is saved to an output CSV file with
    the sector, count, and current date.

    Returns:
        None
    """
    today = date.today()
    in_file = f"{FILES_PATH}/sp500_extract.csv"
    out_file = f"{FILES_PATH}/sp500_transformed.csv"
    df = pd.read_csv(in_file)

    sp500_df = df.groupby(["Sector"])["Sector"].count().reset_index(name="Count")
    sp500_df['Date'] = today.strftime('%Y-%m-%d')
    sp500_df.to_csv(out_file, index=False)


# ARGUMENTS
default_args = {
    'owner':'admin',
    'retries':1,
    'catchup':False,
    'start_date':days_ago(0),
}
    
# DAG DEFINITION
dag = DAG(
    'sp500_etl_dag',
    schedule_interval='0 6 * * 1-5',
    default_args=default_args,
)

# TASK DEFINITION
extract = BashOperator(
    task_id='extract',
    bash_command='mkdir -p {{params.FILES_PATH}} && \
    wget -c https://datahub.io/core/s-and-p-500-companies/r/constituents.csv -O \
        {{ params.FILES_PATH }}/sp500_extract.csv',
    params={'FILES_PATH': FILES_PATH},
    dag=dag,
)

# TASK DEFINITION
transform = PythonOperator(
    task_id='transform',
    python_callable=transform_data,
    dag=dag,
)

# TASK DEFINITION
load = BashOperator(
    task_id='load',
    bash_command = 'sqlite3 {{params.DB_PATH}} <<EOF\n.read create_table.sql\n.quit\nEOF' \
                   '\nsqlite3 {{params.DB_PATH}} -cmd ".mode csv" -cmd ".import --skip 1 {{params.FILES_PATH}}/sp500_transformed.csv {{params.TABLE_NAME}}"',
    params={'FILES_PATH': FILES_PATH, 'DB_PATH': DB_PATH, 'TABLE_NAME': TABLE_NAME},
    dag=dag,
)

# TASK PIPELINE
extract >> transform >> load