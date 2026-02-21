# Package Upgrade Strategy

How package upgrades are handled in the Plex Media Server
add-on.

## Overview

The add-on uses a **hybrid pinning strategy** to balance
security, stability, and maintainability:

- **Base Image (debian-base):** Semantic versioning for automatic security patches
- **Plex Media Server:** Manually pinned for stability and testing
- **System Dependencies:** Locked implicitly through base image versioning

## Base Image Updates

The `build.yaml` specifies `debian-base:8` (without patch version), which means:

✅ **Automatically receives:**

- Security patches (8.0.x → 8.0.y)
- Minor updates (8.0.x → 8.1.x)

⚠️ **Requires manual review:**

- Major version updates (8.x → 9.x)

This ensures the container stays secure without breaking
changes from major version jumps.

## Plex Media Server Updates

Plex versions are pinned in the Dockerfile using:

```dockerfile
ARG PLEX_VERSION=1.43.0.10492
ARG PLEX_HASH=121068a07
```

### Automated Detection

A GitHub Actions workflow (`plex-version-check.yaml`) runs every 3 days to:

1. Check the latest Plex version from `https://plex.tv/api/downloads/1.json`
2. Compare against the version in `Dockerfile`
3. Automatically create a pull request if a new version is available

### Manual Update Process

When a new version is detected:

1. **Review the PR:** Check
   [Plex release notes](https://support.plex.tv/articles/201539776/)
   for breaking changes
2. **Calculate the hash:**

   ```bash
   # Download the binary for your architecture
   curl -O https://# [plex download URL]
   sha256sum plexmediaserver_*.deb
   ```

3. **Update the Dockerfile:**

   ```dockerfile
   ARG PLEX_VERSION=X.Y.Z.XXXXX
   ARG PLEX_HASH=xxxxxxxxxxxxxxx
   ```

4. **Test locally:**

   ```bash
   docker build -t plex:test plex/
   docker run --rm -it plex:test \
     /usr/lib/plexmediaserver/Plex\ Media\ Server --version
   ```

5. **Merge the PR** after verification

## System Dependencies

System packages (curl, gnupg2, ca-certificates,
apt-transport-https) are managed by base image pinning
strategy. They receive updates automatically through
debian-base image updates.

## Version Lock File

| Component   | Strategy  | Update   |
| ----------- | --------- | -------- |
| Base Image  | Semantic  | Auto     |
| Plex Core   | Exact     | Manual   |
| System Libs | Implicit  | Auto     |

## Security Considerations

- **Security patches:** Applied automatically via base image
  updates
- **Major upgrades:** For Plex, reviewed manually; for base,
  requires deliberate action
- **Testing:** New Plex versions should be tested in
  non-production environment first
