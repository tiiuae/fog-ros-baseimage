ARG ROS_DISTRO=galactic

FROM ros:${ROS_DISTRO}-ros-core

# Use FastRTPS as ROS pub/sub messaging subsystem ("middleware") implementation.
# https://docs.ros.org/en/foxy/How-To-Guides/Working-with-multiple-RMW-implementations.html#specifying-rmw-implementations
# (an alternative value could be "rmw_cyclonedds_cpp".)
ENV RMW_IMPLEMENTATION=rmw_fastrtps_cpp

# Configuration for FastRTPS. don't put it in root or workdir of an app because if ENV points to it
# and it's in app's workdir, it'll get read twice and errors happen.
COPY DEFAULT_FASTRTPS_PROFILES.xml /etc/
ENV FASTRTPS_DEFAULT_PROFILES_FILE=/etc/DEFAULT_FASTRTPS_PROFILES.xml

# so we can download our own-produced components
RUN echo "deb [trusted=yes] https://ssrc.jfrog.io/artifactory/ssrc-debian-public-remote $(lsb_release -cs) fog-sw" > /etc/apt/sources.list.d/fogsw-latest.list \
	&& apt update

# be careful about introducing dependencies here that already come from ros-core, because adding
# them again here means updating them to latest version, which might not be what we want?
#
# FastRTPS pinned because our SSRC repo had newer version which was incompatible with our current applications.
# TODO: remove pinning once it's no longer required
RUN apt install -y \
	ros-${ROS_DISTRO}-geodesy \
	ros-${ROS_DISTRO}-tf2-ros \
	ros-${ROS_DISTRO}-fastrtps=2.3.4-1focal.20220210.213911 \
	ros-${ROS_DISTRO}-rmw-fastrtps-cpp

# install packages from release 6.0.1
RUN apt install -y \
	ros-${ROS_DISTRO}-fog-msgs=0.0.8-42~git20220104.1d2cf3f \
	ros-${ROS_DISTRO}-px4-msgs=3.0.0-15~git20220104.c12fcdf

# wrapper used to launch ros with proper environment variables
COPY ros-with-env.sh /usr/bin/ros-with-env
