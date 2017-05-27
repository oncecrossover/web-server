#!/bin/bash -e
EXAMPLE_MAP=(
  'snoop-web-client:com.snoop.server.web.HttpSnoopClient'
  'snoop-web-server:com.snoop.server.web.HttpSnoopServer'
)

NEEDS_NPN_MAP=(
  'spdy-client'
  'spdy-server'
)

EXAMPLE=''
EXAMPLE_CLASS=''
EXAMPLE_ARGS='-D_'
FORCE_NPN=''
I=0

while [[ $# -gt 0 ]]; do
  ARG="$1"
  shift
  if [[ "$ARG" =~ (^-.+) ]]; then
    EXAMPLE_ARGS="$EXAMPLE_ARGS $ARG"
  else
    EXAMPLE="$ARG"
    for E in "${EXAMPLE_MAP[@]}"; do
      KEY="${E%%:*}"
      VAL="${E##*:}"
      if [[ "$EXAMPLE" == "$KEY" ]]; then
        EXAMPLE_CLASS="$VAL"
        break
      fi
    done
    break
  fi
done

if [[ -z "$EXAMPLE" ]] || [[ -z "$EXAMPLE_CLASS" ]] || [[ $# -ne 0 ]]; then
  echo "  Usage: $0 [-D<name>[=<value>] ...] <component-name>" >&2
  echo "" >&2
  echo "Defaults: http.snoop.ssl={true if present | false if absent}" >&2
  echo "          http.snoop.server.live={true if present | false if absent}" >&2
  echo "          http.snoop.server.port= [8080 for http | 8443 for https]" >&2
  echo "          http.method=GET | [POST | PUT | DELETE]" >&2
  echo "          snoop.server.id.worker.id=0" >&2
  echo "          snoop.server.id.datacenter.id=0" >&2
  echo
  echo "" >&2
  echo "Example: $0  snoop-web-server" >&2
  echo "         $0 -Dhttp.snoop.server.port=8080 snoop-web-server" >&2
  echo "         $0 -Dhttp.snoop.server.port=8443 -Dhttp.snoop.ssl snoop-web-server" >&2
  echo "         $0 -Dhttp.snoop.server.port=8443 -Dhttp.snoop.ssl -Dhttp.snoop.server.live snoop-web-server" >&2
  echo "         $0 -Dhttp.snoop.server.port=8443 -Dhttp.snoop.ssl -Dhttp.snoop.client.uri=users/123 snoop-web-client" >&2
  echo >&2
  echo "Available components:" >&2
  I=0
  for E in "${EXAMPLE_MAP[@]}"; do
    if [[ $I -eq 0 ]]; then
      echo -n '  '
    fi

    printf '%-24s' "${E%%:*}"
    ((I++)) || true

    if [[ $I -eq 2 ]]; then
      I=0
      echo
    fi
  done >&2
  if [[ $I -ne 0 ]]; then
    echo >&2
  fi
  echo >&2
  exit 1
fi

for E in "${NEEDS_NPN_MAP[@]}"; do
  if [[ "$EXAMPLE" = "$E" ]]; then
    FORCE_NPN='true'
    break
  fi
done

cd "`dirname "$0"`"/server
EXAMPLE_ARGS="$EXAMPLE_ARGS -Dsnoop.root.logger=INFO,RFA -Dsnoop.log.dir=./logs -Dsnoop.log.file=snoop-${USER}-server-${HOSTNAME}.log"
echo "[INFO] Running: $EXAMPLE ($EXAMPLE_CLASS $EXAMPLE_ARGS)"
exec mvn -q -nsu compile exec:exec -Dcheckstyle.skip=true -Dforcenpn="$FORCE_NPN" -DargLine.example="$EXAMPLE_ARGS" -DexampleClass="$EXAMPLE_CLASS"