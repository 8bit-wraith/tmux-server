#!/bin/bash
while IFS= read -r line; do
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $line" >> "$HISTFILE"
done
