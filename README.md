
# nubis-docker-builder

Docker image for building Nubis AMIs

[Install docker](https://docs.docker.com/engine/installation/linux/ubuntu/)

```bash

docker build -t nubis-builder .

docker login

docker tag nubis-builder nubisproject/nubis-builder:v0.1.0

docker push nubisproject/nubis-builder:v0.1.0

docker pull nubisproject/nubis-builder

```
