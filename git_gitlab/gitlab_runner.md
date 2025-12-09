# GitLab Runner in Docker

## Runner Registration

>Make sure that the base docker image & gitlab-runner dockers are referred using existing registry URLs.

```bash
docker run --rm -v /srv/gitlab-runner:/etc/gitlab-runner \
  globalrepo.pe.jfrog.io/docker/gitlab/gitlab-runner:latest register \
    --url https://globalgitlab.elbit.global \
    --registration-token tZyDzjHocSSrG-X6unHh \
    --executor "docker" \
    --docker_image globalrepo.pe.jfrog.io/local-dv-elop-docker/7base_questa20211_vivado20192:latest \
    --docker-volumes /var/run/docker.sock:/var/run/docker.sock
```

## How to Trust Custom/Internal CA Certificates in a Dockerized GitLab Runner

### 1. Place Your CA Certificates

- [ ] Ensure your internal CA certs are in PEM format and have a .crt extension.
- [ ] Put them all in a directory on your Docker host, e.g.: `/srv/gitlab-runner/certs`

### 2. Stop and Remove the Old Runner Container

```bash
docker stop <gitlab-runner-container-id>
docker rm   <gitlab-runner-container-id>
```

### 3. Start the Runner Container with the Cert Directory Mapped

```bash
docker run -d --restart always -it --name ci-group-runner \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /srv/gitlab-runner/config.toml:/etc/gitlab-runner/config.toml \
  -v /usr/local/share/ca-certificates:/usr/local/share/ca-certificates \
  globalrepo.pe.jfrog.io/docker/gitlab/gitlab-runner:latest run
```

### 4. Check That the Certs Appear in the Container

```bash
docker exec -it ci-group-runner ls /usr/local/share/ca-certificates
```

- [ ] Verify your custom .crt files are listed.

### 5. Update the CA Trust Store

```bash
docker exec -it ci-group-runner update-ca-certificates
```

- [ ] Output should indicate certs added (e.g. 2 added, 0 removed; done.).

### 6. (Optional) Restart the Runner Container

```bash
docker restart gitlab-runner
```

### 7. Verify

- [ ] Run jobs, or check with: `docker logs gitlab-runner`
- [ ] See there's no `x509: certificate signed by unknown authority` error.

## Tips

- Always use `/usr/local/share/ca-certificates` for adding custom CAs (never `/etc/ssl/certs`).
- Repeat `update-ca-certificates` any time you add/remove certs in the mapped directory.
- No need to change `tls-ca-file` in `config.toml`, unless you want to point to a specific single cert.