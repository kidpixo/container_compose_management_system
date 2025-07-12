<a name="top"></a>
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

<a href="#top">[top]</a>
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

<a href="#top">[top]</a>
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

<a href="#top">[top]</a>
## Systemd Units

Two main **template systemd units** are provided in this setup: [`docker-compose@.service`](etc/systemd/system/docker-compose@.service) and [`docker-container@.service`](etc/systemd/system/docker-container@.service).  
A **template unit** in systemd is a special kind of unit file that uses an `@` in its name and can be instantiated for different services by specifying an instance name (e.g., `docker-compose@homer.service`). This allows you to use a single unit file to manage multiple, similarly-structured services.

### [`docker-compose@.service`](etc/systemd/system/docker-compose@.service)

This template unit is designed to manage Docker Compose projects as systemd services.  
When you run `sudo systemctl start docker-compose@homer.service`, systemd will:

- Set the working directory to `/srv/container/homer/docker` (using `%i` for the instance name).
- Run `docker compose --project-name homer up -d --remove-orphans` to start the service in detached mode.
- On stop, run `docker compose --project-name homer down` to stop and remove the containers.
- The `RemainAfterExit=true` option means systemd will consider the service active even after the command completes, which is suitable for one-shot commands like Docker Compose.

**Key lines from the unit file:**
```ini
[Service]
RemainAfterExit=true
WorkingDirectory=/srv/container/%i/docker
ExecStart=/usr/bin/docker compose --project-name %i up -d --remove-orphans
ExecStop=/usr/bin/docker  compose --project-name %i down
Type=oneshot
```

This means you can manage each Docker Compose project as a native systemd service, enabling you to use standard commands like `start`, `stop`, `restart`, and `status` for each service instance.

### [`docker-container@.service`](etc/systemd/system/docker-container@.service)

This template unit is for managing single Docker containers (not Compose projects).  
It expects a `start.sh` script in `/srv/container/<service>/docker/` to launch the container, and will stop/remove the container on service stop.

---

**In summary:**  
Template systemd units allow you to manage multiple Docker Compose projects or containers in a uniform way, using a single unit file and the instance name as a parameter. This makes it easy to add, remove, or manage services without duplicating configuration.

---

<a href="#top">[top]</a>
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

<a href="#top">[top]</a>
## Aliases

See [`home/nas/.bash_aliases`](home/nas/.bash_aliases) for helpful Docker and system management aliases, such as:

- `dim` — List Docker images in a custom format.
- `dps` — List Docker containers in a custom format.
- `drmc` — Stop and remove a container.
- `drmi` — Remove a Docker image.
- `create_service_dirs` — Create the standard directory structure for a new service.

---

<a href="#top">[top]</a>
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

<a href="#top">[top]</a>
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

<a href="#top">[top]</a>
## Notes

- All persistent data should be mapped to `/srv/container/<service>/data` in your Docker Compose or Docker run configurations.
- The systemd units ensure services start on boot and are managed consistently.
- Use the provided Bash functions and aliases to simplify daily operations.

---

<a href="#top">[top]</a>
## References

- [docker-compose@.service](etc/systemd/system/docker-compose@.service)
- [docker-container@.service](etc/systemd/system/docker-container@.service)
- [home/nas/.bash_functions](home/nas/.bash_functions)
- [home/nas/.bash_aliases](home/nas/.bash_aliases)

<a href="#top">[top]</a>
