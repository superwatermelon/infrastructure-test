[Unit]
Requires=docker.service
After=docker.service
[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/bash -c '\
  /usr/bin/docker -H ${swarm_manager_host} swarm join-token -q worker | \
  /usr/bin/xargs -I{} /usr/bin/docker swarm join \
    --token {} ${swarm_manager_host}'
ExecStop=/bin/bash -c '\
  /usr/bin/docker node inspect self --format "{{.ID}}" | \
  /usr/bin/xargs /usr/bin/docker node update --availability drain && \
  /usr/bin/docker swarm leave'
[Install]
WantedBy=multi-user.target
