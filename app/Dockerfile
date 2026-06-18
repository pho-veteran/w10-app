FROM node:20-alpine

RUN apk upgrade --no-cache \
  && npm install -g npm@latest \
  && npm cache clean --force

WORKDIR /usr/src/app

COPY package*.json ./
RUN npm ci --omit=dev && npm cache clean --force

COPY . .

ENV PORT=3000
EXPOSE 3000

USER node

CMD ["node", "server.js"]
