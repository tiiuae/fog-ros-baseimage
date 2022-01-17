FROM ros:foxy-ros-core

ARG ROS_DISTRO=foxy

# so we can download our own-produced components
RUN echo "deb [trusted=yes] https://ssrc.jfrog.io/artifactory/ssrc-debian-public-remote $(lsb_release -cs) fog-sw" > /etc/apt/sources.list.d/fogsw-latest.list \
	&& apt update

RUN apt install -y \
	ros-${ROS_DISTRO}-geodesy \
	ros-${ROS_DISTRO}-px4-msgs \
	ros-${ROS_DISTRO}-rclcpp

# wrapper used to launch ros with proper environment variables
COPY ros-with-env.sh /usr/bin/ros-with-env
