Base container image for FOG ROS apps


Drawing
-------

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
$ docker build -t ghcr.io/tiiuae/fog-ros-baseimage-build-env -f Dockerfile.builder .
```
