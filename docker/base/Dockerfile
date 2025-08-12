FROM kalilinux/kali-rolling:latest

ENV DEBIAN_FRONTEND=noninteractive

# Update and install Kali metapackages + essential additions
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y \
    # Base Kali Linux installation
    kali-linux-core \
    # GUI support - X11 forwarding instead of VNC
    xfce4 \
    xfce4-goodies \
    xfce4-whiskermenu-plugin \
    # Kali menu system - CRITICAL for Kali-specific menus
    kali-menu \
    kali-desktop-xfce \
    kali-themes \
    kali-defaults \
    # Menu support packages
    menu \
    menu-xdg \
    libgarcon-1-0 \
    libgarcon-common \
    # Desktop integration
    xdg-utils \
    desktop-file-utils \
    shared-mime-info \
    xauth \
    x11-apps \
    x11-utils \
    dbus-x11 \
    firefox-esr \
    # Shell enhancements (not in base)
    zsh \
    git \
    curl \
    wget \
    tmux \
    # Development tools (not in base)
    build-essential \
    cmake \
    pkg-config \
    libssl-dev \
    golang \
    nodejs \
    npm \
    python3-venv \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    python3-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Ensure Kali menu is properly set up
RUN if [ -x /usr/share/kali-menu/update-kali-menu ]; then \
        /usr/share/kali-menu/update-kali-menu; \
    fi && \
    # Verify kali-menu installation
    dpkg -l | grep kali-menu && \
    # Create applications-merged directory if missing
    mkdir -p /etc/xdg/menus/applications-merged && \
    # Update desktop database
    update-desktop-database /usr/share/applications || true

# Install specialized malware analysis tools (not in kali-tools-top10)
# Including tools required by XFCE panel launchers
RUN apt-get update && apt-get install -y \
    # Advanced RE tools (required by panel)
    rizin \
    ghidra \
    rizin-cutter \
    radare2 \
    edb-debugger \
    # Binary analysis (required by panel)
    binwalk \
    hexedit \
    xxd \
    exiftool \
    # Core tools for panel
    binutils \
    bsdextrautils \
    # Dynamic analysis
    ltrace \
    gdbserver \
    valgrind \
    # Network analysis (panel requires wireshark)
    wireshark \
    tshark \
    # Memory forensics (panel requires volatility3)
    volatility3 \
    # YARA for malware detection (panel launcher)
    yara \
    # Python RE libraries
    python3-pefile \
    python3-capstone \
    python3-keystone-engine \
    python3-unicorn \
    python3-pyelftools \
    # Windows analysis
    wine \
    wine64 \
    mono-complete \
    # Forensics (specialized)
    foremost \
    scalpel \
    sleuthkit \
    autopsy \
    # Virtualization
    qemu-system \
    qemu-user \
    qemu-user-static \
    # Archive tools
    upx-ucl \
    p7zip-full \
    unrar \
    cabextract \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create symlink for cutter (rizin-cutter backward compatibility)
RUN if [ -f /usr/bin/rizin-cutter ] && [ ! -f /usr/bin/cutter ]; then \
        ln -s /usr/bin/rizin-cutter /usr/bin/cutter; \
    fi

RUN useradd -m -s /bin/zsh kali && \
    echo "kali:kali" | chpasswd && \
    usermod -aG sudo kali

# Install oh-my-zsh for kali user
USER kali
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
USER root

# Setup X11 authentication
RUN mkdir -p /home/kali/.config && \
    touch /home/kali/.Xauthority && \
    chown -R kali:kali /home/kali/.config /home/kali/.Xauthority

# Install Claude Code
RUN npm install -g @anthropic-ai/claude-code && \
    mkdir -p /home/kali/.config/claude && \
    chown -R kali:kali /home/kali/.config

# Install Python malware analysis tools (core tools only for faster build)
# Using --break-system-packages as recommended for containers
# First install setuptools for packages that need distutils
RUN pip3 install --break-system-packages setuptools && \
    pip3 install --break-system-packages --ignore-installed \
    yara-python \
    pefile \
    pyelftools \
    capstone \
    unicorn \
    keystone-engine \
    ropper \
    cryptography \
    requests \
    beautifulsoup4 \
    lxml \
    oletools \
    python-magic \
    pyzipper \
    androguard \
    r2pipe \
    frida-tools \
    volatility3 \
    dnspython \
    impacket \
    scapy

# Install additional RE tools via git
RUN mkdir -p /opt/malware-tools && \
    cd /opt/malware-tools && \
    git clone https://github.com/fireeye/flare-floss && \
    git clone https://github.com/DissectMalware/XLMMacroDeobfuscator && \
    git clone https://github.com/volatilityfoundation/volatility3 && \
    chown -R kali:kali /opt/malware-tools

RUN mkdir -p /home/kali/workspace && \
    chown -R kali:kali /home/kali/workspace

# Create ensure-kali-menu script inline
RUN echo '#!/bin/bash\n\
if ! dpkg -l | grep -q "^ii  kali-menu "; then\n\
    echo "WARNING: kali-menu is not installed in the container!"\n\
    echo "Installing kali-menu and dependencies..."\n\
    apt-get update\n\
    apt-get install -y kali-menu kali-desktop-xfce\n\
fi\n' > /usr/local/bin/ensure-kali-menu.sh && \
    chmod +x /usr/local/bin/ensure-kali-menu.sh

# Copy user scripts
COPY --chown=kali:kali scripts/ /home/kali/scripts/
RUN chmod +x /home/kali/scripts/*.sh

# Create entrypoint script inline
RUN echo '#!/bin/bash\n\
# Ensure kali-menu is installed\n\
if [ "$EUID" -eq 0 ] || [ "$(id -u)" = "0" ]; then\n\
    /usr/local/bin/ensure-kali-menu.sh\n\
else\n\
    sudo /usr/local/bin/ensure-kali-menu.sh\n\
fi\n\
\n\
# Execute the command\n\
exec "$@"\n' > /usr/local/bin/docker-entrypoint.sh && \
    chmod +x /usr/local/bin/docker-entrypoint.sh

# No ports needed for X11 forwarding
# EXPOSE removed - X11 uses unix socket

USER kali
WORKDIR /home/kali

# Use custom entrypoint that ensures menu is available
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["/bin/zsh"]