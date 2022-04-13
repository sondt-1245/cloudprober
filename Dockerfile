FROM golang:1.17-alpine as build

WORKDIR /build

COPY go.mod go.sum ./

RUN go mod download

COPY . .

ENV CGO_ENABLED=0

RUN go build -ldflags "-s -w" -o _output/cloudprober ./cmd/cloudprober.go

FROM crazymax/alpine-s6-dist:3.15-3.0.0.2 as s6

FROM alpine:3.15

RUN addgroup -S app && adduser -S -G app app

COPY ./docker/rootfs /

COPY --from=s6 / /

COPY --from=build /build/_output/ /usr/local/bin/

USER root

ENTRYPOINT [ "docker-entrypoint" ]

CMD []
