FROM alpine:3.13

# Install required packages

RUN apk add --no-cache ca-certificates && update-ca-certificates
RUN apk add --no-cache tzdata

# Set the timezone
ENV TZ=Europe/Berlin

# Copy the Go binaries
COPY ./dist/bin/pgrok_linux_amd64  /usr/local/bin/pgrok
COPY ./dist/bin/pgrokd_linux_amd64  /usr/local/bin/pgrokd


CMD [ "pgrok" ]