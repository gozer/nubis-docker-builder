
# nubis-docker-builder

Docker image for building Nubis AMIs

[Install docker](https://docs.docker.com/engine/installation/linux/ubuntu/)

```bash

docker build -t nubis-builder .

docker login

IMAGE_VERSION='v0.3.0'

docker tag nubis-builder nubisproject/nubis-builder:${IMAGE_VERSION}

docker push nubisproject/nubis-builder:${IMAGE_VERSION}

docker pull nubisproject/nubis-builder:${IMAGE_VERSION}

ACCOUNT='<account-to-build-in>'

aws-vault exec ${ACCOUNT} -- docker run -u $UID:$(id -g) -it --env-file ~/.docker_env -e GIT_COMMIT_SHA=$(git rev-parse HEAD) -v $PWD:/nubis/data nubisproject/nubis-builder:${IMAGE_VERSION}

aws-vault exec ${ACCOUNT} -- docker run -u $UID:$(id -g) -it --env-file ~/.docker_env -e GIT_COMMIT_SHA=$(git rev-parse HEAD) -v $PWD:/nubis/data nubisproject/nubis-builder:${IMAGE_VERSION} --build-region us-east-1 --copy-regions 'ap-northeast-1,ap-northeast-2,ap-southeast-1,ap-southeast-2,eu-central-1,eu-west-1,sa-east-1,us-east-1,us-west-1,us-west-2' build

```

