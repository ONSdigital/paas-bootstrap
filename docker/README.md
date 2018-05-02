# Jumpbox pipeline

This pipeline is to be deployed to the Concourse server to create the Jumpbox.

## Docker image

There is one dependency, which is the paas-ci-gp Docker image. To build this, you need to
be placed on the `onspaas` team in Docker Hub, which has admin rights to this image.

```sh
  docker login
  docker build -t onsdigital/paas-ci-gp:latest .
  docker push onsdigital/paas-ci-gp:latest
```

FIXME: this should be replaced with a pipeline job :)