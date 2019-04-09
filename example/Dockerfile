FROM ubuntu:18.04

RUN apt-get -qqy update
RUN apt-get -qqy install git nodejs npm
WORKDIR /opt

# Install reveal.js
RUN git clone https://github.com/christofmarti/reveal.js.git presentation
WORKDIR /opt/presentation
RUN npm install -g grunt-cli
RUN npm install
RUN sed -i "s/port: port/port: port,\n\t\t\t\t\thostname: \'\'/g" Gruntfile.js

# Add content
ADD index.html /opt/presentation/index.html
# you may need to add additional content like images
# ADD images /opt/presentation/images
WORKDIR /opt/presentation

EXPOSE 8000
CMD [ "grunt", "serve" ]
