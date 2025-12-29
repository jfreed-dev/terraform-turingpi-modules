variable "chart_version" {
  description = "kube-prometheus-stack Helm chart version"
  type        = string
  default     = "65.8.1"
}

variable "timeout" {
  description = "Helm install timeout in seconds"
  type        = number
  default     = 600
}

variable "storage_class" {
  description = "Storage class for persistent volumes"
  type        = string
  default     = "longhorn"
}

# Grafana Configuration
variable "grafana_enabled" {
  description = "Enable Grafana deployment"
  type        = bool
  default     = true
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
  default     = "admin"
}

variable "grafana_persistence_enabled" {
  description = "Enable persistent storage for Grafana"
  type        = bool
  default     = true
}

variable "grafana_storage_size" {
  description = "Grafana persistent volume size"
  type        = string
  default     = "5Gi"
}

variable "grafana_ingress_enabled" {
  description = "Enable Ingress for Grafana"
  type        = bool
  default     = false
}

variable "grafana_ingress_host" {
  description = "Hostname for Grafana Ingress"
  type        = string
  default     = "grafana.local"
}

# Prometheus Configuration
variable "prometheus_enabled" {
  description = "Enable Prometheus deployment"
  type        = bool
  default     = true
}

variable "prometheus_retention" {
  description = "Prometheus data retention period"
  type        = string
  default     = "15d"
}

variable "prometheus_retention_size" {
  description = "Prometheus data retention size"
  type        = string
  default     = "18GB"
}

variable "prometheus_storage_size" {
  description = "Prometheus persistent volume size"
  type        = string
  default     = "20Gi"
}

variable "prometheus_memory_request" {
  description = "Prometheus memory request"
  type        = string
  default     = "512Mi"
}

variable "prometheus_cpu_request" {
  description = "Prometheus CPU request"
  type        = string
  default     = "250m"
}

variable "prometheus_memory_limit" {
  description = "Prometheus memory limit"
  type        = string
  default     = "2Gi"
}

variable "prometheus_cpu_limit" {
  description = "Prometheus CPU limit"
  type        = string
  default     = "1000m"
}

variable "prometheus_ingress_enabled" {
  description = "Enable Ingress for Prometheus"
  type        = bool
  default     = false
}

variable "prometheus_ingress_host" {
  description = "Hostname for Prometheus Ingress"
  type        = string
  default     = "prometheus.local"
}

# Alertmanager Configuration
variable "alertmanager_enabled" {
  description = "Enable Alertmanager deployment"
  type        = bool
  default     = true
}

variable "alertmanager_storage_size" {
  description = "Alertmanager persistent volume size"
  type        = string
  default     = "2Gi"
}

variable "alertmanager_ingress_enabled" {
  description = "Enable Ingress for Alertmanager"
  type        = bool
  default     = false
}

variable "alertmanager_ingress_host" {
  description = "Hostname for Alertmanager Ingress"
  type        = string
  default     = "alertmanager.local"
}

# Exporters
variable "node_exporter_enabled" {
  description = "Enable Node Exporter for host metrics"
  type        = bool
  default     = true
}

variable "kube_state_metrics_enabled" {
  description = "Enable kube-state-metrics"
  type        = bool
  default     = true
}

# Control Plane Endpoint (for Talos clusters)
variable "control_plane_endpoint" {
  description = "Control plane IP for scraping kube-controller-manager, kube-scheduler, etcd"
  type        = string
  default     = null
}

# External Monitoring Targets (Optional)
variable "external_targets" {
  description = "List of external host IPs to monitor with node_exporter (port 9100)"
  type        = list(string)
  default     = []
}

variable "docker_hosts" {
  description = "List of Docker host IPs to monitor (port 9323)"
  type        = list(string)
  default     = []
}

variable "cadvisor_hosts" {
  description = "List of hosts running cAdvisor to monitor (port 8080)"
  type        = list(string)
  default     = []
}
