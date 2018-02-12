{
  "ignition":{
    "version":"2.0.0"
  },
  "storage":{
    "files":[
      {
        "filesystem":"root",
        "path":"/etc/coreos/docker-1.12",
        "contents":{
          "source":"data:,no%0A"
        }
      }
    ]
  },
  "systemd":{
    "units":[
      {
        "name":"containerd.service",
        "enable":true
      },
      {
        "name":"docker.service",
        "enable":true
      },
      {
        "name":"docker-registry.service",
        "enable":true,
        "contents":${docker_registry_service}
      },
      {
        "name":"var-lib-registry.mount",
        "enable":true,
        "contents":${var_lib_registry_mount}
      },
      {
        "name":"format-volume.service",
        "enable":${format_volume_enabled},
        "contents":${format_volume_service}
      }
    ]
  }
}
