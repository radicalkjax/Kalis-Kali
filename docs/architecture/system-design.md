# 🏗️ System Architecture

## Overview

The Kali Linux Docker Container project provides a flexible, secure environment for security testing and malware analysis. The architecture supports multiple use cases through different container configurations.

## 🎨 High-Level Architecture

```mermaid
graph TB
    subgraph "Host System (macOS)"
        Docker[Docker Desktop]
        X11[XQuartz/X11]
        FS[File System]
    end
    
    subgraph "Container Layer"
        Base[Base Image: kalilinux/kali-rolling]
        Custom[Custom Kali Image]
        Secure[Secure Malware Image]
    end
    
    subgraph "Network Architecture"
        Bridge[Bridge Network]
        None[No Network]
        Internal[Internal Network]
        Honeypot[Honeypot Network]
    end
    
    subgraph "Access Methods"
        CLI[Docker Exec]
        X11F[X11 Forwarding]
    end
    
    Docker --> Base
    Base --> Custom
    Base --> Secure
    
    Custom --> Bridge
    Custom --> CLI
    Custom --> X11F
    
    Secure --> None
    Secure --> Internal
    Secure --> Honeypot
    
    X11 --> X11F
    FS --> Custom
    FS --> Secure
    
    style Base fill:#e1f5fe,stroke:#01579b,stroke-width:2px
    style Custom fill:#f3e5f5,stroke:#4a148c,stroke-width:2px
    style Secure fill:#ffebee,stroke:#b71c1c,stroke-width:2px
```

## 🐋 Container Types

### 1. Standard Kali Container

```mermaid
graph LR
    subgraph "Standard Kali Container"
        A[kali-custom:latest] --> B[GUI Support]
        A --> C[Full Network]
        A --> D[Development Tools]
        A --> E[Security Tools]
        
        B --> B1[XFCE4 Desktop]
        B --> B2[X11 Forwarding]
        B --> B3[Native Windows]
        
        C --> C1[Internet Access]
        C --> C2[Bridge Network]
        
        D --> D1[Go, Node.js, Python]
        D --> D2[Build Tools]
        D --> D3[Claude CLI]
        
        E --> E1[Top 10 Tools]
        E --> E2[Malware Analysis]
        E --> E3[Custom Tools]
    end
    
    style A fill:#e8f5e9,stroke:#1b5e20,stroke-width:3px
```

### 2. Malware Analysis Containers

```mermaid
graph TB
    subgraph "Security Levels"
        Static[Static Analysis<br/>Level 1]
        Dynamic[Dynamic Analysis<br/>Level 2]
        Sandbox[Sandbox<br/>Level 3]
    end
    
    subgraph "Static Features"
        S1[No Network]
        S2[Read-only FS]
        S3[Non-root User]
        S4[2GB RAM Limit]
    end
    
    subgraph "Dynamic Features"
        D1[Isolated Network]
        D2[Seccomp Enabled]
        D3[Limited Caps]
        D4[4GB RAM Limit]
    end
    
    subgraph "Sandbox Features"
        B1[Honeypot Net]
        B2[Auto-cleanup]
        B3[Ephemeral Storage]
        B4[Traffic Monitor]
    end
    
    Static --> S1 & S2 & S3 & S4
    Dynamic --> D1 & D2 & D3 & D4
    Sandbox --> B1 & B2 & B3 & B4
    
    style Static fill:#c8e6c9,stroke:#2e7d32,stroke-width:2px
    style Dynamic fill:#fff9c4,stroke:#f57f17,stroke-width:2px
    style Sandbox fill:#ffcdd2,stroke:#c62828,stroke-width:2px
```

## 🔐 Security Architecture

