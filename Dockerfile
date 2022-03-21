ARG ROS_DISTRO=galactic

FROM ros:${ROS_DISTRO}-ros-core

ARG UID=1000
ARG GID=1000

# so we can download our own-produced components
RUN echo "deb [trusted=yes] https://ssrc.jfrog.io/artifactory/ssrc-debian-public-remote $(lsb_release -cs) fog-sw" > /etc/apt/sources.list.d/fogsw-latest.list \
	&& apt update

RUN apt install -y \
	ros-${ROS_DISTRO}-geodesy \
	ros-${ROS_DISTRO}-rclcpp \
	ros-${ROS_DISTRO}-tf2-ros \
	ros-${ROS_DISTRO}-rmw-fastrtps-cpp

# install packages from release 6.0.1
RUN apt install -y \
	ros-${ROS_DISTRO}-fog-msgs=0.0.8-42~git20220104.1d2cf3f \
	ros-${ROS_DISTRO}-px4-msgs=3.0.0-15~git20220104.c12fcdf

# not clear yet if runner user needs sudo credentials
RUN groupadd -g $GID runner && \
    useradd -m -u $UID -g $GID -g runner runner

# wrapper used to launch ros with proper environment variables
COPY ros-with-env.sh /usr/bin/ros-with-env
