#!/bin/bash
# Respaldo de configuración MikroTik con historial en Git

ROUTER="10.1.150.31"
USUARIO="backup"
DESTINO="$HOME/respaldos-mk"
ARCHIVO="$DESTINO/$ROUTER.rsc"

# Sacar el export (sed '1d' quita la línea con fecha/hora,
# así Git solo detecta cambios reales de configuración)
ssh -o ConnectTimeout=10 "$USUARIO@$ROUTER" "/export show-sensitive" | tr -d '\r' | sed '1d' > "$ARCHIVO"

if [ ! -s "$ARCHIVO" ]; then
    echo "ERROR: no se pudo respaldar $ROUTER"
    exit 1
fi

cd "$DESTINO"
git add "$ROUTER.rsc"

if git diff --cached --quiet; then
    echo "$(date '+%F %T') - $ROUTER sin cambios"
else
    git commit -q -m "Respaldo $ROUTER $(date '+%F %T')"
    echo "$(date '+%F %T') - $ROUTER cambios guardados"
fi
