FROM ubuntu:bionic

RUN apt update && apt-get install -y \
    git build-essential mingw-w64 clang curl python python3 pkg-config \
    libcurl4-openssl-dev libfreetype6-dev libx11-dev libxext-dev \
    libxrandr-dev libxcomposite-dev libxinerama-dev libxcursor-dev \
    libjack-dev libasound2-dev ladspa-sdk \
    libcurl4-openssl-dev libgtk2.0-dev \
    libfuse2 imagemagick \
    lua-ldoc lua-markdown zip unzip
RUN update-alternatives --set x86_64-w64-mingw32-gcc /usr/bin/x86_64-w64-mingw32-gcc-posix; \
    update-alternatives --set x86_64-w64-mingw32-g++ /usr/bin/x86_64-w64-mingw32-g++-posix; \
    update-alternatives --set i686-w64-mingw32-gcc /usr/bin/i686-w64-mingw32-gcc-posix; \
    update-alternatives --set i686-w64-mingw32-g++ /usr/bin/i686-w64-mingw32-g++-posix
RUN apt clean && apt autoclean

ADD . /depends
RUN cd /depends && make HOST=x86_64-pc-linux-gnu
RUN cd /depends && make HOST=x86_64-w64-mingw32
RUN cd /depends && make HOST=i686-w64-mingw32

RUN curl -L https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage > /usr/bin/linuxdeploy-x86_64.AppImage && \
    chmod +x /usr/bin/linuxdeploy-x86_64.AppImage && \
    ln -s /usr/bin/linuxdeploy-x86_64.AppImage /usr/bin/linuxdeploy

RUN mkdir -p /dist /project
VOLUME [ "/dist", "/project" ]
