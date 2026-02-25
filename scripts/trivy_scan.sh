#!/bin/bash
# -----------------------------------------------------------------
# TRIVY VULNERABILITY SCANNER (HTML REPORT)
# Managed by Ansible - DO NOT EDIT
# -----------------------------------------------------------------

REPORT_FILE="/srv/docs/vulnerabilities.html"
LOG_FILE="/var/log/trivy-scan.log"
TEMP_FILE="/tmp/trivy_temp.html"

log() {
    echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ") [$1] $2" | tee -a "$LOG_FILE"
}

# The raw tag prevents Ansible from evaluating the Docker format string
IMAGES=$(docker ps --format '{{.Image}}' | sort -u)

FIRST_RUN=true
for IMAGE in $IMAGES; do
    log "INFO" "Scanning: $IMAGE..."
    if [ "$FIRST_RUN" = true ]; then
        docker run --rm \
            -v /var/run/docker.sock:/var/run/docker.sock:ro \
            aquasec/trivy:latest \
            --quiet \
            image \
            --format template \
            --template "@/contrib/html.tpl" \
            --severity HIGH,CRITICAL \
            --ignore-unfixed \
            "$IMAGE" > "$REPORT_FILE"
        sed -i '/<\/body>/d; /<\/html>/d' "$REPORT_FILE"
        FIRST_RUN=false
    else
        docker run --rm \
            -v /var/run/docker.sock:/var/run/docker.sock:ro \
            aquasec/trivy:latest \
            --quiet \
            image \
            --format template \
            --template "@/contrib/html.tpl" \
            --severity HIGH,CRITICAL \
            --ignore-unfixed \
            "$IMAGE" > "$TEMP_FILE"
        sed -n '/<body>/,/<\/body>/p' "$TEMP_FILE" | sed -e 's/<body>//' -e 's/<\/body>//' >> "$REPORT_FILE"
    fi
done

echo "</body></html>" >> "$REPORT_FILE"
rm -f "$TEMP_FILE"

log "INFO" "Scan completed! Report saved to $REPORT_FILE"