job "storage-controller" {
  datacenters = ["dc1"]
  type        = "service"

  group "controller" {

    count = 1

    task "controller" {
      driver = "docker"

      config {
        image = "registry.k8s.io/sig-storage/smbplugin:v1.8.0"

        args = [
          "--v=5",
          "--endpoint=unix:///csi/csi.sock"
        ]

        privileged = true
      }

      csi_plugin {
        id        = "alexandria-smb"
        type      = "controller"
        mount_dir = "/csi"
      }

      resources {
        cpu    = 30
        memory = 100
      }
    }
  }
}