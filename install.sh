#!/bin/bash
BRed='\033[1;31m' 
URed='\033[4;31m' 
BPurple='\033[1;35m'      
BCyan='\033[1;36m'        
NC='\033[0m' # No Color

echo "This script will install Airflow ${URed}WITHOUT${NC} the example dags."
sleep 5

export AIRFLOW_HOME="/workspaces/sp500_etl_pipeline/airflow"

AIRFLOW_VERSION=2.5.1
PYTHON_VERSION="$(python --version | cut -d " " -f 2 | cut -d "." -f 1-2)"
echo "Installing Airflow Version $AIRFLOW_VERSION, with Python $PYTHON_VERSION"
CONSTRAINT_URL="https://raw.githubusercontent.com/apache/airflow/constraints-${AIRFLOW_VERSION}/constraints-${PYTHON_VERSION}.txt"
pip install --upgrade pip  &&\
	pip install -r requirements.txt
pip install "apache-airflow==${AIRFLOW_VERSION}" --constraint "${CONSTRAINT_URL}"

# airflow db init
# airflow db upgrade
# echo -e "Changing value of ${BRed}WTF_CSRF_ENABLED${NC} in webserver_config.py to ${BPurple}False${NC}"
# sed -i -e '/WTF_CSRF_ENABLED =/ s/= .*/= False/' ${AIRFLOW_HOME}/webserver_config.py
# echo -e "Changing value of ${BRed}load_examples${NC} in airflow.cfg.py to ${BPurple}False${NC}"
# sed -i -e '/load_examples =/ s/= .*/= False/' ${AIRFLOW_HOME}/airflow.cfg
# echo -e "Changing value of ${BRed}dag_dir_list_interval${NC} in airflow.cfg.py to ${BPurple}2${NC}"
# sed -i -e '/dag_dir_list_interval =/ s/= .*/= 2/' ${AIRFLOW_HOME}/airflow.cfg
# echo -e "Changing value of ${BRed}worker_refresh_batch_size${NC} in airflow.cfg.py to ${BPurple}0${NC}"
# sed -i -e '/worker_refresh_batch_size =/ s/= .*/= 0/' ${AIRFLOW_HOME}/airflow.cfg
# echo -e "Changing value of ${BRed}worker_refresh_interval${NC} in airflow.cfg.py to ${BPurple}0${NC}"
# sed -i -e '/worker_refresh_interval =/ s/= .*/= 0/' ${AIRFLOW_HOME}/airflow.cfg
# echo -e "Changing value of ${BRed}workers$ in airflow.cfg.py to ${BPurple}2${NC}"
# sed -i -e '/workers =/ s/= .*/= 2/' ${AIRFLOW_HOME}/airflow.cfg

# airflow users create \
# --username admin \
# --firstname FIRST_NAME \
# --lastname LAST_NAME \
# --role Admin \
# --email admin@example.org \
# --password password
# airflow webserver -D
# airflow scheduler -D