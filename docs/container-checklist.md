Container checklist
===================

Golden examples
---------------

These repos are good examples⭐ of how these checklist principles are applied in practice:

- [rplidar](https://github.com/tiiuae/rplidar_ros2/tree/container-v2) (container-v2 branch, look for the `Dockerfile`)
- [mavlink-router](https://github.com/tiiuae/mavlink-router): is not a ROS node (and thus doesn't
  use the base image), but the `Dockerfile` uses multi-stage builds and the build process is simple.


Containers' status
------------------

When all of these are ready, we're able to get rid of FOG Ubuntu:

| Level | Program                                                                                       | Notes                          |
|-------|-----------------------------------------------------------------------------------------------|--------------------------------|
| 0     | [micrortps-agent](https://github.com/tiiuae/px4_ros_com/tree/DP-2046-containerize)            | ✅ ready for flight test       |
| 0     | [mocap_pose](https://github.com/tiiuae/mocap_pose/tree/DP-2044-container)                     | ✅ ready for flight test       |
| 0     | [rplidar](https://github.com/tiiuae/rplidar_ros2/blob/DP-2048-container/Dockerfile)           | ✅ ready for flight test       |
| 0     | mavlink-router                                                                                | (already good, ready for flight test) |
| 0     | [control-interface](https://github.com/tiiuae/control_interface/tree/DP-2042-container)       | ✅ ready for flight test       |
| 0     | [octomap-server](https://github.com/tiiuae/octomap_server2/blob/DP-2043-container/Dockerfile) | ✅ ready for flight test       |
| 0     | [navigation](https://github.com/tiiuae/navigation/tree/DP-2047-container)                     | ✅ ready for flight test       |
| 0     | [fog-bumper](https://github.com/tiiuae/fog_bumper/tree/DP-2050-container)                     | ✅ ready for flight test       |
| 0     | depthai_ctrl                                                                                  | Jari? (PoC: compiles)          |
| 0     | cloud-link                                                                                    | (done earlier)                 |
| 0     | mission-engine                                                                                | (done earlier)                 |
| 0     | provisioning-agent                                                                            | (done earlier)                 |
| 0     | agent-protocol-splitter                                                                       | (done earlier)                 |
| 0     | mission-data-recorder                                                                         | (done earlier)                 |
| 0     | wifi                                                                                          | (done earlier)                 |
| 0     | mesh (pubsub + init)                                                                          | (done earlier)                 |


Checklist
---------

| Level | Item                                                       | Notes                                                                                                                 |
|-------|------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------|
| 1     | No unnecessary build scripts or separate builder images    | No required `tasks.py`, `Dockerfile.build_env` or `build.sh`. Should be buildable by `$ docker build -t IMAGE_NAME .`. |
| 1     | No `entrypoint.sh` if startup logic is very simple         | For simple entrypoints (no `if`s etc.), entrypoint can be inlined in `Dockerfile`                                     |
| 1     | Entrypoint robustness                                      | Uses `set -eu` or similar mode for shell, uses `$ exec program` if doesn't do anything after program exit.            |
| 1     | Keep paths stable in host vs. container                    | Don't confuse by "mapping" `packaging/*` to `/main_ws/packacing/*` if repo root is otherwise mapped to `/main_ws/src/` |
| 1     | Build process                                              | Use multi-stage build. Build process is defined mostly by the builder image (not copy-pasted in the concrete project) |
| 1     | Development tips in README                                 | README links to base image README for developer tips like how to compile, how to run.                                 |
| 1     | Reduce dependency in `/enclave`                            | Details like `DRONE_DEVICE_ID` (or mocap settings) should be injected from outside, not read from files in `/enclave` |
| 1     | CI builds don't limit building / pushing                   | It causes developer friction if one can't get software built (or pushed for testing) if non-`main` branches are limited |
| 1     | No hardcoded ROS distro paths e.g. `/opt/ros/galactic/...` | Use `/opt/ros/${ROS_DISTRO}/setup.bash` or let's make symlink `/opt/ros/CURRENT/...` if we have non-shell path needs  |
| 1     | FastRTPS implementation configured by the base image       | Don't override `RMW_IMPLEMENTATION` or `FASTRTPS_DEFAULT_PROFILES_FILE` in the concrete container                     |
| 1     | No `rosdep.yaml` in concrete projects                      | Specify all `rosdep.yaml` items in the base image                                                                     |


### Upcoming checklist items

| Level | Item                   | Notes                                                                                                      |
|-------|------------------------|------------------------------------------------------------------------------------------------------------|
| 2?    | Define resource limits | Define CPU, RAM etc. limits to not allow a single container bug to take down the whole system          |
| 2?    | No host networking     | `--host=network` was a hack - stop using it where possible                                                 |
| 2?    | Health checks          | Each container should reports its logical health (e.g. wifi container = whether internet connection works) |
| 2?    | Metrics                | Ability to gather operational metrics from containers with e.g. Prometheus                                 |
| 2?    | De-bloating            | Reduce container to bare essentials                                                                        |
| 2?    | Unprivileged user      | The program can be run inside the container without root privileges                                        |
