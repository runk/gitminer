#!/bin/bash


git status 2&> /dev/null

if [ "$?" != "0" ]; then
  # echo "repo found"
# else
  echo "Git repository not found in current directory" 1>&2
  exit 1
fi


VERSION=2
TFILE="./.gitminer.tmp"
ENDPOINT="https://gitminer.com/parser/do?version=$VERSION"

upload() {
  if hash curl 2>/dev/null; then
    cat "$TFILE" | curl -s -X PUT \
      -H 'Content-type: application/octet-stream' \
      -H "Content-Encoding: gzip" \
      --data-binary @- \
      --compressed "$ENDPOINT"
  else
    wget --header="Content-Encoding: gzip" \
      --header="Content-Type: application/octet-stream" \
      --method=PUT \
      -qO- \
      --body-file="$TFILE" "$ENDPOINT"
  fi
}


# 1. retrieve git log
# 2. compress it
# 3. pipe to remote server for analysis
# 4. remove tmp file
git log \
  --format="%n%n%an <%ae>%n%n%ci" \
  --numstat \
  --since=2014-01-01 \
  --no-merges \
  --date-order | \
  gzip > "$TFILE"

upload

rm "$TFILE"
