# Build Base image
`docker build . -t ubuntu:22.04-local -f Dockerfile.base`

# Build Python/Ansible image
`docker build . -t python:latest -f Dockerfile`
