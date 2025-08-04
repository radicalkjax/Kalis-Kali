FROM kalilinux/kali-rolling:latest

ENV DEBIAN_FRONTEND=noninteractive

# Update and install Kali metapackages + essential additions
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y \
    # Complete Kali Linux installation
    kali-linux-everything \
    # GUI support - X11 forwarding instead of VNC
    xfce4 \
    xfce4-goodies \
    kali-menu \
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

# Install specialized malware analysis tools (not in kali-tools-top10)
RUN apt-get update && apt-get install -y \
    # Advanced RE tools (beyond radare2 which may be in top10)
    rizin \
    ghidra \
    edb-debugger \
    # Binary analysis
    hexedit \
    xxd \
    exiftool \
    # Dynamic analysis
    ltrace \
    gdbserver \
    valgrind \
    # Network analysis (beyond basic wireshark)
    tshark \
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

# Copy scripts
COPY --chown=kali:kali scripts/ /home/kali/scripts/
RUN chmod +x /home/kali/scripts/*.sh

# No ports needed for X11 forwarding
# EXPOSE removed - X11 uses unix socket

USER kali
WORKDIR /home/kali

# Simple entrypoint for X11
ENTRYPOINT ["/bin/zsh"]