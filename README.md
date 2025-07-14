<a name="top"></a>
# A Practical Guide to Managing Docker Services on Linux

---

## Why This Project Exists

**The Problem:**  
If you've ever managed more than a couple of Docker Compose projects or standalone containers on a Linux server, you know how quickly things get messy. Data ends up scattered, service management is inconsistent, and onboarding new developers or admins can be slow and error-prone.

**How This Helps:**  
This framework gives you a unified, developer-friendly way to organize, deploy, and manage Docker services. By combining systemd template units, a standardized directory layout, and handy shell utilities, it makes service management predictable, repeatable, and easy to automate.

---

## The Big Picture: Story, Code, and Context

### Why We Do It

- **Goal:**  
  Make deploying and managing Docker-based services on Linux simple and consistent.
- **Benefits:**  
  - All your data is easy to back up and migrate.
  - Services are managed natively by systemd for reliability.
  - New team members can get started quickly.
- **Design Choices:**  
  - Every service lives under `/srv/container/<service>/`.
  - Systemd template units (`docker-compose@.service`, `docker-container@.service`) let you manage many services with one unit file.
  - Bash utilities and aliases make daily tasks easier.

---

### How It Works (With Real Examples)

#### Directory Structure

```
/srv/container/
  <service>/
    data/    # Persistent data (volumes, configs, uploads)
    docker/  # Compose files, scripts
```

#### Example: Deploying the "homer" Dashboard

**Step 1: Create Service Directories**

```sh
create_service_dirs homer
# Creates /srv/container/homer/data and /srv/container/homer/docker
```

**Step 2: Add Your Compose File**

Copy your production-ready `docker-compose.yml` to `/srv/container/homer/docker/`.

```sh
sudo cp path/to/docker-compose.yml /srv/container/homer/docker/
```

**Step 3: Map Persistent Data (Relative Path Example)**

```yaml
# /srv/container/homer/docker/docker-compose.yml
services:
  homer:
    image: b4bz/homer
    volumes:
      - ../data/www/assets:/www/assets
    # ...other options...
```
*All persistent data ends up in `/srv/container/homer/data/www/assets`.*

**Step 4: Enable and Start the Service**

```sh
compose_systemctl homer enable
compose_systemctl homer start
```
Or, using systemd directly:
```sh
sudo systemctl enable docker-compose@homer.service
sudo systemctl start docker-compose@homer.service
```

**Step 5: Jump to Service Directory**

```sh
cdcontainer homer
```

---

### When and Where to Use This

- **Where:**  
  - Any Linux server with systemd and Docker installed.
  - Any service you want to run as a container or Compose stack.
- **When:**  
  - When you want reliable, repeatable service management.
  - When you want all persistent data in a predictable location for backup/migration.
- **Integration:**  
  - Works with CI/CD pipelines (just copy files and run systemctl).
  - Easy to integrate with backup scripts (just backup `/srv/container`).
  - Can be adapted for Podman or other container runtimes.

### When you should NOT use it 

- Single or Very Simple Container Setups: When managing only one or a few basic containers where standardization and centralized management aren't a priority.
- Large-Scale Multi-Server Orchestration: For distributed applications requiring advanced features like auto-scaling, load balancing across multiple nodes, or cluster management (e.g., Kubernetes, Docker Swarm).
- Existing Incompatible CI/CD Pipelines: When current CI/CD workflows do not align with the project's standardized directory structure or systemd integration.
- For Complete Beginners to Docker/Systemd: If users lack foundational knowledge of Docker, Docker Compose, or systemd, as a basic understanding is still beneficial.
- Preference for GUI-Based Management: When a graphical user interface is primarily desired for container management instead of command-line tools.

---

## Getting Started Fast

- **Quickstart:**  
  See [Quickstart](#quickstart) for setup instructions.
- **Common Commands:**  
  - `compose_systemctl <service> status` — Check status
  - `compose_systemctl <service> restart` — Restart service
  - `cdcontainer <service>` — Jump to service directory

---

## Want to Know More?

- **Systemd Template Units:**  
  - [`docker-compose@.service`](etc/systemd/system/docker-compose@.service): Manages Compose stacks.
  - [`docker-container@.service`](etc/systemd/system/docker-container@.service): Manages single containers.
  - See [Systemd Units](#systemd-units) for details.
- **Bash Utilities & Aliases:**  
  - See [home/nas/.bash_functions](home/nas/.bash_functions) and [home/nas/.bash_aliases](home/nas/.bash_aliases).

---

## Real-World Examples

### Add a New Service

```sh
create_service_dirs nextcloud
sudo cp path/to/nextcloud-compose.yml /srv/container/nextcloud/docker/docker-compose.yml
compose_systemctl nextcloud enable
compose_systemctl nextcloud start
```

### Remove a Service

```sh
compose_systemctl nextcloud stop
sudo systemctl disable docker-compose@nextcloud.service
sudo rm -rf /srv/container/nextcloud
```

### List All Running Containers

```sh
dps
```

---

## How Everything Fits Together

### Visual Overview

```
[systemd] <-> [docker-compose@.service] <-> [/srv/container/<service>/docker/docker-compose.yml]
                                      |
                                      +-> [Persistent Data: /srv/container/<service>/data]
```

### Key Points

- One directory per service.
- One systemd unit per service.
- One command to manage each service.

---

## Troubleshooting & Failure Scenarios

### Common Issues

- **Service fails to start:**  
  - Check logs: `sudo journalctl -u docker-compose@<service>.service`
  - Verify Docker Compose file syntax.
  - Make sure `/srv/container/<service>/docker` and `/srv/container/<service>/data` exist and have correct permissions.

- **Data not persisted:**  
  - Check volume mapping in `docker-compose.yml`.
  - Use absolute or relative paths as shown in examples.

- **Tab completion not working for `cdcontainer`:**  
  - Make sure `.bash_functions` is sourced in your shell.

### Debugging Tips

- Use `compose_systemctl <service> status` for quick health checks.
- Use `docker logs <container>` for container-level debugging.
- Use `ll /srv/container/<service>/data` to inspect persistent files.

---

## How This Fits Into Your Workflow

- **Version Control:**  
  - Store your Compose files and systemd unit templates in Git.
  - Use branches for service upgrades or migrations.
- **Automatic Generation:**  
  - Use scripts to scaffold new services (`create_service_dirs`).
  - Integrate with CI/CD for automated deployment.

---

## References

- [docker-compose@.service](etc/systemd/system/docker-compose@.service)
- [docker-container@.service](etc/systemd/system/docker-container@.service)
- [home/nas/.bash_functions](home/nas/.bash_functions)
- [home/nas/.bash_aliases](home/nas/.bash_aliases)
- [srv/container/homer/docker/docker-compose.yml](srv/container/homer/docker/docker-compose.yml)

---

## FAQ

**Q: Can I use Podman instead of Docker?**  
A: Yes, with minor changes to the systemd unit files and Compose commands.

**Q: How do I back up all my service data?**  
A: Back up `/srv/container` — all persistent data lives there.

**Q: How do I add custom environment variables or ports?**  
A: Edit your service's `docker-compose.yml` in `/srv/container/<service>/docker/`.

---

<a href="#top">Back to top</a>
