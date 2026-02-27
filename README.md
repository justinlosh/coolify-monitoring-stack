## 📊 Monitoring Stack with Coolify, Grafana & Elasticsearch

This project provides a fully automated, containerized monitoring solution designed specifically for **Coolify**. It features log aggregation via **Elasticsearch**, metric collection via **Prometheus**, and a pre-configured **Grafana** dashboard suite.

## 🚀 Features

* **Log Management**: Centralized logs for all your containers.
* **Metric Visualization**: Real-time system and container metrics.
* **Auto-Provisioning**: Dashboards for Elasticsearch, Prometheus, and Node Exporter are automatically downloaded and configured on first boot.
* **Coolify Native**: Integrated health checks and automatic Traefik routing.

### ⚠️ Important Note

> **Use at your own risk.**
> 
> This configuration is provided "as-is" without warranty of any kind. By deploying this stack, you acknowledge that I am not responsible for lost data, security breaches, server meltdowns, or any other digital catastrophes that may occur.
> **A few friendly reminders:**
> * **Passwords:** If you lose your `ELASTIC_PASSWORD`, don't come knocking—you’ll have to wipe the volumes and start over.
> * **Resources:** Elasticsearch is a memory-hungry beast. If your VPS starts sweating, give it more RAM or adjust the `ES_HEAP_SIZE`.
> * **Security:** This stack is configured for ease of use. If you expose Elasticsearch's port `9200` to the public internet without extra hardening, you're essentially leaving your front door open in a bad neighborhood.

---

## 🛠️ Setup Instructions

### 1. Environment Variables

Before deploying, add the following variables to your Coolify Service Stack:

| Variable | Description |
| --- | --- |
| `ELASTIC_PASSWORD` | The master password for Elasticsearch. |
| `GRAFANA_ADMIN_USER` | Admin username (default: `admin`). |
| `GRAFANA_ADMIN_PASSWORD` | Admin password for Grafana UI. |
| `SERVICE_FQDN_GRAFANA` | Your full URL (e.g., `https://stats.example.com`). |
| `ES_HEAP_SIZE` | Memory for Elasticsearch (e.g., `2g`). |

### 2. Deployment

1. Paste the `docker-compose.yaml` into your Coolify stack.
2. Ensure you have **deleted any old volumes** (`elasticsearch-data`, `grafana-data`) if you are resetting passwords.
3. Click **Deploy**.

---

## 📁 Included Dashboards

The stack includes a `dashboard-loader` sidecar that automatically provisions:

* **Node Exporter Full**: Detailed OS metrics (CPU, Memory, Disk, Network).
* **Elasticsearch Stats**: Cluster health, shard status, and indexing rates.
* **Prometheus 2.0**: Scraper health and performance metrics.

---

## 🔍 Troubleshooting

### "No date field named @timestamp found"

This error appears in Grafana when Elasticsearch is empty.

* **Fix**: This will disappear automatically once your containers begin sending logs to Elasticsearch. Ensure your other applications are configured to log to this stack.

### "401 Unauthorized" (Elasticsearch)

This happens if the `ELASTIC_PASSWORD` was changed after the first deployment.

* **Fix**: Elasticsearch only sets the password on the *first* boot. To update it, you must go to the **Storage** tab in Coolify, delete the `elasticsearch-data` volume, and redeploy.

### Dashboards Missing

The `dashboard-loader` container runs once to download JSON files.

* **Fix**: Check the logs of the `dashboard-loader` container. If it failed to download, ensure your server has outbound internet access to `grafana.com`.

---

## 🛡️ Security Note

Elasticsearch is configured with `xpack.security.enabled=true` but `http.ssl.enabled=false`. It is intended to run inside a private Docker network. **Do not expose Port 9200 to the public internet** without setting up SSL/TLS.
