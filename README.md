# Renew SSL certificates through Docker containers

We need two containers:

- Web server listening to port 80, it's for response the Let's encrypt request triggered by the following container.
- Let's encrypt container to make the request to renew the certificates.

We have the following files:

##### For Web Server container

- `Dockerfile`
- `default.conf`
- `docker-compose.yml`

##### For Let's Encrypt container

- `docker-compose-le.yml`

##### Instructions

1. Run `docker-compose -f docker-compose.yml up` - to start the web server and wait for Let's Encrypt request. Don't pass param `-d` on this way we could check the logs on our terminal.
2. Run `docker-compose -f docker-compose-le.yml up` - to make the request to Let's Encrypt and then Let's Encrypt makes sure that our domain is listening to port 80 and then renew certificates. Don't pass param `-d` on this way we could check the logs on our terminal.

##### Useful commands

To remove container + remove image + run container of Web Server.

Set the environment variables to the correct names.

```shell
CONTAINER_NAME=our_container_name
IMAGE_REPOSITORY_NAME=our_repository_name

docker rm $(docker ps -aqf name=$CONTAINER_NAME) && \
docker rmi $(docker images --quiet --filter=reference=$IMAGE_REPOSITORY_NAME) && \
docker-compose -f docker-compose.yml up
```

# To create for the first time the SSL certificates

Just change `docker-compose-le.yml` to (only change command):

```yml
version: "3.3"

services:
  letsencrypt:
    container_name: 'certbot-service'
    image: certbot/certbot:v1.17.0
    command: sh -c "certbot certonly --webroot -w /tmp/acme_challenge -d <YOUR_DOMAIN> --text --agree-tos --email <YOUR_EMAIL> --rsa-key-size 4096 --verbose --keep-until-expiring --preferred-challenges=http"
    entrypoint: ""
    volumes:
      - /etc/letsencrypt:/etc/letsencrypt
      - /tmp/acme_challenge:/tmp/acme_challenge
```
