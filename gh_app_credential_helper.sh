#!/bin/bash

if [ "$DEBUG_COMMANDS" = "true" ]; then
    set -ex
fi

# DEBUG_MODE_ENABLED provides a way to enable the debug mode
# export DEBUG_MODE=true
DEBUG_MODE_ENABLED="${DEBUG_MODE:-false}"

APP_SIGN_KEY="$1"
APP_ID="$2"
APP_INSTALLATION_ID="$3"

TOKEN_IAT="$( date +%s )"
TOKEN_EXP="$((TOKEN_IAT + 570))"

RAW_TOKEN_HEADER='{"alg":"RS256"}'
TOKEN_HEADER=$( echo -n "${RAW_TOKEN_HEADER}" | openssl base64 | tr -d '=' | tr '/+' '_-' | tr -d '\n' )

RAW_TOKEN_PAYLOAD="{\"iat\":${TOKEN_IAT},\"exp\":${TOKEN_EXP},\"iss\":\"${APP_ID}\"}"
TOKEN_PAYLOAD=$( echo -n "${RAW_TOKEN_PAYLOAD}" | openssl base64 | tr -d '=' | tr '/+' '_-' | tr -d '\n' )

TOKEN_BODY="${TOKEN_HEADER}.${TOKEN_PAYLOAD}"
TOKEN_SIGNATURE=$( openssl dgst -sha256 -sign <(echo -n "${APP_SIGN_KEY}") <(echo -n "${TOKEN_BODY}") | openssl base64 | tr -d '=' | tr '/+' '_-' | tr -d '\n' )

GH_APP_TOKEN="${TOKEN_BODY}.${TOKEN_SIGNATURE}"

GH_APP_INSTALLATION_TOKEN=$(curl -XPOST -H "Authorization: Bearer $GH_APP_TOKEN" -H "Accept: application/vnd.github.v3+json" "https://api.github.com/app/installations/$APP_INSTALLATION_ID/access_tokens" | jq -r .token)

echo "$GH_APP_INSTALLATION_TOKEN"
