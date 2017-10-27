# Docker image containing all dependencies for running nubis-builder

FROM alpine:3.6

# Do not add a 'v' as part of the version string (ie: v1.1.3)
#+ This causes issues with extraction due to GitHub's methodology
#+ Where necesary the 'v' is specified in code below
ENV AwCliVersion=1.10.38 \
    PackerVersion=1.1.1 \
    PuppetVersion=3.8.7 \
    TerraformVersion=0.10.7 \
    LibrarianPuppetVersion=2.2.3 \
    NubisBuilderVersion=1.5.4 \
    RubyVersion=2.0.0_p647-r0

WORKDIR /nubis

RUN echo 'http://dl-cdn.alpinelinux.org/alpine/v3.0/main' >> /etc/apk/repositories

RUN apk add --no-cache \
  ca-certificates \
  curl \
  bash \
  less \
  git \
  jq \
  unzip \
  binutils \
  rsync \
  tar \
  ruby=${RubyVersion} \
  ruby-rdoc \
  ruby-irb \
  python \
  py2-pip

RUN rm -f /var/cache/apk/APKINDEX.*

# Install puppet
RUN gem install puppet -v ${PuppetVersion} --no-rdoc --no-ri

# Install librarian-puppet
RUN gem install librarian-puppet -v ${LibrarianPuppetVersion}  --no-rdoc --no-ri

# Install the AWS cli tool
RUN pip install awscli==${AwCliVersion}

# Install Packer
RUN ["/bin/bash", "-c", "set -o pipefail \
    && curl --silent -L --out /nubis/packer_${PackerVersion}_linux_amd64.zip https://releases.hashicorp.com/packer/${PackerVersion}/packer_${PackerVersion}_linux_amd64.zip \
    && unzip /nubis/packer_${PackerVersion}_linux_amd64.zip -d /nubis/bin \
    && strip /nubis/bin/packer \
    && rm -f /nubis/packer_${PackerVersion}_linux_amd64.zip" ]

# Install Terraform
RUN ["/bin/bash", "-c", "set -o pipefail \
    && curl --silent -L --out /nubis/terraform_${TerraformVersion}_linux_amd64.zip https://releases.hashicorp.com/terraform/${TerraformVersion}/terraform_${TerraformVersion}_linux_amd64.zip \
    && unzip /nubis/terraform_${TerraformVersion}_linux_amd64.zip -d /nubis/bin \
    && rm -f /nubis/terraform_${TerraformVersion}_linux_amd64.zip" ]

# Install nubis-builder
RUN ["/bin/bash", "-c", "set -o pipefail && mkdir -p /nubis/nubis-builder \
    && curl --silent -L https://github.com/nubisproject/nubis-builder/archive/v${NubisBuilderVersion}.tar.gz \
    | tar --extract --gunzip --directory=/nubis/nubis-builder" ]

# Allow everyone to write and copy to that directory
RUN chmod 777 /nubis && \
    chmod 777 /nubis/nubis-builder/nubis-builder-${NubisBuilderVersion}/secrets

# Cleanup
RUN apk del --no-cache \
  binutils \
  py2-pip \
  ruby-rdoc \
  ruby-irb \
  tar \
  unzip

# Copy over the nubis-builder-wrapper script
COPY [ "nubis-builder-wrapper", "/nubis/" ]

ENV PATH /nubis/nubis-builder/nubis-builder-${NubisBuilderVersion}/bin:/nubis/bin:$PATH

ENTRYPOINT [ "/nubis/nubis-builder-wrapper" ]

CMD [ "build" ]
