#!/bin/bash -eu

# this file previously defined at: https://github.com/tiiuae/fogsw_configs/blob/d9c24cb475449a968c6484b8a01803288ad87e93/setup_fog.sh

# Source local variables for this script
. /enclave/drone_device_id

# Export global environment variables
export DRONE_DEVICE_ID

# Source ROS paths

set +u # poorly coded script don't survive erroring on unbound variables (mentions AMENT_TRACE_SETUP_FILES)
. /opt/ros/${ROS_DISTRO}/setup.bash
set -u

export RMW_IMPLEMENTATION=rmw_fastrtps_cpp

# MISSION_DATA_RECORDER_QOS_OVERRIDES is needed by mission-data-recorder only.
# FASTRTPS_DEFAULT_PROFILES_FILE defines FastDDS default profiles used in FOG.
# Define generic ROS2 profile contiguration file location
export FASTRTPS_DEFAULT_PROFILES_FILE=/enclave/DEFAULT_FASTRTPS_PROFILES.xml

# run actual ros command with now hopefully all the right environment details filled in
exec -- $@
