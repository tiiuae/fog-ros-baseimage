Version pinning plan for base image
==================================


Background & the problem
------------------------

On 2022-03-21 we (Jari, Manuel, Mehmet and Joonas) discussed the need to pin dependencies in order
to prevent hard-to-fix breakage.
Such breakage has occurred with FastRTPS implementation before, where the ROS community shipped a
backwards-incompatible change in minor version and removed the previous-working version from their
repository server. 🥲

This resulted in having a really hard time to fix the issue.

We would like to prevent such situations in the future.


Suggested solutions
-------------------

- Have multiple levels of base image. Instead of `ROS -> fog-ros-baseimage -> end product` we could
  have `ROS -> fog-ros-baseimage:critical-dependencies -> fog-ros-baseimage -> end product` or similar.
  We would update the `critical-dependencies` layer very rarely, and still be able to update the
  image in the less-critical layer frequently, guaranteeing version pinning of the critical dependencies.

- Cache the critical (or all) .deb packages in our own Artifactory server. This could probably be a
  fair amount of work and maintaining, and only works for .deb-based dependencies (and not a general
  solution like Docker layers could provide).

- Don't do anything to to pin dependencies beforehand, knowing we can use Docker primitives as recovery
  plan.

The "don't do anything" plan assumes that critical breakages happen rarely, but if such breakage
happens we have a solid recovery plan.
As a benefit we still get "automatic" version updates to dependencies.
This is best described by just documenting the recovery plan.


Docker layer-based recovery plan
--------------------------------

We have this example directory:

```
.
└── Dockerfile
```

The Dockerfile:

```dockerfile
FROM ros:galactic-ros-core

RUN apt install -y \
	ros-galactic-geodesy \
	ros-galactic-tf2-ros \
	ros-galactic-rmw-fastrtps-cpp  # <-- we would like to pin this

RUN apt install -y \
	ros-galactic-fog-msgs=0.0.8-42~git20220104.1d2cf3f \
	ros-galactic-px4-msgs=3.0.0-15~git20220104.c12fcdf
```

This works and is tagged as `tiiuae/fog-ros-baseimage:sha-f9ebaac` (`f9ebaac` is the Git revision
it was built from).
Let's assume building this gave us v1.1 of `ros-galactic-rmw-fastrtps-cpp`.

Now three months later we go to update `ros-galactic-px4-msgs` to newer version:

```diff
 RUN apt install -y \
 	ros-galactic-fog-msgs=0.0.8-42~git20220104.1d2cf3f \
-	ros-galactic-px4-msgs=3.0.0-15~git20220104.c12fcdf
+	ros-galactic-px4-msgs=3.0.1-12~git20220404.abcdef1
```

The above was the actual edit, but this was the effect including implicit side-effects:

```diff
 RUN apt install -y \
 	ros-galactic-geodesy \
 	ros-galactic-tf2-ros \
-	ros-galactic-rmw-fastrtps-cpp  # <-- v1.1
+	ros-galactic-rmw-fastrtps-cpp  # <-- v1.2 (backwards-breaking version)

 RUN apt install -y \
 	ros-galactic-fog-msgs=0.0.8-42~git20220104.1d2cf3f \
-	ros-galactic-px4-msgs=3.0.0-15~git20220104.c12fcdf
+	ros-galactic-px4-msgs=3.0.1-12~git20220404.abcdef1  # <-- the only explicitly-wished change
```

... but now building it **also** gives us v1.2 of `ros-galactic-rmw-fastrtps-cpp` which is
incompatible with our whole system.
It turns out that ROS community also yanked the good version v1.1 from their repos, so it doesn't
help if we try to pin it to the known-good version - it doesn't exist anymore.
(Pinning the package as recovery solution should be the first and easiest course of action, if it still exists.
Then we don't need the layer-based recovery plan.)

This is a catastrophe in which many things have gone wrong.
From which we still can recover from, and still not end up with a horrible hack.

So let's get back to the first version of the `Dockerfile` and remember that one build of it was
tagged as `tiiuae/fog-ros-baseimage:sha-f9ebaac`.
The image is immutable, and inside that image there's the good version v1.1 of `ros-galactic-rmw-fastrtps-cpp`.

For good documentation reasons (this is not required) we can store the known-good version of
`Dockerfile` in the repo as `Dockerfile.sha-f9ebaac`.

Then change the `Dockerfile` to use the known-good image as its base layer, only adding on top of it
the changes that need to come after it. We'll end up with:

```
.
├── Dockerfile
└── Dockerfile.sha-f9ebaac
```

Where `Dockerfile`:

```dockerfile
# temporary catastrophe recovery in effect: adding on top of previous known-good layer because FastRTPS
# had backwards-incompatible change and the actual good version was removed from ROS repos
FROM tiiuae/fog-ros-baseimage:sha-f9ebaac

RUN apt install -y \
	ros-galactic-px4-msgs=3.0.1-12~git20220404.abcdef1

```

And `Dockerfile.sha-f9ebaac`:

```dockerfile
# DO NOT EDIT: this is stored as documentation for how the following image was built:
#     tiiuae/fog-ros-baseimage:sha-f9ebaac

FROM ros:galactic-ros-core

RUN apt install -y \
	ros-galactic-geodesy \
	ros-galactic-tf2-ros \
	ros-galactic-rmw-fastrtps-cpp

RUN apt install -y \
	ros-galactic-fog-msgs=0.0.8-42~git20220104.1d2cf3f \
	ros-galactic-px4-msgs=3.0.0-15~git20220104.c12fcdf

```


### Caveats

This solution is expected to be temporary "to stop the bleeding", and needs to be returned back to
normal once a new fix comes to the affected dependency (or we can migrate the rest of our system to
the new backwards-incompatible behaviour). Caveats while using this recovery mode:

- We can't obviously get new ROS base image updates, because we've to keep using the "recovery layer"
  as long as we need to keep using the known-good dependency version.

- It would be nice to be able to extract the known-good `.deb` from the base image.
  It seems that `$ apt` doesn't cache those files, but `$ apt-get` does ([source](https://unix.stackexchange.com/q/447593)).
  Changing this is easy, but do we want to increase our base image size?
  If this capability is desired, this size hit we would have to pay as insurance beforehand.


Recap
-----

It is proposed that we move forward with not stressing about version pinning for components where
we'd like to get occasional automatic version updates, because catastophic backwards-compat breakages
with also previous known-good versions being yanked from repos can still be recovered from, with minor effort
with help of Docker layering primitives.

The best thing is that we only need to put in any effort if we actually need to use the recovery plan.

We'll of course continue pinning packages such as `ros-galactic-px4-msgs` where package updating
must happen in very controlled fashion.
We can use the best approach for each situation.

This approach can be re-evaluated if such catastrophic breakages actually occur often enough to
cause significant pain.

It is worth remembering that *changing* the base image Dockerfile is already a good-enough
control point for receiving package updates: end products don't automatically get package updates
from base image unless they opt-in for new version of said base image.
I.e. you can build end product's Dockerfile 100 times and each time get exact same FastRTPS version,
unless you opt-in to newer version of the base image.
