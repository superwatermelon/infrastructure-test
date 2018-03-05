[Unit]
Requires=${requires}
After=${after}
[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/bash -xc 'if [[ "$(docker info --format '{{.Swarm.ControlAvailable}}')" != "true" ]] ; then until /usr/bin/docker swarm init --force-new-cluster --availability drain --advertise-addr $(/usr/bin/curl http://169.254.169.254/latest/meta-data/local-ipv4) --listen-addr $(/usr/bin/curl http://169.254.169.254/latest/meta-data/local-ipv4):2377 ; do sleep 5 ; done ; fi'
[Install]
WantedBy=multi-user.target