```mermaid
graph TD
    subgraph "Defense in Depth"
        L1[Container Isolation]
        L2[User Namespaces]
        L3[Capability Dropping]
        L4[Seccomp Profiles]
        L5[Resource Limits]
        L6[Network Isolation]
        L7[Filesystem Protection]
    end
    
    L1 --> L2
    L2 --> L3
    L3 --> L4
    L4 --> L5
    L5 --> L6
    L6 --> L7
    
    L1 -.-> |Docker Runtime| R1[Namespace Isolation]
    L2 -.-> |UID Mapping| R2[Non-root Execution]
    L3 -.-> |CAP_DROP ALL| R3[Minimal Privileges]
    L4 -.-> |Syscall Filtering| R4[Restricted System Calls]
    L5 -.-> |Cgroups| R5[CPU/Memory/PID Limits]
    L6 -.-> |Internal Networks| R6[No External Access]
    L7 -.-> |Read-only + tmpfs| R7[Immutable System]
    
    style L1 fill:#e3f2fd,stroke:#0d47a1,stroke-width:2px
    style L7 fill:#fce4ec,stroke:#880e4f,stroke-width:2px
```

## 🌐 Network Architecture

```mermaid
graph LR
    subgraph "Network Types"
        subgraph "Standard Network"
            SN[kali-net<br/>Bridge Network]
            SN --> Internet[Internet Access]
            SN --> Host[Host Communication]
        end
        
        subgraph "Isolated Network"
            IN[malware-isolated-net<br/>Internal Only]
            IN --> NoExt[No External Access]
            IN --> NoICC[No Container Comm]
        end
        
        subgraph "Honeypot Network"
            HN[malware-honeypot-net<br/>Monitored]
            HN --> Monitor[Traffic Capture]
            HN --> Fake[Fake Services]
        end
        
        subgraph "No Network"
            NN[network_mode: none]
            NN --> Complete[Complete Isolation]
        end
    end
    
    style SN fill:#e1f5fe,stroke:#0277bd,stroke-width:2px
    style IN fill:#fff3e0,stroke:#e65100,stroke-width:2px
    style HN fill:#fbe9e7,stroke:#bf360c,stroke-width:2px
    style NN fill:#efebe9,stroke:#3e2723,stroke-width:2px
```

## 📁 Storage Architecture

```mermaid
graph TD
    subgraph "Persistent Storage"
        Host[Host Filesystem]
        Workspace[./workspace]
        Config[./config]
        Malware[./malware/]
    end
    
    subgraph "Container Mounts"
        CW[/home/kali/workspace]
        CC[/home/kali/.config]
        CS[/samples :ro]
        CR[/reports :rw]
    end
    
    subgraph "Ephemeral Storage"
        Tmp[/tmp - tmpfs]
        VarTmp[/var/tmp - tmpfs]
        Cache[/.cache - tmpfs]
    end
    
    Workspace --> |Read/Write| CW
    Config --> |Read/Write| CC
    Malware --> |Read Only| CS
    Malware --> |Write Only| CR
    
    Host --> Tmp
    Host --> VarTmp
    Host --> Cache
    
    style Host fill:#f5f5f5,stroke:#424242,stroke-width:3px
    style Tmp fill:#e8f5e9,stroke:#2e7d32,stroke-width:2px
```

## 🚀 Build Process

```mermaid
graph TD
    A[Start Build] --> B{Which Container?}
    
    B -->|Standard| C[Pull kali-rolling:latest]
    B -->|Malware| D[Pull kali-rolling:latest]
    
    C --> E[Install Metapackages]
    E --> F[Add GUI Support]
    F --> G[Install Dev Tools]
    G --> H[Add Malware Tools]
    H --> I[Configure User]
    I --> J[Setup Scripts]
    J --> K[Standard Image Ready]
    
    D --> L[Minimal Install]
    L --> M[Security Tools Only]
    M --> N[Create malware User]
    N --> O[Lock Down Permissions]
    O --> P[Secure Image Ready]
    
    style A fill:#fff,stroke:#333,stroke-width:3px
    style K fill:#c8e6c9,stroke:#2e7d32,stroke-width:3px
    style P fill:#ffcdd2,stroke:#c62828,stroke-width:3px
```

