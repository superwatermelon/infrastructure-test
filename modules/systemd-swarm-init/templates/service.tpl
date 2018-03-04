[Unit]
Requires=${requires}
After=${after}
[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/bash -c '/usr/bin/docker swarm init --force-new-cluster --availability drain --advertise-addr $(/usr/bin/curl http://169.254.169.254/latest/meta-data/local-ipv4) --listen-addr $(/usr/bin/curl http://169.254.169.254/latest/meta-data/local-ipv4):2377'
[Install]
WantedBy=multi-user.target
