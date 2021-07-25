#!/usr/bin/env bash

# Copyright 2021 Mark Jenkins
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

CARDSERVER="https://immunizationcard.manitoba.ca"
VERIFICATION_URL="$CARDSERVER/api/verification"

# QR-Code: is the prefix we're expecting in the output of zbarcam
CARD_PREFIX_W_QR_PREFIX="QR-Code:https://immunizationcard.manitoba.ca/?ID="

# set this to have zbarcam use a different /dev/video* device than the default
# e.g. VIDEODEVICE="/dev/video1"
VIDEODEVICE=""

if ! test -f bearertoken.txt; then \
    echo "bearertoken.txt file does not exist" 1>&2
    exit 1
fi
bearertoken=$(<bearertoken.txt)

function processuuid {
    # ask the government if a UUID ($1 first argument) is a valid
    # immunization card
    responsejson=$(wget -q -O - \
			--header "authorization: Bearer $bearertoken" \
			"$VERIFICATION_URL/$1" 2>/dev/null)

    # check if we got a response with the JSON payload containing a
    # isValid field, if that's not there something is very wrong, so exit
    if ! grep 'isValid'<<<"$responsejson">/dev/null; then \
	echo "immunization server response was not what we expected; exiting" \
	     1>&2
	echo "possibly the bearer token is expired" 1>&2
	exit 1
    fi

    # if the response contains "isValid": true, with whatever use of whitespace
    if grep '"isValid"[[:space:]]*:[[:space:]]*true'<<<$responsejson >/dev/null; then \
	# exact firstName and lastName fields expected in a valid response
	# (we should probably check they're there)
	#
	# this isn't even close to a proper JSON parser
	# for example, considering the firstName to end with double quote '"'
	# doesn't account for the fact that json has escape sequences for
	# such things!
	firstName=$(sed -e 's@^.*"firstName"[[:space:]]*:[[:space:]]*"\([^"]*\)".*$@\1@'\
			<<<"$responsejson")
	lastName=$(sed -e 's@^.*"lastName"[[:space:]]*:[[:space:]]*"\([^"]*\)".*$@\1@'\
		       <<<"$responsejson")

	echo $firstName $lastName Verification successful;
	if test -f verification_success_script.sh; then \
	    ./verification_success_script.sh "$firstName" "$lastName"
	fi
    # otherwise, consider verificaiton to have failed
    else \
	echo Verification failed
	if test -f verification_failed_script.sh; then \
	    ./verification_failed_script.sh
	fi
    fi
}

function processimmunizationcards {
    # for each potential immunization card on standard in
    while read immunizationcard; do \
	# check for the zbarcam QR code prefix and the government URL prefix
	if grep "^$CARD_PREFIX_W_QR_PREFIX"<<<"$immunizationcard" >/dev/null;
	then \
	    # extract the UUID from the read line
	    uuid=$(sed -e "s@^$CARD_PREFIX_W_QR_PREFIX@@"\
		       <<<"$immunizationcard")
	    # validate the format of the uuid
	    # if we wanted to get fancier we would verify a type 4 (random),
	    # sub-variant 1 (standard) UUID
	    if egrep "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"<<<"$uuid" >/dev/null;
	    then \
		# delegate processing an exacted immunization card UUID
		# to another function
		processuuid "$uuid"
	    else echo "malformed UUID on immunization card"
	    fi
	else echo "malformed immunization card"
	fi
    done;
}

# our main pipeline, zbarcam will output a line for every barcode/QR code
# that it sees
#
# we delegate handling each of those lines to a function
zbarcam --nodisplay $VIDEODEVICE | processimmunizationcards
