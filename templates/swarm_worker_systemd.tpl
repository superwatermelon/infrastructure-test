[Unit]
Requires=docker.service
After=docker.service
[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/bash -c 'docker swarm join --token $(docker -H ${swarm_manager_host} swarm join-token -q worker) ${swarm_manager_host}'
[Install]
WantedBy=multi-user.target
