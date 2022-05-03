Base container image for FOG ROS apps


How concrete projects are built
-------------------------------

### Summary

- Concrete projects use the builder image to build the ROS node
- After building, a separate runtime image is created in which this just-compiled program is copied
- Both of the above steps happen inside Docker
  [multi-stage build](https://docs.docker.com/develop/develop-images/multistage-build/)


### Drawing

```
                            │
                            │
                            │
                            │
fog-ros-baseimage repo      │       Concrete repos
                            │
                            │
                            │       Multi-stage build
                            │  ┌─────────────────────────┐
                            │  │                         │
                            │  │   ┌─────────────────┐   │
                            │  │   │                 │   │
                            │  │   │  Builder        │   │
┌────────────────┐             │   │                 │   │
│                │             │   │  ┌────────────┐ │   │
│  Builder image ├─────────────┼───►  │ Compile ROS│ │   │
│                │ Compiler,   │   │  │ node       │ │   │
└────────────────┘ other build │   │  └─┬──────────┘ │   │
                   tools       │   │    │            │   │
                               │   └────┼────────────┘   │
                               │        │                │
                               │ ┌──────┘                │
                               │ │                       │
                               │ │ ┌───────────────┐     │
                               │ │ │               │     │
                               │ │ │ Runtime build │     │    ┌─────────────┐
                               │ │ │               │     │    │             │
                               │ │ │ ┌───────────┐ ├─────┼────► Final image │
┌────────────┐                 │ └─┼─►Add program│ │     │    │             │
│            │                 │   │ └───────────┘ │     │    └─────────────┘
│ Base image ├─────────────────┼───►               │     │
│            │                 │   └───────────────┘     │
└────────────┘                 │                         │
                               └─────────────────────────┘
```


### Technical details

Concrete project repo is mounted at location `/main_ws/src` inside the build container.

Shared builder script is invoked. This produces a `.deb` file in directory `/main_ws/`.


Interesting files
-----------------

| File               | Purpose                                     |
|--------------------|---------------------------------------------|
| Dockerfile         | Base image for concrete ROS projects        |
| Dockerfile.builder | Build environment for concrete ROS projects |


More documentation
------------------

- [Rationale/design of this base image](docs/rationale-design.md)
- [Version pinning plan for base image](docs/version-pinning-plan.md)
- [Container checklist](docs/container-checklist.md)


Development & debug for concrete projects
-----------------------------------------

You may have been linked here from concrete project's readme.
These tips should apply to all our concrete ROS-based projects (mocap_pose, rplidar etc..)


### Development tips

All concrete projects should be buildable by "standard Docker-ism:" `$ docker build -t PROJECT_NAME .`.

This is also what the
[GitHub actions CI workflows](https://github.com/tiiuae/mocap_pose/blob/29299da43a4a487ed3dc5979681afec49422805e/.github/workflows/tii-mocap-pose.yaml#L35)
effectively do.


### Extract the .deb package from the build process

Extract built `.deb` from multi-stage build's builder layer.

Just before the multi-stage build is moving on to building the runtime image, look for output like this:

```
Removing intermediate container ef11fe5a4ad1
 ---> 0d84c105ca04
```

The `0d84c105ca04` is the image ID in which the file modifications made by the container are stored.
This includes any files it built.

You can either copy a known file from the image (with the help of a temporary container based on it):

`$ docker run --rm -it -v "$(pwd):/host" IMAGE_ID cp /path/to.deb /host/`

Or if you're unsure, you can change `cp` to `bash`/`sh` to explore.


Development & debug for base images
-----------------------------------

These tips concern this repository, i.e. the runtime base image and the build environment base image.


### Build runtime base image

This image is used as runtime container base image of concrete ROS nodes.
([Example](https://github.com/tiiuae/px4_ros_com/blob/38649b1f446264b248c982899ce0b08094d56427/Dockerfile#L20))

If you need to build the fog-ros-baseimage to be used in your local docker environment for development purposes the command to be used is:

```
$ docker build -t ghcr.io/tiiuae/fog-ros-baseimage:latest .
```


### Build build-environment base image

This image is used as build container in multi-stage build of concrete ROS nodes.
([Example](https://github.com/tiiuae/px4_ros_com/blob/38649b1f446264b248c982899ce0b08094d56427/Dockerfile#L1))

Following command shows how to build your local docker image for building ROS2 nodes:

```
$ docker build -t ghcr.io/tiiuae/fog-ros-baseimage:builder-latest -f Dockerfile.builder .
```
