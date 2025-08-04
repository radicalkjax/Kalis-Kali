# 🔧 Troubleshooting Guide

This guide helps you resolve common issues with the Kali Linux Docker containers.

## 🚨 Quick Diagnosis

```mermaid
graph TD
    A[Problem Occurs] --> B{Container Running?}
    B -->|No| C[Check Docker]
    B -->|Yes| D{Can Access?}
    
    C --> E[docker ps]
    C --> F[Docker Desktop Status]
    
    D -->|No| G[Check Ports]
    D -->|Yes| H{GUI Works?}
    
    G --> I[Check Docker ports]
    G --> J[docker ps]
    
    H -->|No| K[Check X11/XQuartz]
    H -->|Yes| L[Check Logs]
    
    K --> M[XQuartz Running?]
    L --> N[docker logs container]
    
    style A fill:#ffcdd2,stroke:#d32f2f,stroke-width:3px
    style B fill:#fff9c4,stroke:#f57f17,stroke-width:2px
```

## 🐛 Common Issues & Solutions

### 1. Docker Daemon Not Running

**Symptoms:**
```
Cannot connect to the Docker daemon at unix:///var/run/docker.sock
```

**Solution:**
```bash
# Start Docker Desktop
open -a Docker

# Wait for Docker to start (check menu bar icon)
# Verify Docker is running
docker version

# If still not working, restart Docker Desktop
osascript -e 'quit app "Docker"'
sleep 5
open -a Docker
```

### 2. Port Already in Use

**Symptoms:**
```
Error: bind: address already in use
```

**Diagnosis & Fix:**
```mermaid
graph LR
    A[Port Conflict] --> B[Find Process]
    B --> C[Kill Process]
    C --> D[Or Change Port]
    
    B --> |lsof -i :5901| E[Process Info]
    C --> |kill -9 PID| F[Free Port]
    D --> |Edit compose| G[New Port]
    
    style A fill:#ffcdd2,stroke:#d32f2f,stroke-width:2px
    style F fill:#c8e6c9,stroke:#388e3c,stroke-width:2px
    style G fill:#c8e6c9,stroke:#388e3c,stroke-width:2px
```

```bash
# Find what's using the port
lsof -i :5901
lsof -i :6080

# Kill the process (replace PID)
kill -9 <PID>

# Or change ports in docker-compose.yml if needed
```

### 3. X11 Forwarding Not Working

**Symptoms:**
- GUI apps won't start
- "Cannot open display" errors

**Fix Process:**

```mermaid
sequenceDiagram
    participant User
    participant XQuartz
    participant Docker
    participant Container
    
    User->>XQuartz: Start XQuartz
    XQuartz-->>User: Running
    User->>XQuartz: Enable networking
    User->>XQuartz: xhost +localhost
    User->>Docker: Set DISPLAY
    Docker->>Container: Pass DISPLAY env
    Container->>XQuartz: Connect to X11
    XQuartz-->>Container: Display GUI
```

```bash
# 1. Start XQuartz
open -a XQuartz

# 2. Configure XQuartz
defaults write org.xquartz.X11 enable_iglx -bool true
defaults write org.xquartz.X11 nolisten_tcp -bool false

# 3. Allow connections
xhost +localhost
xhost +$(ipconfig getifaddr en0)

# 4. Test with simple X11 app
docker exec -e DISPLAY=host.docker.internal:0 kali-workspace xclock
```

### 5. Container Keeps Restarting

**Symptoms:**
- Container status shows "Restarting"
- Cannot exec into container

**Debugging:**
```bash
# Check logs
docker logs kali-workspace --tail 50

# Check events
docker events --filter container=kali-workspace

# Stop restart loop
docker update --restart=no kali-workspace
docker stop kali-workspace

# Fix and restart
docker start kali-workspace
```

### 6. Out of Disk Space

**Symptoms:**
```
No space left on device
```

**Cleanup Commands:**
```bash
# Check Docker disk usage
docker system df

# Clean up unused resources
docker system prune -a --volumes

# Remove old images
docker image prune -a

# Clear build cache
docker builder prune

# Check host disk space
df -h
```

### 7. Slow Performance

**Diagnosis:**
```mermaid
graph TD
    A[Slow Performance] --> B{Check Resources}
    B --> C[Docker Resources]
    B --> D[Container Limits]
    B --> E[Host System]
    
    C --> F[Docker Desktop Settings]
    D --> G[docker stats]
    E --> H[Activity Monitor]
    
    F --> I[Increase RAM/CPU]
    G --> J[Resource Usage]
    H --> K[System Load]
    
    style A fill:#ffeb3b,stroke:#f57f17,stroke-width:2px
```

**Solutions:**
```bash
# 1. Check container resources
docker stats kali-workspace

# 2. Increase Docker Desktop resources
# Docker Desktop → Settings → Resources
# Increase CPUs and Memory

# 3. Remove resource limits (if set)
docker update --memory=0 --cpus=0 kali-workspace

# 4. Restart container
docker restart kali-workspace
```

