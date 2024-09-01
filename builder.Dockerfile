# Use Ubuntu 20.04 as the base image
FROM ubuntu:20.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV ANDROID_HOME=/opt/android-sdk
ENV ANDROID_NDK_HOME=/opt/android-ndk
ENV PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin:/usr/local/go/bin:/go/bin

# Install required packages
RUN apt-get update && \
    apt-get install -y wget unzip make zip git curl gnupg && \
    apt-get clean

# Install Java 17 (OpenJDK)
RUN apt-get update && \
    apt-get install -y openjdk-17-jdk && \
    apt-get clean

# Install Android SDK
RUN mkdir -p /opt/android-sdk/cmdline-tools && \
    cd /opt/android-sdk/cmdline-tools && \
    wget https://dl.google.com/android/repository/commandlinetools-linux-7583922_latest.zip && \
    unzip commandlinetools-linux-7583922_latest.zip && \
    rm commandlinetools-linux-7583922_latest.zip && \
    mv cmdline-tools latest && \
    mkdir -p ~/.android && \
    touch ~/.android/repositories.cfg && \
    yes | sdkmanager --licenses && \
    sdkmanager "platform-tools" "platforms;android-30" "build-tools;30.0.3"

# Install Android NDK
RUN mkdir -p /opt/android-ndk && \
    cd /opt/android-ndk && \
    wget https://dl.google.com/android/repository/android-ndk-r25c-linux.zip && \
    unzip android-ndk-r25c-linux.zip && \
    rm android-ndk-r25c-linux.zip

# Install Go 1.21
RUN wget https://go.dev/dl/go1.21.13.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.21.13.linux-amd64.tar.gz && \
    rm go1.21.13.linux-amd64.tar.gz

# Install Go packages
RUN /usr/local/go/bin/go install golang.org/x/lint/golint@latest && \
    /usr/local/go/bin/go install github.com/go-bindata/go-bindata/...@latest

# Verify Go binaries installation
RUN /usr/local/go/bin/go env -w GOBIN=/usr/local/go/bin && \
    /usr/local/go/bin/go install github.com/go-bindata/go-bindata/...@latest && \
    /usr/local/go/bin/go-bindata --version

# Set working directory
WORKDIR /workspace

# Copy the build script and source code
COPY . .

# Ensure Go binaries are in the PATH and run the build script
RUN  bash build.sh

# Default command
CMD ["bash"]