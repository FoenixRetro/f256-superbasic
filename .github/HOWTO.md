You can test GitHub Actions workflows locally using [`act`](https://nektosact.com/) and [Docker](https://www.docker.com/):

```shell
act --container-architecture linux/amd64 -W '.github/workflows/prepare-release-pr.yml'
act --container-architecture linux/amd64 -W '.github/workflows/release.yml'
```
