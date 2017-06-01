![alt text](https://raw.githubusercontent.com/ckimdev/celtra/master/diagram2.jpg)
# Dependencies
1. [Aws-cli](https://aws.amazon.com/cli/)
2. AWS credential to access the registry (private)
3. [Docker](https://www.docker.com/)

# celtra-lb

**Celtra-lb** is a docker code for Nginx reverse proxy that
1. Listens on port 80
2. Routes traffic to port 8080 and/or 8081


# celtra-app
**celtra-app** is a docker code for...
1. An extremely simple web app that shows stock quote (high,low,open,close) when the user types in stock symbol.
2. Built with
   * HTML + CSS + Vuejs
   * Nginx webserver


