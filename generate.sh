#!/bin/bash

# Variables
URL="https://download.microsoft.com/download/8/a/5/8a51eee5-cd02-431c-9d78-a58b7f77c070/mde-urls.xlsx"

# Script

# Requirements
apk add python3 py3-pip git
pip install xlsx2csv

cd /root/mde-urls
mkdir ./work
rm -rf government/ region-*
wget $URL -O ./work/mde-urls.xlsx
xlsx2csv -a ./work/mde-urls.xlsx ./work

function pars_categories {
    value=$(echo $1 | tr -d '[:blank:]')
    
    case $value in
    "Common"*)
    echo "common"
    ;;

    "MicrosoftMonitoring"*)
    echo "microsoft-monitoring-agent"
    ;;

    "MicrosoftDefender"*)
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
    echo $value
    ;;
    esac

}

# Microsoft Defender for Endpoint URLs
while IFS="," read -r region category endpoint
do
    
    category=$(pars_categories "$category" | tr '[:upper:]' '[:lower:]')
    FOLDERNAME="./region-$(echo $region | tr '[:upper:]' '[:lower:]' | tr -d '[:blank:]')"
    mkdir $FOLDERNAME -p
    echo $endpoint >> "$FOLDERNAME/$category"
    echo $endpoint >> "combined.list"
done < <(cut -d "," -f2,3,5 ./work/Microsoft\ Defender\ URLs.csv | tail -n +2)

# Microsoft Defender for Endpoint URLs US Gov
while IFS="," read -r region category endpoint
do
    category=$(pars_categories "$category" | tr '[:upper:]' '[:lower:]')
    FOLDERNAME="./government/$(echo $region | tr '[:upper:]' '[:lower:]' | tr -d '[:blank:]')"
    mkdir $FOLDERNAME -p
    echo $endpoint >> "$FOLDERNAME/$category"
    echo $endpoint >> "combined.list"
done < <(cut -d "," -f2,3,5 ./work/Microsoft\ Defender\ URLs\ -\ USGov.csv | tail -n +2)

# Security Center URLs
while IFS="," read -r endpoint
do
    FOLDERNAME="./region-ww"
    echo $endpoint >> "$FOLDERNAME/security-center"
    echo $endpoint >> "combined.list"
done < <(cut -d "," -f3 ./work/Security\ Center\ URLs.csv | tail -n +2)

# Security Center URLs US Gov
while IFS="," read -r region endpoint
do
    FOLDERNAME="./government/$(echo $region | tr '[:upper:]' '[:lower:]' | tr -d '[:blank:]')"
    mkdir $FOLDERNAME -p
    echo $endpoint >> "$FOLDERNAME/security-center"
    echo $endpoint >> "combined.list"
done < <(cut -d "," -f2,3 ./work/Security\ Center\ URLs\ -\ US\ Gov.csv | tail -n +2)

rm -rf ./work

git pull
git add -A 
git commit -am "$(date)"
git tag "$(date '+%F-%s')"
git push
git push --tags
