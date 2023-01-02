ARG DEBIAN_VERSION=stable-slim


# builder
FROM debian:${DEBIAN_VERSION} as builder
ARG SHELLCHECK_VERSION=latest
ARG TERRAFORM_DOCS_VERSION=latest
ARG TERRAFORM_VERSION=latest
ARG TERRAGRUNT_VERSION=latest
ARG TFLINT_VERSION=latest
ARG TFSEC_VERSION=latest
COPY docker/dotfiles/. /root/
COPY tfget /usr/local/bin/
ENV CURL='curl -fsSL --netrc-optional'
RUN apt-get update && apt-get install --no-install-recommends -y \
      bash \
      ca-certificates \
      curl \
      jq \
      libc6 \
      unzip \
      xz-utils

# shellcheck
RUN /bin/bash -c 'if [[ "${SHELLCHECK_VERSION}" == "latest" ]]; then SHELLCHECK_VERSION=$(${CURL} "https://api.github.com/repos/koalaman/shellcheck/releases/latest" | jq -r .tag_name); fi \
      && ${CURL} https://github.com/koalaman/shellcheck/releases/download/v${SHELLCHECK_VERSION}/shellcheck-v${SHELLCHECK_VERSION}.linux.x86_64.tar.xz -o shellcheck.tar.xv \
      && tar -xvf shellcheck.tar.xv \
      && mv shellcheck-v${SHELLCHECK_VERSION}/shellcheck /usr/local/bin/ \
      && chmod +x /usr/local/bin/shellcheck \
      && shellcheck --version'

# terraform
RUN /bin/bash -c 'tfget ${TERRAFORM_VERSION} \
      && terraform --version'

# terragrunt
RUN /bin/bash -c 'if [[ "${TERRAGRUNT_VERSION}" == "latest" ]]; then TERRAGRUNT_VERSION=$(${CURL} "https://api.github.com/repos/gruntwork-io/terragrunt/releases/latest" | jq -r .tag_name); fi \
      && ${CURL} https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 -o /usr/local/bin/terragrunt \
      && chmod +x /usr/local/bin/terragrunt \
      && terragrunt --version'

# terraform-docs
RUN /bin/bash -c 'if [[ "${TERRAFORM_DOCS_VERSION}" == "latest" ]]; then TERRAFORM_DOCS_VERSION=$(${CURL} "https://api.github.com/repos/terraform-docs/terraform-docs/releases/latest" | jq -r .tag_name); fi \
      && ${CURL} https://github.com/terraform-docs/terraform-docs/releases/download/${TERRAFORM_DOCS_VERSION}/terraform-docs-${TERRAFORM_DOCS_VERSION}-linux-amd64.tar.gz -o terraform-docs.tar.gz \
      && tar -xzf terraform-docs.tar.gz \
      && mv terraform-docs /usr/local/bin/ \
      && chown root:root /usr/local/bin/terraform-docs \
      && chmod +x /usr/local/bin/terraform-docs \
      && terraform-docs --version'

# tflint
RUN /bin/bash -c 'if [[ "${TFLINT_VERSION}" == "latest" ]]; then TFLINT_VERSION=$(${CURL} "https://api.github.com/repos/terraform-linters/tflint/releases/latest" | jq -r .tag_name); fi \
      && ${CURL} https://github.com/terraform-linters/tflint/releases/download/${TFLINT_VERSION}/tflint_linux_amd64.zip -o tflint.zip \
      && unzip tflint.zip \
      && mv tflint /usr/local/bin/ \
      && chmod +x /usr/local/bin/tflint \
      && TFLINT_AWS_VERSION=$(${CURL} "https://api.github.com/repos/terraform-linters/tflint-ruleset-aws/releases/latest" | jq -r .tag_name | sed -e "s:^v::") \
      && sed -ie "s:TFLINT_AWS_VERSION:$TFLINT_AWS_VERSION:" /root/.tflint.hcl \
      && GITHUB_TOKEN=${GITHUB_TOKEN:-$(awk "'"c&&!--c;/github.com/{c=2}"'" /root/.netrc | awk "'"{print $2;exit}"'")} \
      && tflint --version \
      && tflint --init'

# tfsec
RUN bin/bash -c 'if [[ "${TFSEC_VERSION}" == "latest" ]]; then TFSEC_VERSION=$(${CURL} "https://api.github.com/repos/aquasecurity/tfsec/releases/latest" | jq -r .tag_name); fi \
      && ${CURL} https://github.com/aquasecurity/tfsec/releases/download/${TFSEC_VERSION}/tfsec-linux-amd64 -o /usr/local/bin/tfsec \
      && chmod +x /usr/local/bin/tfsec \
      && tfsec --version'


# main
FROM debian:${DEBIAN_VERSION} as main
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install --no-install-recommends -y \
      bash \
      curl \
      ca-certificates \
      git \
      jq \
      unzip \
      vim \
      && apt-get clean \
      && rm -rf /var/lib/apt/lists/*
COPY --from=builder /root/.terraform.d/. /root/.terraform.d/
COPY --from=builder /root/.tflint.d/. /root/.tflint.d/
COPY --from=builder /root/.tflint.hcl /root/
COPY --from=builder /usr/local/bin/ /usr/local/bin/
RUN /bin/bash -c 'terraform --version'
RUN echo "complete -C /usr/local/bin/aws_completer aws" >> /root/.bashrc

ENTRYPOINT []
