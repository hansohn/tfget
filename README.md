<div align="center">
  <h3>tfget</h3>
  <p>Terraform tool for fetching release metadata</p>
  <p>
    <!-- Build Status -->
    <a href="https://actions-badge.atrox.dev/hansohn/tfget/goto?ref=main">
      <img src="https://img.shields.io/endpoint.svg?url=https%3A%2F%2Factions-badge.atrox.dev%2Fhansohn%2Ftfget%2Fbadge%3Fref%3Dmain&style=for-the-badge">
    </a>
    <!-- Github Tag -->
    <a href="https://github.com/hansohn/tfget/tags/">
      <img src="https://img.shields.io/github/tag/hansohn/tfget.svg?style=for-the-badge">
    </a>
    <!-- License -->
    <a href="https://github.com/hansohn/tfget/blob/main/LICENSE">
      <img src="https://img.shields.io/github/license/hansohn/tfget.svg?style=for-the-badge">
    </a>
    <!-- LinkedIn -->
    <a href="https://linkedin.com/in/ryanhansohn">
      <img src="https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555">
    </a>
  </p>
</div>

### Description

Welcome to the **tfget** repo. This bash command line utility fetches Terraform
binaries and symlinks them to /usr/local/bin/terraform.

### Usage

#### Commands

```
$ tfget --help

  Usage: /usr/local/bin/tfget <TERRAFORM_VERSION>

    -c              Clean up symlinks and temp files
    -i              Install specified version(s) of Terraform. Multiple versions
                    can be specified using a comma-seperated string. Example:
                    '1.2.3,4.5.6'
    -l              List currently installed versions
    -p              Preinstall binary but do not symlink it after installation.
                    Default behavior symlinks binary to '/usr/local/bin/terraform'
    -s              Symlink specified <version> to '/usr/local/bin/terraform'

    -h, --help      shows this help menu

  This script downloads the Terraform version passed into it and symlinks the
  binary to '/usr/local/bin/terraform'.
```

#### Makefile

Additionally, a Makefile has been included in this repo to assist with common
development-related functions. I've included the following make targets for
convenience:

```
Available targets:

  clean                               Clean everything
  clean/docker                        Clean docker build images
  docker                              Docker lint, build and run image
  docker/build                        Docker build image
  docker/lint                         Lint Dockerfile
  docker/push                         Docker push image
  docker/run                          Docker run image
  help                                Help screen
  help/all                            Display help for all targets
  help/short                          This help short screen
  lint                                Run all linters, validators, and security analyzers
  lint/shellcheck                     Bash linter
```
