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

# Inject chat widget into all pages post-build
COPY static/chat-widget.js .evidence/template/build/chat-widget.js
RUN find .evidence/template/build -name "*.html" -exec \
    sed -i 's|</body>|<script src="/chat-widget.js"></script></body>|' {} \;

FROM nginx:alpine AS runtime

COPY --from=builder /app/.evidence/template/build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

ARG DASHBOARD_USER=important
ARG DASHBOARD_PASSWORD=Adminimportant!
RUN apk add --no-cache apache2-utils && \
    htpasswd -bc /etc/nginx/.htpasswd "${DASHBOARD_USER}" "${DASHBOARD_PASSWORD}" && \
    apk del apache2-utils

EXPOSE 3000
CMD ["nginx", "-g", "daemon off;"]
