[Unit]
Requires=${requires}
After=${after}
[Service]
Restart=always
ExecStartPre=/usr/bin/docker pull registry:${image_tag}
ExecStart=/usr/bin/docker run --rm --publish ${host_port}:5000 --volume ${mount_point}:/var/lib/registry --name registry registry:${image_tag}
[Install]
WantedBy=multi-user.target
