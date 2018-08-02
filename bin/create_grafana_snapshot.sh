#!/bin/bash
#
# Uploads a Grafana snapshot from template
#

set -euo pipefail

while getopts "h:u:p:f:n:" option
do
  case $option in
    h) HOST=$OPTARG;;
    u) USER=$OPTARG;;
    p) PASS=$OPTARG;;
    f) TEMPLATE=$OPTARG;;
    n) SNAPSHOT_NAME=$OPTARG;;
  esac
done

: $HOST $USER $PASS $TEMPLATE $SNAPSHOT_NAME

CURL="curl -f --show-error -s"

snapshot_json() {
    jq ".name=\"$SNAPSHOT_NAME\"" <$1
}


# create API key
apikey_name=tmp$$
apikey=$($CURL -X POST -H "Content-Type: application/json" -d '{"name": "'${apikey_name}'", "role": "Admin"}' \
    https://${USER}:${PASS}@${HOST}/api/auth/keys | jq -r '.key')

cleanup() {
    # don't blow up when cleaning
    set +e

    # get existing API key
    apikey_id=$($CURL -X GET \
        https://${HOST}/api/auth/keys \
        -H "Authorization: Bearer ${apikey}" \
        -H 'Cache-Control: no-cache' | jq '.[] | select(.name=="'${apikey_name}'") | .id ')

    # delete API key
    $CURL -X DELETE \
        https://${HOST}/api/auth/keys/${apikey_id} \
        -H "Authorization: Bearer ${apikey}" \
        -H 'Cache-Control: no-cache' -o /dev/null
}

trap cleanup EXIT

# delete snapshot if it exists already
deletekey=$($CURL -X GET "https://${HOST}/api/dashboard/snapshots?query=${SNAPSHOT_NAME}" \
   -H "Authorization: Bearer ${apikey}" | jq -r '.[] | select(.name=="'${SNAPSHOT_NAME}'") | .deleteKey')

if [ -n "$deletekey" ]; then
    echo "Deleting existing snapshot"
    $CURL -X GET "https://${HOST}/api/snapshots-delete/${deletekey}"\
     -H "Authorization: Bearer ${apikey}"
    echo
fi

# upload snapshot
$CURL -X POST https://${HOST}/api/snapshots \
-H "Content-Type: application/json" \
-H "Authorization: Bearer ${apikey}" \
-d "$(snapshot_json $TEMPLATE)"

echo