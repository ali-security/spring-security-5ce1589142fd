#!/bin/sh
# Seal build: Travis archives job logs asynchronously, so a log fetched right after the job
# ends can be truncated. Keep the job open (after_script, cannot change the build result)
# until this job's public log.txt holds Gradle's final status line, printing a heartbeat on
# every poll so Travis's 10-minute no-output watchdog never fires. Capped at 8 minutes;
# always exits 0.
URL="https://api.travis-ci.com/v3/job/${TRAVIS_JOB_ID}/log.txt"
MAX=480
STEP=20
waited=0
while [ "$waited" -lt "$MAX" ]; do
  if curl -fsSL --max-time 15 "$URL" 2>/dev/null | grep -Eq "BUILD (SUCCESSFUL|FAILED) in [0-9]"; then
    echo "wait-for-log: archived log complete after ${waited}s"
    exit 0
  fi
  echo "wait-for-log: waiting for log archive... (${waited}s of ${MAX}s)"
  sleep "$STEP"
  waited=$((waited + STEP))
done
echo "wait-for-log: gave up after ${MAX}s"
exit 0
