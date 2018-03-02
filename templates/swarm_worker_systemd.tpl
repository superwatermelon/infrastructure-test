[Unit]
Requires=docker.service
After=docker.service
[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/bash -c '/usr/bin/docker swarm join --token $(/usr/bin/docker -H ${swarm_manager_host} swarm join-token -q worker) ${swarm_manager_host}'
ExecStop=/bin/bash -c '/usr/bin/docker swarm leave'
[Install]
WantedBy=multi-user.target
