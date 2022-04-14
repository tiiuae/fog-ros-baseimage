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
# Packages with PKCS#11 features have fog-sw-sros component.
RUN FOG_DEB_REPO="https://ssrc.jfrog.io/artifactory/ssrc-debian-public-remote" \
	&& echo "deb [trusted=yes] ${FOG_DEB_REPO} $(lsb_release -cs) fog-sw" > /etc/apt/sources.list.d/fogsw.list \
	&& echo "deb [trusted=yes] ${FOG_DEB_REPO} $(lsb_release -cs) fog-sw-sros" >> /etc/apt/sources.list.d/fogsw-sros.list \
	&& apt update

# be careful about introducing dependencies here that already come from ros-core, because adding
# them again here means updating them to latest version, which might not be what we want?
#
# FastRTPS pinned because our SSRC repo had newer version which was incompatible with our current applications.
# WARNING: the same pinning happens in Dockerfile.builder, please update that if you change this!
# TODO: remove pinning once it's no longer required
RUN apt install -y \
	ros-${ROS_DISTRO}-geodesy \
	ros-${ROS_DISTRO}-tf2-ros \
	# Packages with PKCS#11 feature
	ros-${ROS_DISTRO}-fastcdr=1.0.20-5~git20220310.f65f034 \
	ros-${ROS_DISTRO}-fastrtps=2.5.0-7~git20220310.4ca1f95 \
	ros-${ROS_DISTRO}-fastrtps-cmake-module=1.2.1-6~git20220310.67ed436 \
	ros-${ROS_DISTRO}-foonathan-memory-vendor=1.1.0-4~git20220310.bbb8a5c \
	ros-${ROS_DISTRO}-rmw-fastrtps-cpp=5.0.0-7~git20220310.8684e20 \
	ros-${ROS_DISTRO}-rmw-fastrtps-dynamic-cpp=5.0.0-7~git20220310.8684e20 \
	ros-${ROS_DISTRO}-rmw-fastrtps-shared-cpp=5.0.0-7~git20220310.8684e20 \
	ros-${ROS_DISTRO}-rosidl-typesupport-fastrtps-c=1.2.1-6~git20220310.67ed436 \
	ros-${ROS_DISTRO}-rosidl-typesupport-fastrtps-cpp=1.2.1-6~git20220310.67ed436

# install packages from release 6.1
RUN apt install -y \
	ros-${ROS_DISTRO}-fog-msgs=0.0.8-42~git20220104.1d2cf3f \
	ros-${ROS_DISTRO}-px4-msgs=3.0.0-15~git20220104.c12fcdf

# wrapper used to launch ros with proper environment variables
COPY ros-with-env.sh /usr/bin/ros-with-env
