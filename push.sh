#!/bin/bash
echo "=== Git Push Script ==="
git log --oneline -1
echo ""
git push origin main
echo "DONE"
