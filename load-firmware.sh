last_run=$(gh run list --json databaseId -q '.[0].databaseId')
echo "Loading firmware from job run id: $last_run"

status=$(gh run view "$last_run" --json status -q '.status')

if [ "$status" != "completed" ]; then
  echo 'The job still not completed. Stopping script.'
  exit 0
fi

conclusion=$(gh run view "$last_run" --json conclusion -q '.conclusion')

if [ "$conclusion" != "success" ]; then
  echo 'The job is unsuccecful. Please visit page for more detail.'
  exit 1
fi

if [ -d ./firmware ]; then
  rm -r ./firmware
fi

gh run download "$last_run"
