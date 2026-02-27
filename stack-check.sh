#!/bin/bash

# --- CONFIGURATION ---
# The script will try to pull these from your environment if they exist, 
# otherwise please edit them here for the manual check.
ES_PASS="${ELASTIC_PASSWORD:-YOUR_PASSWORD_HERE}"
ES_URL="http://localhost:9200"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}--- Starting Monitoring Stack Diagnostic ---${NC}"

# 1. Check if Containers are Running
echo -n "1. Checking Docker containers... "
if docker ps | grep -q "elasticsearch" && docker ps | grep -q "grafana"; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL: Elasticsearch or Grafana is not running.${NC}"
fi

# 2. Check Elasticsearch Connectivity (Port 9200)
echo -n "2. Checking Elasticsearch port 9200... "
if curl -s --connect-timeout 2 $ES_URL > /dev/null; then
    echo -e "${GREEN}CONNECTED${NC}"
else
    echo -e "${RED}FAILED: Cannot reach $ES_URL. Is port 9200 mapped in your compose?${NC}"
fi

# 3. Check Elasticsearch Auth & Cluster Health
echo -n "3. Verifying Credentials & Cluster Health... "
HEALTH=$(curl -u "elastic:$ES_PASS" -s "$ES_URL/_cluster/health")
if [[ $HEALTH == *"status"*"green"* ]] || [[ $HEALTH == *"status"*"yellow"* ]]; then
    echo -e "${GREEN}AUTH OK (Health: $(echo $HEALTH | jq -r .status))${NC}"
else
    echo -e "${RED}AUTH FAILED or Cluster Unhealthy.${NC}"
    echo "   Tip: Check if ELASTIC_PASSWORD is correct."
fi

# 4. Check for Log Indices (Is data actually arriving?)
echo -n "4. Checking for Coolify Log Indices... "
INDICES=$(curl -u "elastic:$ES_PASS" -s "$ES_URL/_cat/indices?h=index")
if echo "$INDICES" | grep -q "coolify-logs"; then
    COUNT=$(curl -u "elastic:$ES_PASS" -s "$ES_URL/coolify-logs-*/_count" | jq -r .count)
    echo -e "${GREEN}FOUND ($COUNT logs detected)${NC}"
else
    echo -e "${YELLOW}NOT FOUND: No logs have arrived yet.${NC}"
    echo "   Tip: Go to Coolify Server > Log Drains and point to http://localhost:9200"
fi

# 5. Check Dashboard Files
echo -n "5. Checking Dashboard provisioning files... "
DASH_DIR="/var/lib/docker/volumes/grafana-dashboards/_data"
if [ -d "$DASH_DIR" ] && [ "$(ls -A $DASH_DIR)" ]; then
    echo -e "${GREEN}FILES PRESENT ($(ls $DASH_DIR | wc -l) dashboards found)${NC}"
else
    echo -e "${RED}EMPTY: Dashboard loader failed or volume path differs.${NC}"
fi

echo -e "${YELLOW}--- Diagnostic Complete ---${NC}"
