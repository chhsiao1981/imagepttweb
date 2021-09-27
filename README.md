# imagepttweb
Dockerfile for https://github.com/ptt/pttweb

## Getting Started

* copy docs/config.json.tmpl and docs/static.tmpl to your etc directory.
* change "RecaptchaSiteKey" and "RecaptchaSecret" config.json
* `docker-compose --env-file docker_compose.env -f docker-compose.yaml up -d`