### 8. Network Issues

**Symptoms:**
- Cannot reach internet from container
- DNS resolution fails

**Fixes:**
```bash
# 1. Check network inside container
docker exec kali-workspace ping -c 3 8.8.8.8
docker exec kali-workspace nslookup google.com

# 2. Restart Docker network
docker network prune
docker-compose down
docker-compose up -d

# 3. Check DNS settings
docker exec kali-workspace cat /etc/resolv.conf

# 4. Use custom DNS
# Add to docker-compose.yml:
# dns:
#   - 8.8.8.8
#   - 8.8.4.4
```

### 9. Build Failures

**Common Build Errors:**

```mermaid
graph LR
    A[Build Fails] --> B{Error Type}
    B -->|Network| C[Proxy/DNS Issues]
    B -->|Package| D[Repository Problems]
    B -->|Space| E[Disk Full]
    B -->|Cache| F[Corrupted Cache]
    
    C --> G[Check Internet]
    D --> H[Update Sources]
    E --> I[Clean Space]
    F --> J[Clear Cache]
    
    style A fill:#ffcdd2,stroke:#d32f2f,stroke-width:2px
```

**Solutions:**
```bash
# 1. Clear cache and rebuild
docker builder prune
docker-compose build --no-cache

# 2. Update base image
docker pull kalilinux/kali-rolling:latest

# 3. Build with debug output
docker-compose build --progress=plain

# 4. Check Dockerfile syntax
docker build -f docker/base/Dockerfile . --no-cache
```

### 10. Permission Denied Errors

**Symptoms:**
- Cannot write to mounted volumes
- Permission denied in workspace

**Fixes:**
```bash
# 1. Check ownership
ls -la workspace/

# 2. Fix permissions on host
chmod -R 755 workspace/
chmod -R 755 config/

# 3. Run as root (temporary)
docker exec -u root kali-workspace /bin/bash

# 4. Fix inside container
docker exec -u root kali-workspace chown -R kali:kali /home/kali/workspace
```

## 🛠️ Advanced Debugging

### Container Inspection

```bash
# Full container details
docker inspect kali-workspace

# Check mounts
docker inspect kali-workspace | jq '.[0].Mounts'

# Check environment
docker inspect kali-workspace | jq '.[0].Config.Env'

# Check networks
docker inspect kali-workspace | jq '.[0].NetworkSettings'
```

### Process Debugging

```bash
# See all processes
docker exec kali-workspace ps aux

# Check specific service
docker exec kali-workspace supervisorctl status

# View supervisor logs
docker exec kali-workspace tail -f /var/log/supervisor/supervisord.log
```

### Network Debugging

```bash
# Test connectivity
docker exec kali-workspace curl -I https://google.com

# Check routing
docker exec kali-workspace ip route

# List interfaces
docker exec kali-workspace ip addr

# Check iptables (as root)
docker exec -u root kali-workspace iptables -L
```

## 📊 Performance Monitoring

```mermaid
graph TD
    A[Monitor Performance] --> B[Host Level]
    A --> C[Container Level]
    A --> D[Application Level]
    
    B --> E[Activity Monitor]
    B --> F[iostat/vmstat]
    
    C --> G[docker stats]
    C --> H[docker top]
    
    D --> I[htop in container]
    D --> J[Application logs]
    
    style A fill:#e1f5fe,stroke:#01579b,stroke-width:2px
```

```bash
# Real-time stats
docker stats --no-stream

# Container processes
docker top kali-workspace

# Inside container monitoring
docker exec -it kali-workspace htop
```

## 🔄 Recovery Procedures

### Complete Reset

```bash
# 1. Stop everything
docker-compose down -v

# 2. Clean Docker system
docker system prune -a --volumes

# 3. Remove directories
rm -rf workspace/* config/* malware/*

# 4. Rebuild fresh
./scripts/start-kali.sh
```

### Backup & Restore

```bash
# Backup workspace
tar -czf kali-backup-$(date +%Y%m%d).tar.gz workspace/ config/

# Restore workspace
tar -xzf kali-backup-20250115.tar.gz
```

## 📞 Getting Help

1. **Check Logs First:**
   ```bash
   docker logs kali-workspace --tail 100
   ```

2. **Gather System Info:**
   ```bash
   docker version
   docker-compose version
   uname -a
   ```

3. **Create Issue Report:**
   - Error messages
   - Steps to reproduce
   - System information
   - Container logs

## 🔗 Quick Reference

| Issue | Command | Solution |
|-------|---------|----------|
| Container not running | `docker ps -a` | `docker start kali-workspace` |
| Port conflict | `docker ps` | Change port or kill process |
| No GUI | `xhost +localhost` | Start XQuartz first |
| Slow performance | `docker stats` | Increase resources |
| Network issues | `docker exec kali-workspace ping 8.8.8.8` | Check DNS/firewall |
| Disk space | `docker system df` | `docker system prune -a` |

---

**Still having issues? Check the logs and documentation, or file an issue with detailed information.**