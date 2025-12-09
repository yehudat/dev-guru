## 1. Prep Artifactory

### 1.1. Create a Local Repository

- Open a 1BIT IT4E request to add a new repository
    - Naming convention: `local-dv-elop-<name>`
    - Choose a required type (Docker, NPM, Maven, Generic or else)
- Log into Artifactory’s UI
- Go to Repositories → Local → `local-dv-elop-<name>`
- Give it a key, e.g. `generic-local`

### 1.2. Generate Credentials

- Either use your username / password or create an API key in your user profile
- You’ll reference these in your CI pipelines

## 2. Push with JFrog CLI (my recommendation)

### 2.1. Install JFrog CLI

```bash
curl -fL https://getcli.jfrog.io | sh
mv jfrog /usr/local/bin
```
### 2.2. Configure a Server ID

> non-interactive; replace ORIGIN and creds

```bash
jfrog rt config \
  --url=https://your-artifactory.example.com/artifactory \
  --user=$ARTIFACTORY_USER \
  --apikey=$ARTIFACTORY_API_KEY \
  --interactive=false \
  default-server
```

## 3. Upload Your Binaries

> push your files into the registry, by using its repo path
> By default this will preserve filenames; you can add patterns or flatten paths via CLI flags.

```bash
jfrog rt upload "dist/*.zip" <new-registry>/<dir-of-choice>/ --server-id=default-server
```

## 3. Pull in GitLab CI

### 3.1. Store Secrets in GitLab → Settings → CI/CD → Variables:

- ARTIFACTORY_USER
- ARTIFACTORY_API_KEY

### 3.2. `.gitlab-ci.yml` Snippet

```yaml
image: docker:stable

variables:
  ARTIFACTORY_URL: "https://your-artifactory.example.com/artifactory"
  ARTIFACTORY_SERVER_ID: "default-server"

stages:
 - build
 - deploy

before_script:
  # install jfrog CLI
  - apk add --no-cache curl
  - curl -fL https://getcli.jfrog.io | sh && mv jfrog /usr/local/bin/

deploy:
  stage: deploy
  script:
    - jfrog rt config --url=$ARTIFACTORY_URL --user=$ARTIFACTORY_USER --apikey=$ARTIFACTORY_API_KEY --interactive=false $ARTIFACTORY_SERVER_ID
    - jfrog rt upload "build/output/*.tar.gz" <new-registry>/<dir-of-choice>/ --server-id=$ARTIFACTORY_SERVER_ID
 only:
   - main

build:
  stage: build
  script:
    - jfrog rt download generic-local/myproj/*.tar.gz ./artifacts/ --server-id=$ARTIFACTORY_SERVER_ID
    - ls artifacts/
```

## 4. Quick & Dirty: curl + REST API

> If you don’t want the CLI, you can use raw HTTP:

### 4.1. REST API Upload

```bash
curl -u"$ARTIFACTORY_USER:$ARTIFACTORY_API_KEY" -T ./path/to/binary.zip "https://your-artifactory.example.com/artifactory/generic-local/myproj/binary.zip"
```

### 4.2. Download

```bash
curl -u"$ARTIFACTORY_USER:$ARTIFACTORY_API_KEY" -O "https://your-artifactory.example.com/artifactory/generic-local/myproj/binary.zip"
```