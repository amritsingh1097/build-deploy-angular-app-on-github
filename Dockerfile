# Container image to run the code
FROM alpine:3.10

# Add git dependency
RUN apk add --no-cache node git

# Copy the code file from the action repository to the filesystem path "/" of the container
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

# Code file to execute when the docker container starts up
ENTRYPOINT ["/entrypoint.sh"]
