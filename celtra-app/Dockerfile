FROM nginx
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y vim curl


RUN echo "daemon off;" >> /etc/nginx/nginx.conf

COPY . /usr/share/nginx/html
CMD sleep 15 && nginx