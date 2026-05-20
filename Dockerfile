# multi stage dockerfile for go app to reduce size of the final image by using distroless as the base image
# and also improving the security by using distroless which does not include any package manager or shell and only includes the necessary files to run the application 

FROM golang:1.22.5 as base

WORKDIR /app

COPY go.mod .

#downloading dependencies before copying the entire code to leverage docker cache
RUN go mod download

COPY . .

RUN go build -o main .

# final stage - Distroless image

FROM gcr.io/distroless/base

COPY --from=base /app/main .

#static content are outside the binary like html, css, js files so we need to copy them separately
COPY --from=base /app/static ./static

EXPOSE 8080

CMD [ "./main" ]
