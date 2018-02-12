[Unit]
Requires=dev-${volume}.device
After=dev-${volume}.device
[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/bash -xc "parted /dev/${volume} mklabel gpt mkpart primary 0%% 100%% && mkfs.ext4 /dev/${volume}1"
[Install]
WantedBy=multi-user.target
