#!/bin/bash
# Managed by Ansible - DO NOT EDIT

ACTION=$1
SERVICES_DIR=/srv/services

if [ -z "$ACTION" ]; then
  echo "Usage: ./stack.sh [action] [additional-flags...]"
  exit 1
fi

shift

for service in "$SERVICES_DIR"/*/; do
  COMPOSE_FILE="${service}docker-compose.yaml"

  if [ -f "$COMPOSE_FILE" ]; then
    echo "--- Executing: docker compose $ACTION $@ on $(basename "$service") ---"
    docker compose -f "$COMPOSE_FILE" "$ACTION" "$@"
  fi
done