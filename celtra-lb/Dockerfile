FROM nginx
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y vim curl

RUN rm /etc/nginx/conf.d/default.conf
COPY . /etc/nginx/conf.d

RUN echo "daemon off;" >> /etc/nginx/nginx.conf
CMD nginx