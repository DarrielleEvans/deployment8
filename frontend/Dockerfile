FROM node:10

RUN git clone https://github.com/DarrielleEvans/deployment8.git

WORKDIR /deployment8/frontend

RUN npm install

EXPOSE 3000

CMD ["npm", "start"]
