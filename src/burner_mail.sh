#!/bin/bash

api="https://burnermail.io/api"
user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Safari/537.36"

function sign_in() {
	# 1 - email: (string): <email>
	# 2 - password: (string): <password>
	email=$1
	password=$2
	response=$(curl --request POST \
		--url "$api/auth/sign_in" \
		--user-agent "$user_agent" \
		--header "content-type: application/x-www-form-urlencoded" \
		--header "api_application_key: 1234test" \
		--data "email=$email&password=$password" \
		-i -s)
	client=$(echo "$response" | grep -iE '^client:' | awk '{print $2}')
	access_token=$(echo "$response" | grep -iE '^access_token:' | awk '{print $2}')
	app_session=$(echo "$(get_aliases)" | grep -iE '_goninja-app_session:' | awk '{print $2}')
	echo $response
}

function register() {
	# 1 - email: (string): <email>
	# 2 - password: (string): <password>
	email=$1
	password=$2
	response=$(curl --request POST \
		--url "$api/auth" \
		--user-agent "$user_agent" \
		--header "content-type: application/x-www-form-urlencoded" \
		--header "api_application_key: 1234test" \
		--data "email=$email&password=$password" \
		-i -s)
	client=$(echo "$response" | grep -iE '^client:' | awk '{print $2}')
	access_token=$(echo "$response" | grep -iE '^access_token:' | awk '{print $2}')
	app_session=$(echo "$(get_aliases)" | grep -iE '_goninja-app_session:' | awk '{print $2}')
	echo $response
}

function get_aliases() {
	curl --request GET \
		--url "$api/aliases?email=$email&password=$password" \
		--user-agent "$user_agent" \
		--header "api_application_key: 1234test" \
		--header "client: $client" \
		--header "token-type: Bearer" \
		--header "access-token: $access_token" \
		--header "uid: $email" \
		--header "cookie: $app_session"
}

function get_users() {
	curl --request GET \
		--url "$api/users" \
		--user-agent "$user_agent" \
		--header "api_application_key: 1234test" \
		--header "client: $client" \
		--header "token-type: Bearer" \
		--header "access-token: $access_token" \
		--header "uid: $email" \
		--header "cookie: $app_session"
}

function generate_alias() {
	curl --request POST \
		--url "$api/v2/aliases/generate" \
		--user-agent "$user_agent" \
		--header "content-type: application/json" \
		--header "cookie: $app_session" \
		--data "{
			\"aliases\": {
				\"domain\": \" \"
			}
		}" 
}

function get_domains() {
	curl --request GET \
		--url "$api/v1/domains" \
		--user-agent "$user_agent" \
		--header "content-type: application/json" \
		--header "cookie: $app_session"
}

function get_hash() {
	curl --request GET \
		--url "$api/v1/hash" \
		--user-agent "$user_agent" \
		--header "content-type: application/json" \
		--header "cookie: $app_session"
}

function get_account_info() {
	curl --request GET \
		--url "$api/v1/users.json" \
		--user-agent "$user_agent" \
		--header "content-type: application/json" \
		--header "cookie: $app_session"
}

function get_virtual_emails() {
	curl --request GET \
		--url "$api/v1/virtual_emails.json" \
		--user-agent "$user_agent" \
		--header "content-type: application/json" \
		--header "cookie: $app_session"
}

function create_virtual_email() {
	# 1 - email: (string): <email>
	curl --request POST \
		--url "$api/v1/virtual_emails" \
		--user-agent "$user_agent" \
		--header "content-type: application/json" \
		--header "cookie: $app_session" \
		--data '{
			"virtual_emails": {
				"hash": "'$(jq -r ".hash" <<< "$(get_hash)")'",
				"address": "'$1'"
			}
		}' 
}

function preview_email() {
	# 1 - email: (string): <email>
	# 2 - first: (integer): <first - default: 0>
	# 3 - last: (integer): <last - default: 10>
	curl --request POST \
		--url "$api/v1/emails/preview" \
		--user-agent "$user_agent" \
		--header "content-type: application/json" \
		--header "cookie: $app_session" \
		--data '{
			"virtual_emails": {
				"email": "'$1'"
			},
			"first": "'${2:-0}'",
			"last": "'${3:-10}'"
		}' 
}

function read_message() {
	# 1 - email: (string): <email>
	# 2 - message_id: (integer): <message_id>
	curl --request POST \
		--url "$api/v1/emails/open" \
		--user-agent "$user_agent" \
		--header "content-type: application/json" \
		--header "cookie: $app_session" \
		--data '{
			"virtual_emails": {
				"email": "'$1'",
				"email_id": "'$2'"
			}
		}' 
}

function delete_email() {
	# 1 - email: (string): <email>
	curl --request POST \
		--url "$api/v1/aliases/delete" \
		--user-agent "$user_agent" \
		--header "content-type: application/json" \
		--header "cookie: $app_session" \
		--data '{
			"email": "'$1'"
		}' 
}
