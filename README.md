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

Shared builder script is invoked. This produces a `.deb` file in directory `/main_ws/src`.


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


Build docker image
------------------

If you need to build the fog-ros-baseimage to be used in your local docker environment for development purposes the command to be used is:

```
$ docker build -t ghcr.io/tiiuae/fog-ros-baseimage .
```

Build build environment docker image
------------------------------------

Following command shows how to build your local docker image for building ROS2 nodes:

```
$ docker build -t ghcr.io/tiiuae/fog-ros-baseimage:builder-latest -f Dockerfile.builder .
```


### Debug

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
