FROM nginx:latest
RUN mkdir -p /tmp/acme_challenge
COPY default.conf /etc/nginx/conf.d/default.conf
