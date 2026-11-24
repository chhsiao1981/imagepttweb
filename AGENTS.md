# Repository Guidelines

## Project Overview
`github.com/chhsiao1981/imagepttweb`: Dockerfile and deployment templates for [ptt/pttweb](https://github.com/ptt/pttweb), the PTT BBS web frontend. This repo contains no Go source of its own; the image clones pttweb at build time.

## Architecture & Data Flow
- `Dockerfile`: installs `protoc`, `protoc-gen-go`, `protoc-gen-go-grpc`; clones `ptt/pttweb` (default branch, unpinned) into `/srv/pttweb`; pins `github.com/golang/protobuf` and `google.golang.org/grpc` with `go get`; generates `proto/man` and `proto/api` stubs; `go build`. Copies `docs/config.json.tmpl` to `/etc/pttweb/config.json` and `docs/static.tmpl` to `/etc/pttweb/static`. Runs `/srv/pttweb/pttweb -conf /etc/pttweb/config.json`, port 4567.
- `docker-compose.yaml`: `pttredis` (Redis, captcha store) and `pttweb` (image `imagepttweb:v0.1.0`, `127.0.0.1:4567:4567`, mounts `${ETC}` over `/etc/pttweb`).
- pttweb at runtime talks to `boardd`, `searchd`, `mand` (gRPC), `memcached`, and `pttredis:6379`, by the hostnames in `docs/config.json.tmpl`. Those services are not defined here.

## Key Directories
- `docs/config.json.tmpl`: pttweb config template (`RecaptchaSiteKey`, `RecaptchaSecret`, `CaptchaInsertSecret` are placeholders).
- `docs/static.tmpl/`: minimal placeholder HTML templates (`{{define "ROOT"}}`); only `captcha.html` is a real page.

## Development Commands
```
docker build -t imagepttweb:v0.1.0 .
docker-compose --env-file docker_compose.env -f docker-compose.yaml up -d
```
Before `up`, copy `docs/config.json.tmpl` (as `config.json`) and `docs/static.tmpl` (as `static/`) into the `ETC` directory and set the reCAPTCHA keys.

## Code Conventions & Common Patterns
- Image tag version lives in `docker-compose.yaml` / `docker-compose.yaml.tmpl` (`imagepttweb:v0.1.0`); keep both in sync.
- `docker_compose.env` and `docker_compose.env.template` define `ETC`.
- Proto generator versions must match the protobuf runtime pinned by `go get` (`protoc-gen-go` vs `google.golang.org/protobuf`), and pttweb's `go.mod` declares `go 1.15`, so generated code must not need newer language features.

## Important Files
`Dockerfile`, `docker-compose.yaml`, `docker-compose.yaml.tmpl`, `docs/config.json.tmpl`, `docs/static.tmpl/captcha.html`, `README.md`.

## Runtime/Tooling Preferences
- Docker and docker-compose. No Makefile, scripts, or CI.
- License: GPL-3.0.

## Testing & QA
- No tests. Verify changes with `docker build`, then run the image and check that pttweb listens on 4567 (requests return 500 until `boardd` etc. are reachable).
