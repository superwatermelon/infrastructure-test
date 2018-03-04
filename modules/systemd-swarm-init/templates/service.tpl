[Unit]
Requires=${requires}
After=${after}
[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/bash -c '/usr/bin/docker swarm init --force-new-cluster --advertise-addr $(/usr/bin/curl http://169.254.169.254/latest/meta-data/local-ipv4)'
ExecStart=/bin/bash -c '/usr/bin/docker node update --availability drain $(/usr/bin/docker node inspect --format '{{.ID}}' self)'
Restart=on-failure
RestartSec=5
StartLimitInterval=0
[Install]
WantedBy=multi-user.target
