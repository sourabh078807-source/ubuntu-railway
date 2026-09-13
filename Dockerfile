FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
        wget curl git python3 python3-pip \
        ca-certificates neofetch ripgrep iproute2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN wget -qO /bin/ttyd \
    https://github.com/tsl0922/ttyd/releases/download/1.7.3/ttyd.x86_64 && \
    chmod +x /bin/ttyd

RUN curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash

RUN echo "neofetch" >> /root/.bashrc && \
    echo "cd /root" >> /root/.bashrc

RUN cat > /root/start-hermes.sh <<'EOF'
#!/bin/bash
set -e

echo "=== HERMES AGENT 24/7 STARTING ==="

PORT="${PORT:-8080}"

echo "[Hermes] Starting web terminal..."
/bin/ttyd \
    -p "$PORT" \
    -c "${USERNAME}:${PASSWORD}" \
    /bin/bash &

TTYD_PID=$!

cleanup() {
    kill "$TTYD_PID" 2>/dev/null || true
}

trap cleanup EXIT TERM INT

echo "[Hermes] Starting Gateway..."
exec hermes gateway run
EOF

RUN chmod +x /root/start-hermes.sh

EXPOSE 8080

CMD ["/root/start-hermes.sh"]
