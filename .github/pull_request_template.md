### Proposed changes

Describe the use case and detail of the change. If this PR addresses an issue on GitHub, make sure to include a link to that issue using one of the [supported keywords](https://docs.github.com/en/github/managing-your-work-on-github/linking-a-pull-request-to-an-issue) here in this description (not in the title of the PR).

### Checklist

Before creating a PR, run through this checklist and mark each as complete:

- [ ] I have read the [contributing guidelines](/CONTRIBUTING.md)
- [ ] I have signed the [F5 Contributor License Agreement (CLA)](https://github.com/f5/f5-cla/blob/main/docs/f5_cla.md)
- [ ] I have run the [`update.sh`](/update.sh) script and ensured all entrypoint/Dockerfile template changes have been applied to the relevant image entrypoint scripts & Dockerfiles
- [ ] I have tested that the NGINX Docker unprivileged image builds and runs correctly on all supported architectures on an unprivileged environment (check out the [`README`](/README.md) for more details)
- [ ] I have updated any relevant documentation ([`README.md`](/README.md))
