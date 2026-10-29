#!/bin/bash
# Respaldo de varios MikroTik desde un inventario, con historial en Git

set -o pipefail

LISTA="$HOME/devops-lab/routers.txt"
USUARIO="backup"
DESTINO="$HOME/respaldos-mk"
OK=0
FALLAS=0

cd "$DESTINO" || exit 1

while IFS=, read -r NOMBRE IP VERSION; do
    # Saltar líneas vacías y comentarios
    [[ -z "$NOMBRE" || "$NOMBRE" == \#* ]] && continue
        if [ "$VERSION" = "6" ]; then
        CMD="/export"
    else
        CMD="/export show-sensitive"
    fi
    ARCHIVO="$NOMBRE.rsc"

    if ssh -n -o ConnectTimeout=10 -o BatchMode=yes "$USUARIO@$IP" "$CMD" \
        | tr -d '\r' | sed '1d' > "$ARCHIVO.tmp" && [ -s "$ARCHIVO.tmp" ]; then
        mv "$ARCHIVO.tmp" "$ARCHIVO"
        git add "$ARCHIVO"
        echo "$(date '+%F %T') - OK    $NOMBRE ($IP)"
        OK=$((OK + 1))
    else
        rm -f "$ARCHIVO.tmp"
        echo "$(date '+%F %T') - FALLA $NOMBRE ($IP)"
        FALLAS=$((FALLAS + 1))
    fi
done < "$LISTA"

if git diff --cached --quiet; then
    echo "$(date '+%F %T') - Sin cambios de configuración"
else
    echo "$(date '+%F %T') - Cambios en:"
    git diff --cached --name-only | sed 's/^/    /'
    git commit -q -m "Respaldo $(date '+%F %T')"
fi

echo "$(date '+%F %T') - Resumen: $OK OK, $FALLAS fallas"
[ "$FALLAS" -eq 0 ]
