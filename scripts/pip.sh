#!/bin/bash
if ! command -v pip &> /dev/null
then
    wget https://bootstrap.pypa.io/pip/2.7/get-pip.py
    python get-pip.py
fi

pip install -r requirements.txt