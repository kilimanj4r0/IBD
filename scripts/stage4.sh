#!/bin/bash
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
streamlit run ${SCRIPTPATH}/streamlit/main.py --server.port 60001
