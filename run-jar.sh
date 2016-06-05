#!/bin/bash -e
EXAMPLE_MAP=(
  'peeq-snoop-server:com.gibbon.peeq.snoop.HttpSnoopServer'
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
  echo "  Usage: $0 [-D<name>[=<value>] ...] <server-name>" >&2
  echo "Example: $0 -Dport=8443 -Dssl peeq-snoop-server" >&2
  echo "         $0 -Dhost=127.0.0.1 -Dport=8009 peeq-snoop-server" >&2
  echo "         $0 -DlogLevel=debug -Dhost=127.0.0.1 -Dport=8009 peeq-snoop-server" >&2
  echo >&2
  echo "Available servers:" >&2
  echo >&2
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
echo "[INFO] Running: $EXAMPLE ($EXAMPLE_CLASS $EXAMPLE_ARGS)"
exec mvn -q -nsu compile exec:exec -Dcheckstyle.skip=true -Dforcenpn="$FORCE_NPN" -DargLine.example="$EXAMPLE_ARGS" -DexampleClass="$EXAMPLE_CLASS"