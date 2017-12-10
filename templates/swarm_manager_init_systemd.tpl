[Unit]
Requires=docker.service
After=docker.service
[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/bash -c 'docker swarm init --advertise-addr $(curl http://169.254.169.254/latest/meta-data/local-ipv4)'
[Install]
WantedBy=multi-user.target
