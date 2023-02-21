# NGINX Unprivileged Docker Image

This repo contains a series of Dockerfiles to create an NGINX Docker image that runs NGINX as a non root, unprivileged user. Notable differences with respect to the official NGINX Docker image include:

* The default NGINX listen port is now `8080` instead of `80` (this is no longer necessary as of Docker `20.03` but it's still required in other container runtimes).
* The default NGINX user directive in `/etc/nginx/nginx.conf` has been removed.
* The default NGINX PID has been moved from `/var/run/nginx.pid` to `/tmp/nginx.pid`.
* Change `*_temp_path` variables to `/tmp/*`.

New images are built and pushed to on a weekly basis (every Monday night).

Check out the [docs](https://hub.docker.com/_/nginx) for the upstream Docker NGINX image for a detailed explanation on how to use this image.

**Note:** Issues related to security vulnerabilities will be promptly closed unless they are accompanied by a solid reasoning as to why the vulnerability poses a real security threat to this image. Check out the [`SECURITY`](https://github.com/nginxinc/docker-nginx-unprivileged/blob/main/.github/SECURITY.md) doc for more details.

## Supported Image Registries and Platforms

### Image Registries

You can find built images in the following registries:

* Amazon ECR - <https://gallery.ecr.aws/nginx/nginx-unprivileged>
* Docker Hub - <https://hub.docker.com/r/nginxinc/nginx-unprivileged>
* GitHub Container Registry - <https://github.com/nginxinc/docker-nginx-unprivileged/pkgs/container/nginx-unprivileged>

### Platforms

Most images are built for the `amd64`, `arm32v5` (for Debian), `arm32v6` (for Alpine), `arm32v7`, `arm64v8`, `i386`, `mips64le` (for Debian), `ppc64le` and `s390x` architectures.

## Common Issues

* If you override the default `nginx.conf` file you may receive the message `nginx: [emerg] open() "/var/run/nginx.pid" failed (13: Permission denied)`, in this case you have to add the line `pid /tmp/nginx.pid` into your config.
