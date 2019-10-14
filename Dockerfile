#first stage - builder
FROM golang:1.13.1-stretch as setup

ENV GO111MODULE=on
WORKDIR /app/grpc-server

COPY go.mod .
COPY go.sum .

RUN go mod download

COPY ./routeguide/ ./routeguide/
COPY ./testdata/ ./testdata/
COPY ./server.go .

FROM setup as builder

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o server

#second stage
FROM alpine:latest as executable
COPY --from=builder /app/grpc-server/server /app/
WORKDIR /app/

ENTRYPOINT ["/app/server"]
CMD ["--json_db_file", "route_guide_db.json"]

EXPOSE 10000

FROM setup as testrunner

ENTRYPOINT ["go"]
CMD ["test", "./..."]