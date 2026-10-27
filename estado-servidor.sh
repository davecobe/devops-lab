#!/bin/bash
# Reporte básico del estado del servidor

echo "===== Reporte de $(hostname) ====="
echo "Fecha:   $(date '+%Y-%m-%d %H:%M:%S')"
echo "Uptime:  $(uptime -p)"
echo ""
echo "--- CPU (carga) ---"
cat /proc/loadavg
echo ""
echo "--- Memoria ---"
free -h
echo ""
echo "--- Disco ---"
df -h /
echo ""
echo "--- IPs ---"
ip -4 -br addr
