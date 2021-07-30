FROM node:12
WORKDIR /app
ADD nodejs/index.js nodejs/package.json /app/
RUN npm install
EXPOSE 3000
CMD npm start