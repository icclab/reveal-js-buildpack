FROM ubuntu:18.04

RUN apt-get -qqy update
RUN apt-get -qqy install git curl

# Install nodejs
RUN curl -sL https://deb.nodesource.com/setup_9.x | bash -
RUN apt-get -qqy install nodejs

# Install reveal.js
WORKDIR /opt
RUN git clone https://github.com/christofmarti/reveal.js.git presentation
WORKDIR /opt/presentation
RUN npm install

# Add content
ADD index.html /opt/presentation/index.html
# you may need to add additional content like images
# ADD images /opt/presentation/images
WORKDIR /opt/presentation

EXPOSE 8000
ENV GRUNT_PORT 8000
ENV GRUNT_BROWSER false
CMD [ "npm", "start" ]
