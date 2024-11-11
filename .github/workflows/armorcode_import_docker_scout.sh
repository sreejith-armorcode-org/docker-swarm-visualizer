#!/bin/bash
set -e

token=$1
filePath=$2
productName='Docker Swarm'
subProductName='Visualizer'
environmentName="Production"
toolName="Docker Scout"
urlUpload='https://app.armorcode.com/client/utils/scan/upload'
scanIdentifier=''
# Enter comma separated tags
tags=''

if [ $# -ne 2 ]
then
  echo "invalid arguments, please specify token and filePath"
  echo "usage - ./<script> <token> <filePath>"
  exit -1
fi

echo "token: <redacted>"
echo "toolName: $toolName"
echo "productName: $productName"
echo "subProductName: $subProductName"
echo "environment: $environmentName"
echo "filePath: $filePath"
echo "urlUpload: $urlUpload"
echo "scanIdentifier: $scanIdentifier"
echo "tags: $tags"

echo "create scan entry in ArmorCode"
result=$(curl "$urlUpload" -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $token" --data-raw "{\"product\":\"$productName\",\"subProduct\":\"$subProductName\",\"env\":\"$environmentName\",\"scanTool\":\"$toolName\",\"fileName\":\"$filePath\",\"scanIdentifier\":\"$scanIdentifier\",\"tags\":\"$tags\"}")
echo "API response for Upload - $result"

errorMessage=$(echo $result | jq --raw-output '.message')
if [ -z "$errorMessage" ]
  then
    echo "Error Message - $errorMessage"
    exit 2
fi

signedUrl=$(echo $result | jq --raw-output '.signedUrl')
echo "signedUrl: $signedUrl"
echo "upload scanfile"
curl --upload-file "$filePath" -X PUT -L $signedUrl
echo "Scan upload to ArmorCode complete"