# Prebuilt DB for OWASP Dependency-Check Docker Image

This Docker image provides a secure, up-to-date, and CI/CD-ready environment for running OWASP vulnerability scans. It is designed for use in professional DevSecOps pipelines (GitHub Actions, GitLab CI, Jenkins, etc.) and supports fast, offline scans by baking the NVD database into the image at build time.

---

## Features
- **Based on [Eclipse Temurin JDK](https://hub.docker.com/_/eclipse-temurin)** (LTS, security maintained)
- **Installs latest Dependency-Check CLI** (version controlled via build arg)
- **Bakes NVD database into the image** for fast, offline scans
- **Supports NVD API key** for reliable DB updates
- **Includes bash, curl, unzip, ca-certificates, gosu** for scripting and CI compatibility
- **Custom entrypoint** for flexible command execution
- **Works with custom scan scripts and CI/CD pipelines**

---

## Usage

### **Build the Image**

```sh
# (Optional) Get a free NVD API key: https://nvd.nist.gov/developers/request-an-api-key
export NVD_API_KEY=your-nvd-api-key

# Build with the latest Dependency-Check version (default: 8.4.0, recommended: 12.1.3)
podman build --build-arg DC_VERSION=12.1.3 --build-arg NVD_API_KEY=$NVD_API_KEY -t owasp-dependency-check:latest .
```

### **Run a Scan (Local Example)**

```sh
podman run --rm -v $(pwd):/workspace owasp-dependency-check:latest \
  dependency-check.sh --data /opt/dc-data --project "my-project" --scan . --format "ALL" --out ./odc-reports
```

### **Use in CI/CD (GitHub Actions, GitLab CI, etc.)**
- Reference this image in your pipeline job
- Mount your code as `/workspace`
- Use your scan script or call `dependency-check.sh` directly

**Example GitHub Actions step:**
```yaml
- name: Dependency-Check Scan
  uses: addnab/docker-run-action@v3
  with:
    image: ghcr.io/your-org/owasp-dependency-check:latest
    options: -v ${{ github.workspace }}:/workspace
    run: |
      dependency-check.sh --data /opt/dc-data --project "my-project" --scan . --format "ALL" --out ./odc-reports
```

**Example GitLab CI job:**
```yaml
dependency-check:
  stage: scan
  image: registry.gitlab.com/your-org/owasp-dependency-check:latest
  script:
    - dependency-check.sh --data /opt/dc-data --project "$CI_PROJECT_NAME" --scan . --format "ALL" --out ./odc-reports
```

---

## Build Arguments
| Argument        | Default   | Description                                      |
|-----------------|-----------|--------------------------------------------------|
| `DC_VERSION`    | 8.4.0     | Dependency-Check CLI version to install          |
| `NVD_API_KEY`   | (empty)   | NVD API key for reliable DB download (recommended)|

## Environment Variables
| Variable        | Default         | Description                                      |
|-----------------|-----------------|--------------------------------------------------|
| `DC_DATA_DIR`   | /opt/dc-data    | Path to baked-in NVD database                    |
| `NVD_API_KEY`   | (from build arg)| Used by Dependency-Check for DB updates          |

---

## Best Practices
- **Rebuild the image regularly** (e.g., nightly) to keep the NVD database fresh.
- **Always use an NVD API key** to avoid rate limits and ensure reliable DB updates.
- **Use the `--data /opt/dc-data --noupdate` flags** in CI to ensure fast, offline scans.
- **Pin the Dependency-Check version** via `DC_VERSION` for reproducible builds.
- **Mount your code to `/workspace`** for consistent scan paths.

---

## Entrypoint & Custom Scripts
- The image uses a custom `entrypoint.sh` for flexible command execution.
- You can run any shell script or command as the container entrypoint.
- Example: `podman run ... owasp-dependency-check:latest bash /workspace/scripts/scan.sh`

---
