# Docker Service Management System

This system provides a structured way to manage Docker Compose projects and standalone containers on a server. It uses a standardized directory layout, custom Bash utilities, and systemd unit files to simplify deployment, management, and extension of services.
This can probably be done also with podman, I just not yet tried.

## Table of Contents

- [Quickstart](#quickstart)
- [Directory Structure](#directory-structure)
- [Systemd Units](#systemd-units)
- [Bash Utilities](#bash-utilities)
- [Aliases](#aliases)
- [Adding a New Service](#adding-a-new-service)
- [Example](#example)
- [Notes](#notes)
- [References](#references)

---

## Quickstart

Follow these steps to set up this system on a fresh Linux installation with systemd:

### 1. Prerequisites

- A Linux system with `systemd`
- Docker and Docker Compose installed (`docker` and `docker compose` commands available)
- Sudo privileges

### 2. Copy Template Files

Clone or copy the template repository to your server. Then:

- **Systemd unit files:**  
  Copy `docker-compose@.service` and `docker-container@.service` to `/etc/systemd/system/`:
  ```sh
  sudo cp etc/systemd/system/docker-compose@.service /etc/systemd/system/
  sudo cp etc/systemd/system/docker-container@.service /etc/systemd/system/
  sudo systemctl daemon-reload
  ```

- **Bash functions and aliases:**  
  Append or source the provided Bash functions and aliases in your shell configuration (e.g., `~/.bashrc`):
  ```sh
  cat home/nas/.bash_functions >> ~/.bashrc
  cat home/nas/.bash_aliases >> ~/.bashrc
  # Or, to keep them separate and source them:
  echo 'source ~/nas_template/home/nas/.bash_functions' >> ~/.bashrc
  echo 'source ~/nas_template/home/nas/.bash_aliases' >> ~/.bashrc
  source ~/.bashrc
  ```

### 3. Create the Base Directory

Create the main container directory if it does not exist:
```sh
sudo mkdir -p /srv/container
sudo chown $USER: /srv/container
```

### 4. Add Your First Service

See the [Example](#example) section below for a step-by-step guide.

---

## Directory Structure

All persistent data and Docker configurations are stored under `/srv/container/<service>/`:

```
/srv/container/
  <service>/
    data/    # Persistent data for the service
    docker/  # Docker Compose files and scripts
```

- **data/**: Used for volumes and persistent storage.
- **docker/**: Contains `docker-compose.yml` and related scripts.

---

## Systemd Units

Two main systemd unit templates are provided:

### [`docker-compose@.service`](etc/systemd/system/docker-compose@.service)

Manages Docker Compose projects as systemd services.

- **Usage:**  
  `sudo systemctl start docker-compose@<service>.service`
- **Working Directory:** `/srv/container/<service>/docker`
- **Executes:**  
  `docker compose --project-name <service> up -d --remove-orphans`

### [`docker-container@.service`](etc/systemd/system/docker-container@.service)

Manages single Docker containers as systemd services.

- **Usage:**  
  `sudo systemctl start docker-container@<service>.service`
- **Working Directory:** `/srv/container/<service>/docker`
- **Executes:**  
  Custom `start.sh` script or direct Docker commands.

---

## Bash Utilities

Add these to your `.bashrc` or source them directly.

### [`compose_systemctl`](home/nas/.bash_functions)

Run systemctl commands for Docker Compose services in a simplified way.

- **Usage:**  
  `compose_systemctl <service> [command]`

  - `<service>`: The name of your service (e.g., `homer`)
  - `[command]`: The systemctl command to run (e.g., `status`, `restart`, `stop`, `start`). If omitted, defaults to `status`.

- **How it works:**  
  `compose_systemctl` is a Bash function that wraps `sudo systemctl <command> docker-compose@<service>.service`.  
  For example:
  - `compose_systemctl homer status`  
    → runs `sudo systemctl status docker-compose@homer.service`
  - `compose_systemctl homer restart`  
    → runs `sudo systemctl restart docker-compose@homer.service`

- **Examples:**  
  - `compose_systemctl homer status`  
  - `compose_systemctl homer restart`

### [`cdcontainer`](home/nas/.bash_functions)

Quickly change directory to a service's container folder.

- **Usage:**  
  `cdcontainer <service>`
- **Tab completion** is supported for existing services.

---

## Aliases

See [`home/nas/.bash_aliases`](home/nas/.bash_aliases) for helpful Docker and system management aliases, such as:

- `dim` — List Docker images in a custom format.
- `dps` — List Docker containers in a custom format.
- `drmc` — Stop and remove a container.
- `drmi` — Remove a Docker image.
- `create_service_dirs` — Create the standard directory structure for a new service.

---

## Adding a New Service

1. **Create directories:**
   ```sh
   create_service_dirs <service>
   ```
2. **Add your `docker-compose.yml` or scripts** to `/srv/container/<service>/docker/`.
3. **Enable and start the service:**
   ```sh
   compose_systemctl <service> enable
   compose_systemctl <service> start
   ```
   Or for single containers:
   ```sh
   sudo systemctl enable docker-container@<service>.service
   sudo systemctl start docker-container@<service>.service
   ```

---

## Example

Suppose you want to add a service called `homer`. Here’s how you would set it up and where your persistent data will live:

```sh
create_service_dirs homer
# This creates:
# /srv/container/homer/data/
# /srv/container/homer/docker/

# Copy your docker-compose.yml to /srv/container/homer/docker/
sudo cp path/to/your/docker-compose.yml /srv/container/homer/docker/

# Enable and start the service using compose_systemctl:
compose_systemctl homer enable
compose_systemctl homer start
```

**Directory Layout for `homer`:**

```
/srv/container/homer/
  data/    # Persistent data for the homer service (e.g., configs, databases, uploads)
  docker/  # Contains docker-compose.yml and related scripts
```

**How to use the data directory:**

When writing your `docker-compose.yml`, make sure to map any persistent volumes to `/srv/container/homer/data`. For example:

```yaml
# /srv/container/homer/docker/docker-compose.yml
services:
  homer:
    image: b4bz/homer
    container_name: homer
    volumes:
      - ../data:/www/assets
    # ...other options...
```

> **Note:**  
> The `data` directory is always located at `/srv/container/<service>/data`.  
> In this example, all persistent data for the `homer` service will be stored in `/srv/container/homer/data`, which is outside the container and survives upgrades, restarts, or container removal.  
> This makes it easy to back up, migrate, or inspect your service's data.
> I prefer to ue relative directory to the compose file, because the structure of the `/srv/container/` is fixed. This makes the whole structure _theoretically_ independent from the path (never tested).

You can quickly jump to the service directory using:

```sh
cdcontainer homer
```

This will take you to `/srv/container/homer/`, where you can access both the `data` and `docker` directories.

---

## Notes

- All persistent data should be mapped to `/srv/container/<service>/data` in your Docker Compose or Docker run configurations.
- The systemd units ensure services start on boot and are managed consistently.
- Use the provided Bash functions and aliases to simplify daily operations.

---

## References

- [docker-compose@.service](etc/systemd/system/docker-compose@.service)
- [docker-container@.service](etc/systemd/system/docker-container@.service)
- [home/nas/.bash_functions](home/nas/.bash_functions)
- [home/nas/.bash_aliases](home/nas/.bash_aliases)