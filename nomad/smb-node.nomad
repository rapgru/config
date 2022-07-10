job "storage-node" {
  datacenters = ["dc1"]
  type        = "system"

  group "node" {
    network {
      mode = "host"
    }

    task "node" {
      driver = "docker"

      config {
        image = "registry.k8s.io/sig-storage/smbplugin:v1.8.0"

        args = [
          "--v=5",
          "--endpoint=unix:///csi/csi.sock",
          "--nodeid=${node.unique.id}"
        ]

        privileged = true
      }

      csi_plugin {
        id        = "alexandria-smb"
        type      = "node"
        mount_dir = "/csi"
      }

      resources {
        cpu    = 30
        memory = 100
      }
    }
  }
}