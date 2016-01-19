CLIENTID="wAtdi9rbYoMRccsV81eY2mTsI1w9gNde"
echo "This script will generate an OAuth2 Token that can be used for uploading DSYMS to Crittercism for crash processing"
echo "PLEASE NOTE: This token will be valid for 1 year"
echo "To generate the token, you will need to enter your Application ID and cittercism login credentials below."
printf "Enter Crittercism App ID: " && read APP_ID && printf "Enter Email address used to log into Crittercism: " && read UN && printf "Enter Crittercism password: " && read -s PW

ENCODED_UN=$(echo "${UN}" | sed -e 's/%/%25/g' -e 's/ /%20/g' -e 's/!/%21/g' -e 's/"/%22/g' -e 's/#/%23/g' -e 's/\$/%24/g' -e 's/\&/%26/g' -e 's/'\''/%27/g' -e 's/(/%28/g' -e 's/)/%29/g' -e 's/\*/%2a/g' -e 's/+/%2b/g' -e 's/,/%2c/g' -e 's/-/%2d/g' -e 's/\./%2e/g' -e 's/\//%2f/g' -e 's/:/%3a/g' -e 's/;/%3b/g' -e 's//%3e/g' -e 's/?/%3f/g' -e 's/@/%40/g' -e 's/\[/%5b/g' -e 's/\\/%5c/g' -e 's/\]/%5d/g' -e 's/\^/%5e/g' -e 's/_/%5f/g' -e 's/`/%60/g' -e 's/{/%7b/g' -e 's/|/%7c/g' -e 's/}/%7d/g' -e 's/~/%7e/g')
ENCODED_PASSWORD=$(echo "${PW}" | sed -e 's/%/%25/g' -e 's/ /%20/g' -e 's/!/%21/g' -e 's/"/%22/g' -e 's/#/%23/g' -e 's/\$/%24/g' -e 's/\&/%26/g' -e 's/'\''/%27/g' -e 's/(/%28/g' -e 's/)/%29/g' -e 's/\*/%2a/g' -e 's/+/%2b/g' -e 's/,/%2c/g' -e 's/-/%2d/g' -e 's/\./%2e/g' -e 's/\//%2f/g' -e 's/:/%3a/g' -e 's/;/%3b/g' -e 's//%3e/g' -e 's/?/%3f/g' -e 's/@/%40/g' -e 's/\[/%5b/g' -e 's/\\/%5c/g' -e 's/\]/%5d/g' -e 's/\^/%5e/g' -e 's/_/%5f/g' -e 's/`/%60/g' -e 's/{/%7b/g' -e 's/|/%7c/g' -e 's/}/%7d/g' -e 's/~/%7e/g')

APP_ID_LENGTH=${#APP_ID}
if [ $APP_ID_LENGTH -eq 24 ]; then
  TOKEN_DOMAIN="developers.crittercism.com"
elif [ $APP_ID_LENGTH -eq 40 ]; then
  APP_ID_LOCATION=${APP_ID:32}
  US_WEST_1_PROD_DESIGNATOR="00555300"
  EU_CENTRAL_1_PROD_DESIGNATOR="00444503"
  if [ "${APP_ID_LOCATION}" == "${US_WEST_1_PROD_DESIGNATOR}" ]; then
    TOKEN_DOMAIN="developers.crittercism.com"
  elif [ "${APP_ID_LOCATION}" == "${EU_CENTRAL_1_PROD_DESIGNATOR}" ]; then
    TOKEN_DOMAIN="developers.eu.crittercism.com"
  else
    echo "Unexpected APP_ID_LOCATION == ${APP_ID_LOCATION}"
  fi
else
  echo "Unexpected APP_ID_LENGTH == ${APP_ID_LENGTH}"
fi
if [ ! "${TOKEN_DOMAIN}" ]; then
	echo "Error: Invalid Crittercism App ID: ${APP_ID}"
  	exit 1
fi

GRANT="grant_type=password&username=${ENCODED_UN}&password=${ENCODED_PASSWORD}&scope=app/${APP_ID}/symbols&duration=31536000"

TOKEN_URL="https://${TOKEN_DOMAIN}/v1.0/token" 
RESPONSE=$(curl --silent -X POST "${TOKEN_URL}" -u "${CLIENTID}":  -d "${GRANT}")

TOKEN=$(echo $RESPONSE | sed  's/^.*"access_token": "\([^"]*\)".*$/\1/')

if [ ${#TOKEN} -eq 0 ]; then
	echo
	echo "======================================================="
	echo ${RESPONSE}
else
	echo
	echo "======================================================="
	echo
	echo "Your OAuth2 token is:"
	echo ""
	echo "${TOKEN}"
	echo ""
	echo "You now have access to upload DSYM files to Crittercism"
fi	



