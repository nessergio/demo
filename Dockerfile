# syntax=docker/dockerfile:1
FROM node:20
LABEL maintainer="Sergey@Nesterenko.net"

# Create app directory
WORKDIR /usr/src/app

COPY package*.json ./

# Install app dependencies
RUN npm install

# Bundle app source
COPY . .

# Expose the port on which the app will run
EXPOSE 3000

# Start the server 
CMD ["npm", "run", "start"]