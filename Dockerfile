ARG ROS_DISTRO=galactic

FROM ros:${ROS_DISTRO}-ros-core

ARG UID=1000
ARG GID=1000

# so we can download our own-produced components
RUN FOG_DEB_REPO="https://ssrc.jfrog.io/artifactory/ssrc-debian-public-remote" \
    && echo "deb [trusted=yes] ${FOG_DEB_REPO} $(lsb_release -cs) fog-sw" > /etc/apt/sources.list.d/fogsw.list \
    && echo "deb [trusted=yes] ${FOG_DEB_REPO} $(lsb_release -cs) fog-sw-sros" >> /etc/apt/sources.list.d/fogsw-sros.list \
    && apt update

RUN apt install -y --no-install-recommends \
    ros-${ROS_DISTRO}-geodesy \
    ros-${ROS_DISTRO}-tf2-ros \
    ros-${ROS_DISTRO}-fastcdr=1.0.20-5~git20220310.f65f034 \
    ros-${ROS_DISTRO}-fastrtps=2.5.0-7~git20220310.4ca1f95 \
    ros-${ROS_DISTRO}-fastrtps-cmake-module=1.2.1-6~git20220310.67ed436 \
    ros-${ROS_DISTRO}-foonathan-memory-vendor=1.1.0-4~git20220310.bbb8a5c \
    ros-${ROS_DISTRO}-rmw-fastrtps-cpp=5.0.0-7~git20220310.8684e20 \
    ros-${ROS_DISTRO}-rmw-fastrtps-dynamic-cpp=5.0.0-7~git20220310.8684e20 \
    ros-${ROS_DISTRO}-rmw-fastrtps-shared-cpp=5.0.0-7~git20220310.8684e20 \
    ros-${ROS_DISTRO}-rosidl-typesupport-fastrtps-c=1.2.1-6~git20220310.67ed436 \
    ros-${ROS_DISTRO}-rosidl-typesupport-fastrtps-cpp=1.2.1-6~git20220310.67ed436 \
    # install packages from release 6.1.0
    ros-${ROS_DISTRO}-fog-msgs=0.0.8-42~git20220104.1d2cf3f \
    ros-${ROS_DISTRO}-px4-msgs=3.0.0-15~git20220104.c12fcdf \
    # clean up to reduce size of the image
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

# not clear yet if runner user needs sudo credentials
RUN groupadd -g $GID runner && \
    useradd -m -u $UID -g $GID -g runner runner

# wrapper used to launch ros with proper environment variables
COPY ros-with-env.sh /usr/bin/ros-with-env
