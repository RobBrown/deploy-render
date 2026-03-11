#!/bin/zsh

set -euo pipefail

API_KEY="${RENDER_API_KEY:-}"
SERVICE_ID="${RENDER_SERVICE_ID:-}"
POLL_SECONDS="${RENDER_POLL_SECONDS:-5}"

SUCCESS_SOUND="/System/Library/Sounds/Funk.aiff"
FAIL_SOUND="/System/Library/Sounds/Basso.aiff"

GREEN=$'\033[32m'
RESET=$'\033[0m'

if [[ -z "$API_KEY" || -z "$SERVICE_ID" ]]; then
  printf "%bMissing RENDER_API_KEY or RENDER_SERVICE_ID%b\n" "$GREEN" "$RESET"
  exit 1
fi

play_success() {
  afplay "$SUCCESS_SOUND" &
}

play_failure() {
  afplay "$FAIL_SOUND" &
}

printf "%bTriggering deploy for service: %s%b\n" "$GREEN" "$SERVICE_ID" "$RESET"

TRIGGER_RESPONSE=$(
  curl -sS --fail \
    --request POST \
    --url "https://api.render.com/v1/services/${SERVICE_ID}/deploys" \
    --header "accept: application/json" \
    --header "authorization: Bearer ${API_KEY}"
)

DEPLOY_ID=$(
  printf '%s' "$TRIGGER_RESPONSE" | jq -r '.id // empty'
)

if [[ -z "$DEPLOY_ID" ]]; then
  printf "%bCould not parse deploy ID from Render response:%b\n" "$GREEN" "$RESET"
  printf "%b%s%b\n" "$GREEN" "$TRIGGER_RESPONSE" "$RESET"
  play_failure
  exit 1
fi

spinner='|/-\'
i=0
last_status="starting"

printf "%bDeploying %s  status: %-20s%b" "$GREEN" "${spinner:0:1}" "$last_status" "$RESET"

while true; do
  DEPLOY_RESPONSE=$(
    curl -sS --fail \
      --request GET \
      --url "https://api.render.com/v1/services/${SERVICE_ID}/deploys/${DEPLOY_ID}" \
      --header "accept: application/json" \
      --header "authorization: Bearer ${API_KEY}"
  )

  STATUS=$(
    printf '%s' "$DEPLOY_RESPONSE" | jq -r '.status // "unknown"'
  )

  if [[ "$STATUS" != "$last_status" ]]; then
    last_status="$STATUS"
  fi

  printf "\r%bDeploying %s  status: %-20s%b" "$GREEN" "${spinner:$((i % 4)):1}" "$last_status" "$RESET"
  i=$((i + 1))

  case "$STATUS" in
    live|succeeded)
      printf "\r%bDeploy completed successfully.                    %b\n" "$GREEN" "$RESET"
      play_success
      exit 0
      ;;
    build_failed|update_failed|failed|canceled|cancelled)
      printf "\r%bDeploy failed with status: %s                    %b\n" "$GREEN" "$STATUS" "$RESET"
      play_failure
      exit 1
      ;;
    *)
      sleep "$POLL_SECONDS"
      ;;
  esac
done
