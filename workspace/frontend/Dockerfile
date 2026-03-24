FROM node:24-alpine AS builder

WORKDIR /app
COPY workspace/frontend/package.json workspace/frontend/pnpm-lock.yaml ./
RUN corepack enable && pnpm install --frozen-lockfile

COPY workspace/frontend ./
ARG VITE_API_BASE_URL=
ENV VITE_API_BASE_URL=$VITE_API_BASE_URL
RUN corepack enable && pnpm run build

FROM nginx:1.29-alpine

COPY workspace/frontend/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 80
