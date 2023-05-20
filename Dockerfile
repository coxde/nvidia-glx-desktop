FROM ghcr.io/selkies-project/nvidia-glx-desktop:latest
USER root

# Use Bash as the default shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV DEBIAN_FRONTEND noninteractive\
SHELL=/bin/bash

# Install steam and fix webview issue
RUN curl -fsSL -o google-chrome-stable_current_amd64.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    curl -fsSL -o ffmpeg-release-amd64-static.tar.xz https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz && \
    tar -xf ./ffmpeg-release-amd64-static.tar.xz ffmpeg-6.0-amd64-static/ffmpeg && \
    cp -f ./ffmpeg-6.0-amd64-static/ffmpeg /usr/bin/ffmpeg && \
    apt-get update && apt-get install -y \
        tmux \
        ./google-chrome-stable_current_amd64.deb \
        steam && \
    rm -rf /var/lib/apt/lists/* && \
    mv -f /usr/bin/google-chrome /usr/bin/google-chrome.real && \
    echo '#!/bin/bash' > /usr/bin/google-chrome && \
    echo '/usr/bin/google-chrome.real --no-sandbox $@' >> /usr/bin/google-chrome && \
    chmod +x /usr/bin/google-chrome && \
    mv -f /usr/games/steam /usr/games/steam.real && \
    echo '#!/bin/bash' > /usr/games/steam && \
    echo 'ALCRO_BROWSER_PATH=/usr/bin/google-chrome /usr/games/steam.real -no-cef-sandbox $@' >> /usr/games/steam && \
    chmod +x /usr/games/steam && \
    rm -f ./google-chrome-stable_current_amd64.deb && \
    rm -f ./ffmpeg-release-amd64-static.tar.xz && \
    rm -rf ./ffmpeg-6.0-amd64-static/

# Install some useful tools
RUN  apt-get install -y \
        btop \
        ncdu \
        neofetch \
        duf

USER user
ENV SHELL /bin/bash
ENV USER user
WORKDIR /home/user

ENTRYPOINT ["/usr/bin/supervisord"]
