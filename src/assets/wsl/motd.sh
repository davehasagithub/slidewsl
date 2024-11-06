if [[ $- == *i* ]]; then
  cat <<EOF | sed "s/^ *//"  | /usr/local/bin/daveml.sh -p ""
  <WBB>|             |
  <WBB>|   Welcome   |
  <WBB>|             |
EOF
fi