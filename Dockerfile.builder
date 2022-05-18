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
# - ros-<DISTRO>-rmw-fastrtps-cpp is needed for building msgs (fog-msgs, px4-msgs)
#
# WARNING: the same FastRTPS pinning happens in Dockerfile, please update that if you change this!
#   (see the other file for rationale. we need pinning in builder also due to micrortps-agent linking directly to fastrtps)
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    curl \
    python3-bloom \
    dh-make \
    libboost-dev \
    ros-${ROS_DISTRO}-fastrtps=2.3.4-1focal.20220430.111237 \
    ros-${ROS_DISTRO}-rmw-fastrtps-cpp \
    && rm -rf /var/lib/apt/lists/*

# dedicated user because ROS builds can complain if building as root.
# TODO: fix & remove this requirement?
RUN groupadd -g $GID builder && \
    useradd -m -u $UID -g $GID -g builder builder && \
    usermod -aG sudo builder && \
    echo 'builder ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

COPY builder/packaging /packaging

ARG GO_VERSION=1.18.2

# Install golang
RUN curl -L https://golang.org/dl/go$GO_VERSION.linux-amd64.tar.gz \
    | tar -xzC /usr/local

ENV GOPATH=/go \
    GOBIN="$GOPATH/bin" \
    PATH="/usr/local/go/bin:$PATH:$GOBIN"

# Install C/C++ compiler for cgo and version control software for installing Go
# modules
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        bzr \
        git \
        mercurial \
        subversion && \
    rm -rf /var/lib/apt/lists/*

# The following enables automatic sourcing of the ROS environment. rclgo-gen
# uses the ROS environment to find ROS interface definitions.
SHELL [ "/bin/bash", "-c" ]

ENV BASH_ENV="/opt/ros/$ROS_DISTRO/setup.bash" \
    RMW_IMPLEMENTATION=rmw_fastrtps_cpp
RUN echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> /etc/bash.bashrc && \
	echo "RMW_IMPLEMENTATION=$RMW_IMPLEMENTATION" >> /etc/bash.bashrc
