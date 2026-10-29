set -u
ls cc 2>/dev/null | grep -q . || exit 0
[ "$HOP" -lt "$MAXHOP" ] || exit 0
NH=$((HOP+1))
curl -s -X POST -H "Authorization: Bearer $GH" -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/$REPO/actions/workflows/run.yml/dispatches" \
  -d "{\"ref\":\"$REF\",\"inputs\":{\"job\":\"$JOB\",\"shards\":\"$N\",\"hop\":\"$NH\",\"maxhop\":\"$MAXHOP\",\"budget\":\"$BUDGET\"}}"
