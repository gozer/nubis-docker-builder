# Docker image containing all dependencies for running nubis-builder and nubis-release

FROM ubuntu:16.04

# Do not add a 'v' as pert of the version string (ie: v1.1.3)
#+ This causes issues with extraction due to GitHub's methodology
#+ Where necesary the 'v' is specified in code below
ENV AwCliVersion=1.10.38 \
    AwsVaultVersion=3.7.1 \
    PackerVersion=1.0.0 \
    TerraformVersion=0.8.8 \
    UnicredsVersion=1.5.1 \
    NubisBulderVersion=1.5.1

# Intall package dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    jq=1.5* \
    python-pip=8.1.* \
    unzip \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /nubis

# Install the AWS cli tool
RUN pip install awscli==${AwCliVersion}

# Install aws-vault
RUN ["/bin/bash", "-c", "set -o pipefail && mkdir -p /nubis/bin \
    && curl --silent -L --out /nubis/bin/aws-vault https://github.com/99designs/aws-vault/releases/download/v${AwsVaultVersion}/aws-vault-linux-amd64 \
    && chmod +x /nubis/bin/aws-vault" ]

# Install Packer
RUN ["/bin/bash", "-c", "set -o pipefail \
    && curl --silent -L --out /nubis/packer_${PackerVersion}_linux_amd64.zip https://releases.hashicorp.com/packer/${PackerVersion}/packer_${PackerVersion}_linux_amd64.zip \
    && unzip /nubis/packer_${PackerVersion}_linux_amd64.zip -d /nubis/bin \
    && rm -f /nubis/packer_${PackerVersion}_linux_amd64.zip" ]

# Install Terraform
RUN ["/bin/bash", "-c", "set -o pipefail \
    && curl --silent -L --out /nubis/terraform_${TerraformVersion}_linux_amd64.zip https://releases.hashicorp.com/terraform/${TerraformVersion}/terraform_${TerraformVersion}_linux_amd64.zip \
    && unzip /nubis/terraform_${TerraformVersion}_linux_amd64.zip -d /nubis/bin \
    && rm -f /nubis/terraform_${TerraformVersion}_linux_amd64.zip" ]

# Install Unicreds
RUN ["/bin/bash", "-c", "set -o pipefail \
    && curl --silent -L https://github.com/Versent/unicreds/releases/download/${UnicredsVersion}/unicreds_${UnicredsVersion}_linux_amd64.tar.gz \
    | tar --extract --gunzip --directory=/nubis/bin" ]

# Install nubis-builder
RUN ["/bin/bash", "-c", "set -o pipefail && mkdir -p /nubis/nubis-builder \
    && curl --silent -L https://github.com/nubisproject/nubis-builder/archive/v${NubisBulderVersion}.tar.gz \
    | tar --extract --gunzip --directory=/nubis/nubis-builder" ]

# Configure nubis-builder
COPY [ "nubis-builder-config", "/nubis/" ]
RUN ["/bin/bash", "-c", "/nubis/nubis-builder-config ${NubisBulderVersion}" ]


ENV PATH /nubis/nubis-builder/nubis-builder-${NubisBulderVersion}/bin:/nubis/bin:$PATH

ENTRYPOINT [ "nubis-builder", "build" ]

CMD [ "--project-path", "/nubis/data" ]
