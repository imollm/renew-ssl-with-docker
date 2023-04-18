#!/bin/zsh

certsPath='/etc/letsencrypt/archive/ndiarealestate.com'
backendStgCertsFolder='/home/ivan/staging/NdiaRealState/backend/docker/api/nginx/ssl'
frontendStgCertsFolder='/home/ivan/staging/NdiaRealState/frontend/docker/nginx/ssl'
backendProdCertsFolder='/home/ivan/production/NdiaRealState/backend/docker/api/nginx/ssl'
frontendProdCertsFolder='/home/ivan/production/NdiaRealState/frontend/docker/nginx/ssl'

### Move expired certificates to old folder
if [ -d "${certsPath}" ]; then
    certsName=("cert" "chain" "fullchain" "privkey")
    timestamp=$(date +%s)
    echo "directory \"${certsPath}\" exists, lets move old certs"

    if [ ! -d "${certsPath}/old-${timestamp}" ]; then
        mkdir "${certsPath}/old-${timestamp}"
        echo "directory \"${certsPath}\"/old-\"${timestamp}\" exists"
    fi
    
    for cert in {certsName[@]}; do
        if [ -f "${certsPath}/${cert}1.pem" ]; then
            mv "${certsPath}/${cert}1.pem ${certsPath}/old-${timestamp}/${cert}1.pem"
            echo "\"${certsPath}\"/\"${cert}\"1.pem has been moved to \"${certsPath}\"/old-\"${timestamp}\"/\"${cert}\"1.pem"
        fi

        ### Rename renewed certificats from *2.pem to *1.pem
        if [ -f "${cert}2.pem" ]; then
            mv "${certsPath}/${cert}2.pem ${certsPath}/${cert}1.pem"
            echo "\"${certsPath}\"/\"${cert}\"2.pem \"${certsPath}\"/\"${cert}\"1.pem has been moved"
        fi
    done

    ### Copy renewed certificates to backend/frontend folders
    cp "${certsPath}/* ${backendStgCertsFolder}"
    cp "${certsPath}/* ${backendProdCertsFolder}"
    cp "${certsPath}/* ${frontendStgCertsFolder}"
    cp "${certsPath}/* ${frontendProdCertsFolder}"

    for cert in {certsName[@]}; do
      if [ -f "${backendStgCertsFolder}/${cert}" ]; then
        echo "File \"${backendStgCertsFolder}/${cert}\" exists"
      fi
      if [ -f "${backendProdCertsFolder}/${cert}" ]; then
        echo "File \"${backendProdCertsFolder}/${cert}\" exists"
      fi
      if [ -f "${frontendStgCertsFolder}/${cert}" ]; then
        echo "File \"${frontendStgCertsFolder}/${cert}\" exists"
      fi
      if [ -f "${frontendProdCertsFolder}/${cert}" ]; then
        echo "File \"${frontendProdCertsFolder}/${cert}\" exists"
      fi
    done
    

    ### Execute docker-compose down && docker-compose up -d on backend/frontend containers
    docker-compose -f "\"${backendStgCertsFolder}\"/docker-compose.staging.yml" down && \
    docker-compose -f "\"${backendStgCertsFolder}\"/docker-compose.staging.yml" up -d && \

    docker-compose -f "\"${backendStgCertsFolder}\"/docker-compose.staging.yml" down && \
    docker-compose -f "\"${backendStgCertsFolder}\"/docker-compose.staging.yml" up -d && \

    docker-compose -f "\"${backendProdCertsFolder}\"/docker-compose.production.yml" down && \
    docker-compose -f "\"${backendProdCertsFolder}\"/docker-compose.production.yml" up -d && \

    docker-compose -f "\"${frontendProdCertsFolder}\"/docker-compose.production.yml" down && \
    docker-compose -f "\"${frontendProdCertsFolder}\"/docker-compose.production.yml" up -d
fi




