# syntax=docker/dockerfile:1.4
FROM node:18-alpine AS builder
WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .

ARG EVIDENCE_SOURCE__important_db__host
ARG EVIDENCE_SOURCE__important_db__port
ARG EVIDENCE_SOURCE__important_db__database
ARG EVIDENCE_SOURCE__important_db__user
ARG EVIDENCE_SOURCE__important_db__password

ENV EVIDENCE_SOURCE__important_db__host=$EVIDENCE_SOURCE__important_db__host
ENV EVIDENCE_SOURCE__important_db__port=$EVIDENCE_SOURCE__important_db__port
ENV EVIDENCE_SOURCE__important_db__database=$EVIDENCE_SOURCE__important_db__database
ENV EVIDENCE_SOURCE__important_db__user=$EVIDENCE_SOURCE__important_db__user
ENV EVIDENCE_SOURCE__important_db__password=$EVIDENCE_SOURCE__important_db__password

RUN --network=host npm run sources
RUN npm run build:strict

FROM node:18-alpine AS runtime
WORKDIR /app
RUN npm install -g serve

COPY --from=builder /app/.evidence/template/build ./build

EXPOSE 3000
CMD ["serve", "build", "-l", "3000", "-s"]
