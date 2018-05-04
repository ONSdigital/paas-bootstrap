# Docker image

The onsdigital/paas-ci-gp Docker image is used by Concourse for a variety of tasks.
To build this, you need to be added to the `onspaas` team in Docker Hub, which has
admin rights to this image.

```sh
  make docker_image
```