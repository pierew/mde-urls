#!/bin/bash

# Variables
URL="https://download.microsoft.com/download/8/a/5/8a51eee5-cd02-431c-9d78-a58b7f77c070/mde-urls.xlsx"

# Script

# Requirements
apk add python3 py3-pip git
pip install xlsx2csv

mkdir ./work
wget $URL -O ./work/mde-urls.xlsx
xlsx2csv -a ./work/mde-urls.xlsx ./work

function pars_categories {
    case $1 in
    "Common"*)
    echo "common"
    ;;

    *"Monitoring"*)
    echo "microsoft-monitoring-agent"
    ;;

    *"Endpoint"*)
    echo "microsoft-defender-for-endpoint"
    ;;

    "MU"*)
    echo "microsoft-update"
    ;;

    "Malware"*)
    echo "malware-submission"
    ;;

    "Reporting"*)
    echo "reporting-and-notifications"
    ;;

    *)
    echo $1
    esac

}

# Microsoft Defender for Endpoint URLs
while IFS="," read -r region category endpoint
do
    
    category=$(pars_categories $category | tr '[:upper:]' '[:lower:]')
    FOLDERNAME="./region-$(echo $region | tr '[:upper:]' '[:lower:]' | tr -d '[:blank:]')"
    mkdir $FOLDERNAME -p
    echo $endpoint >> "$FOLDERNAME/$category"
done < <(cut -d "," -f2,3,5 ./work/Microsoft\ Defender\ URLs.csv | tail -n +2)

# Microsoft Defender for Endpoint URLs US Gov
while IFS="," read -r region category endpoint
do
    category=$(pars_categories $category | tr '[:upper:]' '[:lower:]')
    FOLDERNAME="./government/$(echo $region | tr '[:upper:]' '[:lower:]' | tr -d '[:blank:]')"
    mkdir $FOLDERNAME -p
    echo $endpoint >> "$FOLDERNAME/$category"
done < <(cut -d "," -f2,3,5 ./work/Microsoft\ Defender\ URLs\ -\ USGov.csv | tail -n +2)

# Security Center URLs
while IFS="," read -r endpoint
do
    FOLDERNAME="./region-ww"
    echo $endpoint >> "$FOLDERNAME/security-center"
done < <(cut -d "," -f3 ./work/Security\ Center\ URLs.csv | tail -n +2)

# Security Center URLs US Gov
while IFS="," read -r region endpoint
do
    FOLDERNAME="./government/$(echo $region | tr '[:upper:]' '[:lower:]' | tr -d '[:blank:]')"
    mkdir $FOLDERNAME -p
    echo $endpoint >> "$FOLDERNAME/security-center"
done < <(cut -d "," -f2,3 ./work/Security\ Center\ URLs\ -\ US\ Gov.csv | tail -n +2)

rm -rf ./work/*

git pull
git add -A 
git commit -am "$(date)"
git push