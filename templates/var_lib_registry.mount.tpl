[Unit]
Requires=dev-${volume}1.device
After=dev-${volume}1.device swarm-manager-data-format.service
[Mount]
What=/dev/${volume}1
Where=/var/lib/registry
Type=ext4
[Install]
WantedBy=multi-user.target
