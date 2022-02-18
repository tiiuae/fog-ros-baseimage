Base container image for FOG ROS apps


Why
---

The basic idea is to add to this image any dependencies used by ≥ 2 concrete components.
I.e. if `fog_msgs` is used by several components => it belongs here.


### Space and bandwidth saving

This fattens the base image, yes, but due to Docker layer reuse this yields space and bandwidth
saving in concrete containers, as the base image has to be transferred only once, and none of the
concrete container layers need to transfer those dependencies.


### Easier dependency version coordination

Also for some dependencies like `fog_msgs` it is critical to have the same version running in all containers.
With one shared base image it's easy to audit that concrete containers are derived from same
`FROM ghcr.io/tiiuae/fog-ros-baseimage:<version>`.

It is intended that for each given system version, only one version of this base image is used in
all of the containers!


Security
--------

But this adds unnecessary files to some containers? Aren't minimal containers best for security?

Yes! But unfortunately ROS-based containers seem to get large in size, so we'll start off with a solution
that works for us *now*, and once we understand the problem (= necessary dependencies + container sizes)
better, we can start researching how viable it is to have each container contain only the dependencies it needs.

Also strictly speaking, as a hack for security it would be possible to have this "fat" image used in
a concrete container as a base layer and then on its build run `$ apt remove some-dep`, i.e.
dependencies/files can be deleted from upper layers.
Layer dir/file deletions don't use much space. :)


Build docker image
------------------

If you need to build the fog-ros-base-image to be used in your local docker environmetn for development purposes the command to be used is:

```
$ docker build -t ghcr.io/tiiuae/fog-ros-baseimage:devel .
```
