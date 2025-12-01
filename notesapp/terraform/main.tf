terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.27"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

variable "ingress_host" {
  type        = string
  description = "FQDN utilisé par l’Ingress (ex: notes.192.168.49.2.nip.io)"
}

# Namespace
resource "kubernetes_namespace" "notes" {
  metadata {
    name = "notesapp"
  }
}

# Secret Postgres
resource "kubernetes_secret" "postgres_secret" {
  metadata {
    name      = "postgres-secret"
    namespace = kubernetes_namespace.notes.metadata[0].name
  }

  data = {
    POSTGRES_PASSWORD = "changeme"
  }

  type = "Opaque"
}

# PVC pour Postgres
resource "kubernetes_persistent_volume_claim" "postgres_pvc" {
  metadata {
    name      = "postgres-pvc"
    namespace = kubernetes_namespace.notes.metadata[0].name
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}

# Deployment Postgres
resource "kubernetes_deployment" "postgres" {
  metadata {
    name      = "notes-db"
    namespace = kubernetes_namespace.notes.metadata[0].name
    labels = {
      app = "notes-db"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "notes-db"
      }
    }

    template {
      metadata {
        labels = {
          app = "notes-db"
        }
      }

      spec {
        container {
          name  = "postgres"
          image = "postgres:15"

          env {
            name  = "POSTGRES_DB"
            value = "notesdb"
          }

          env {
            name  = "POSTGRES_USER"
            value = "notesuser"
          }

          env {
            name = "POSTGRES_PASSWORD"

            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgres_secret.metadata[0].name
                key  = "POSTGRES_PASSWORD"
              }
            }
          }

          port {
            container_port = 5432
          }

          volume_mount {
            name       = "postgres-data"
            mount_path = "/var/lib/postgresql/data"
          }
        }

        volume {
          name = "postgres-data"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.postgres_pvc.metadata[0].name
          }
        }
      }
    }
  }
}

# Service Postgres
resource "kubernetes_service" "postgres" {
  metadata {
    name      = "notes-db"
    namespace = kubernetes_namespace.notes.metadata[0].name
  }

  spec {
    selector = {
      app = "notes-db"
    }

    port {
      port        = 5432
      target_port = "5432"
      protocol    = "TCP"
    }
  }
}

# Deployment API
resource "kubernetes_deployment" "api" {
  metadata {
    name      = "notes-api"
    namespace = kubernetes_namespace.notes.metadata[0].name
    labels = {
      app = "notes-api"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "notes-api"
      }
    }

    template {
      metadata {
        labels = {
          app = "notes-api"
        }
      }

      spec {
        container {
          name  = "notes-api"
          image = "notes-api:latest"

          env {
            name  = "DB_HOST"
            value = kubernetes_service.postgres.metadata[0].name
          }

          env {
            name  = "DB_PORT"
            value = "5432"
          }

          env {
            name  = "DB_NAME"
            value = "notesdb"
          }

          env {
            name  = "DB_USER"
            value = "notesuser"
          }

          env {
            name = "DB_PASSWORD"

            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgres_secret.metadata[0].name
                key  = "POSTGRES_PASSWORD"
              }
            }
          }

          port {
            container_port = 5000
          }
        }
      }
    }
  }
}

# Service API
resource "kubernetes_service" "api" {
  metadata {
    name      = "notes-api"
    namespace = kubernetes_namespace.notes.metadata[0].name
  }

  spec {
    selector = {
      app = "notes-api"
    }

    port {
      port        = 5000
      target_port = "5000"
      protocol    = "TCP"
    }
  }
}

# Deployment frontend
resource "kubernetes_deployment" "frontend" {
  metadata {
    name      = "notes-frontend"
    namespace = kubernetes_namespace.notes.metadata[0].name
    labels = {
      app = "notes-frontend"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "notes-frontend"
      }
    }

    template {
      metadata {
        labels = {
          app = "notes-frontend"
        }
      }

      spec {
        container {
          name  = "notes-frontend"
          image = "notes-frontend:latest"

          port {
            container_port = 80
          }
        }
      }
    }
  }
}

# Service frontend
resource "kubernetes_service" "frontend" {
  metadata {
    name      = "notes-frontend"
    namespace = kubernetes_namespace.notes.metadata[0].name
  }

  spec {
    selector = {
      app = "notes-frontend"
    }

    port {
      port        = 80
      target_port = "80"
      protocol    = "TCP"
    }
  }
}

# Ingress
resource "kubernetes_ingress_v1" "notes_ingress" {
  metadata {
    name      = "notes-ingress"
    namespace = kubernetes_namespace.notes.metadata[0].name
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      host = var.ingress_host

      http {
        # Frontend
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service.frontend.metadata[0].name

              port {
                number = 80
              }
            }
          }
        }

        # API
        path {
          path      = "/api"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service.api.metadata[0].name

              port {
                number = 5000
              }
            }
          }
        }
      }
    }
  }
}
