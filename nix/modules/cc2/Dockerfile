FROM cm2network/steamcmd:root

# Install Wine and Xvfb (Virtual Framebuffer)
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    wine \
    wine32 \
    wine64 \
    xvfb \
    xauth \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set up environment
ENV APP_ID=1489630
ENV SERVER_DIR=/home/steam/cc2_server
ENV LOG_LOC=/home/steam/logs

RUN mkdir -p $LOG_LOC

# Copy the server files
COPY ./game_files $SERVER_DIR

WORKDIR "$SERVER_DIR"

# Expose the default ports
EXPOSE 25565-25568/udp

# Run via xvfb to avoid windowing errors
CMD ["sh", "-c", "xvfb-run --auto-servernum wine dedicated_server.exe | tee $LOG_LOC/$(date +%Y-%m-%d-%H:%M:%S).log"]
