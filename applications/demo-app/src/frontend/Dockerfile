FROM golang:1.26-alpine AS build

WORKDIR /src

COPY go.mod ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags="-s -w" -o /out/demo-app .

FROM alpine:3.20

RUN addgroup -S app && adduser -S -G app app

WORKDIR /app

COPY --from=build /out/demo-app /app/demo-app

ENV PORT=3000
ENV BUILD_BRANCH=unknown

EXPOSE 3000

USER app

ENTRYPOINT ["/app/demo-app"]
