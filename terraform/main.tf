
provider "kubernetes" {
  config_path = "~/.kube/config"
}


resource "kubernetes_deployment" "my_app" {
  metadata {
    name = "my-app"
    labels = {
      app = "my-app"
    }
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "my-app"
      }
    }
    template {
      metadata {
        labels = {
          app = "my-app"
        }
      }
      spec {
        container {
  name  = "my-app"
  image = "my-app:latest"
  image_pull_policy = "IfNotPresent"

  port {
    container_port = 3000
  }
  resources {
    limits = {
      cpu    = "500m"
      memory = "512Mi"
    }
    requests = {
      cpu    = "250m"
      memory = "256Mi"
    }
  }
}
      }
    }
  }
}


resource "kubernetes_service" "my_app_service" {
  metadata {
    name = "my-app-service"
  }
  spec {
    selector = {
      app = "my-app"
    }
    port {
      port        = 80
      target_port = 3000
    }
    type = "NodePort"
  }
}


resource "kubernetes_ingress_v1" "my_app_ingress" {
  metadata {
    name = "my-app-ingress"
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
    }
  }
  spec {
    rule {
      host = "my-app.local"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.my_app_service.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}
