FROM golang:1.26 AS builder

WORKDIR /app
COPY workspace/backend/go.mod workspace/backend/go.sum ./
RUN go mod download

COPY workspace/backend ./
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /bin/backend .

FROM gcr.io/distroless/base-debian12

WORKDIR /app
COPY --from=builder /bin/backend /app/backend

ENV PORT=8080
ENV DB_PATH=/data/backend.sqlite
ENV COOKIE_SECURE=true

EXPOSE 8080

ENTRYPOINT ["/app/backend"]