## 🔄 Container Lifecycle

```mermaid
stateDiagram-v2
    [*] --> Building: docker-compose build
    Building --> Ready: Build Success
    Ready --> Running: docker-compose up
    Running --> Stopped: docker-compose stop
    Stopped --> Running: docker-compose start
    Running --> Removed: docker-compose down
    Removed --> [*]
    
    Running --> Exec: docker exec
    Exec --> Running: Exit
    
    Running --> Logs: docker logs
    Logs --> Running: View
    
    note right of Running : Active container
    note right of Stopped : Container preserved
    note right of Removed : Container deleted
```

## 📊 Resource Management

```mermaid
graph LR
    subgraph "Resource Limits"
        subgraph "Standard Container"
            SC[No Limits]
            SC --> SCM[Host Resources]
        end
        
        subgraph "Static Analysis"
            SA[Conservative]
            SA --> SAM[2GB RAM<br/>1 CPU<br/>200 PIDs]
        end
        
        subgraph "Dynamic Analysis"
            DA[Moderate]
            DA --> DAM[4GB RAM<br/>2 CPUs<br/>500 PIDs]
        end
        
        subgraph "Sandbox"
            SB[Restricted]
            SB --> SBM[2GB RAM<br/>1 CPU<br/>100 PIDs]
        end
    end
    
    style SC fill:#e8f5e9,stroke:#2e7d32,stroke-width:2px
    style SA fill:#e3f2fd,stroke:#1565c0,stroke-width:2px
    style DA fill:#fff3e0,stroke:#ef6c00,stroke-width:2px
    style SB fill:#ffebee,stroke:#c62828,stroke-width:2px
```

## 🎯 Use Case Flows

```mermaid
sequenceDiagram
    participant User
    participant Script
    participant Docker
    participant Container
    
    User->>Script: ./scripts/start-kali.sh
    Script->>Docker: docker pull kali-rolling
    Docker->>Script: Image updated
    Script->>Docker: docker-compose build
    Docker->>Script: Build complete
    Script->>Docker: docker-compose up -d
    Docker->>Container: Start container
    Container->>Docker: Running
    Docker->>Script: Container ID
    Script->>User: Access instructions
    
    User->>Docker: docker exec -it kali-workspace
    Docker->>Container: Execute bash
    Container->>User: Shell prompt
```

## 🏛️ Design Principles

1. **Layered Security**: Multiple isolation mechanisms
2. **Least Privilege**: Minimal capabilities by default
3. **Flexibility**: Multiple configuration options
4. **Persistence**: Separate data from containers
5. **Monitoring**: Logging and capture capabilities
6. **Automation**: Scripted workflows
7. **Documentation**: Clear usage patterns

## 🔗 Component Relationships

```mermaid
graph TB
    subgraph "External Dependencies"
        KaliRepo[Kali Repository]
        DockerHub[Docker Hub]
        GitHub[GitHub Repos]
    end
    
    subgraph "Build Components"
        Dockerfile[Dockerfiles]
        Compose[docker-compose.yml]
        Scripts[Shell Scripts]
    end
    
    subgraph "Runtime Components"
        Containers[Containers]
        Networks[Networks]
        Volumes[Volumes]
    end
    
    subgraph "User Interface"
        CLI[CLI Access]
        X11[X11 GUI Access]
    end
    
    KaliRepo --> Dockerfile
    DockerHub --> Dockerfile
    GitHub --> Scripts
    
    Dockerfile --> Compose
    Scripts --> Compose
    Compose --> Containers
    Compose --> Networks
    Compose --> Volumes
    
    Containers --> CLI
    Containers --> X11
    
    style KaliRepo fill:#e8f5e9,stroke:#2e7d32,stroke-width:2px
    style Containers fill:#e3f2fd,stroke:#1565c0,stroke-width:3px
```