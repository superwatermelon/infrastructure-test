[Unit]
Requires=var-lib-docker-swarm.mount
After=var-lib-docker-swarm.mount
[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/bin/chown -R docker:docker /var/lib/docker/swarm
[Install]
WantedBy=multi-user.target
