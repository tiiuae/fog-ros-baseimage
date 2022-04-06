# ROS2 builder base image.
# This image can be used to build FOG ROS2 nodes. Referenced from concrete projects like:
#    FROM ghcr.io/tiiuae/fog-ros-baseimage:builder-latest AS builder
#

# please don't use this as dynamic build argument from outside of this file.
# this is more of a shared constant-like type situation in this file.
ARG ROS_DISTRO="galactic"

FROM ros:${ROS_DISTRO}-ros-base

WORKDIR /main_ws/src

# FIXME: these can be removed after '$ groupadd builder' is removed
ARG UID=1001
ARG GID=1001

# needs to be done before FastRTPS installation because we seem to have have newer version of that
# package in our repo. also fast-dds-gen seems to only be available from this repo.
RUN echo "deb [trusted=yes] https://ssrc.jfrog.io/artifactory/ssrc-debian-public-remote $(lsb_release -cs) fog-sw" > /etc/apt/sources.list.d/fogsw-latest.list

# Install build dependencies
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    curl \
    python3-bloom \
    fakeroot \
    dh-make \
    libboost-dev \
    ros-${ROS_DISTRO}-rmw-fastrtps-cpp \
    && rm -rf /var/lib/apt/lists/*

# dedicated user because ROS builds can complain if building as root.
# TODO: fix & remove this requirement?
RUN groupadd -g $GID builder && \
    useradd -m -u $UID -g $GID -g builder builder && \
    usermod -aG sudo builder && \
    echo 'builder ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

COPY builder/packaging /packaging
