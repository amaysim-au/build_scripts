#!/bin/bash -e

ISOK=`curl -i -s ${HEALTHCHECKURL} --max-time 5 | head -1 | grep "200 OK" | wc -l`

COUNT=0
while [ $ISOK -eq 0 ]; do
  echo "Waiting on Poseidon application ..."

  COUNT=$[$COUNT + 1]
  if [ $COUNT -gt 90 ]; then
    echo "Error: Poseidon application healthcheck timeout: ${HEALTHCHECKURL}"
    exit 1;
  fi

  ISOK=`curl -i -s ${HEALTHCHECKURL} --max-time 5 | head -1 | grep "200 OK" | wc -l`
  sleep 10
done

echo "Poseidon application started"