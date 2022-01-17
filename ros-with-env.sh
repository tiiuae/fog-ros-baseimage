#!/bin/bash -eu

# this file previously defined at: https://github.com/tiiuae/fogsw_configs/blob/d9c24cb475449a968c6484b8a01803288ad87e93/setup_fog.sh

# Source local variables for this script
. /enclave/drone_device_id

# Export global environment variables
export DRONE_DEVICE_ID

# Source ROS paths
. /opt/ros/${ROS_DISTRO}/setup.bash

export RMW_IMPLEMENTATION=rmw_fastrtps_cpp

# TODO: are these following two necessary? where they are defined

# Define generic ROS2 profile contiguration file location
# export FASTRTPS_DEFAULT_PROFILES_FILE=/opt/ros/${ROS_DISTRO}/DEFAULT_FASTRTPS_PROFILES.xml

# export MISSION_DATA_RECORDER_QOS_OVERRIDES="/opt/ros/${ROS_DISTRO}/share/mission-data-recorder/fog_qos_overrides.yaml"

# run actual ros command with now hopefully all the right environment details filled in
exec -- $@
