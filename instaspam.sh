#!/bin/bash
# InstapostSpam v1.0
# https://github.com/cyberkallan/Instapostspamer
# Author: Cyber kallan (You don't become a coder by just changing the credits)

csrftoken=$(curl https://www.instagram.com/accounts/login/ajax -L -i -s | grep "csrftoken" | cut -d "=" -f2 | cut -d ";" -f1)


login_user() {

if [[ "$default_username" == "" ]]; then
read -p $'\e[1;77m[\e[0m\e[1;92m+\e[0m\e[1;77m] Login: \e[0m' username
else
username="${username:-${default_username}}"
fi

if [[ "$default_password" == "" ]]; then
read -s -p $'\e[1;77m[\e[0m\e[1;92m+\e[0m\e[1;77m] Password: \e[0m' password
else
password="${password:-${default_password}}"
fi

printf "\e[\n1;77m[*] Trying to login as\e[0m\e[1;77m %s\e[0m\n" $username
IFS=$'\n'
check_login=$(curl -c cookies.txt 'https://www.instagram.com/accounts/login/ajax/' -H 'Cookie: csrftoken='$csrftoken'' -H 'X-Instagram-AJAX: 1' -H 'Referer: https://www.instagram.com/' -H 'X-CSRFToken:'$csrftoken'' -H 'X-Requested-With: XMLHttpRequest' --data 'username='$username'&password='$password'&intent' -L --compressed -s | grep -o '"authenticated": true')

if [[ "$check_login" == *'"authenticated": true'* ]]; then
printf "\e[1;92m[*] Login Successful!\e[0m\n"
else
printf "\e[1;93m[!] Check your login data or IP! Dont use Tor, VPN, Proxy. It requires your usual IP.\n\e[0m"
login_user
fi

}

config() {

IFS=$'\n'
default_amount="100"
default_message="InstaSpam"
read -p $'\e[1;77m[\e[0m\e[1;92m+\e[0m\e[1;77m] Message: ' message
message="${message:-${default_message}}"
read -p $'\e[1;77m[\e[0m\e[1;92m+\e[0m\e[1;77m] Amount message (Default: 100): ' amount
amount="${amount:-${default_amount}}"

}


account() {

read -p $'\e[1;77m[\e[0m\e[1;92m+\e[0m\e[1;77m] Spammed Account: ' account_spam

checkaccount=$(curl -L -s https://www.instagram.com/$account_spam/ | grep -c "the page may have been removed")
if [[ "$checkaccount" == 1 ]]; then
printf "\e[1;91mInvalid Username! Try again\e[0m\n"
sleep 1
account
fi

curl -s -L https://www.instagram.com/$account_spam | grep  -o '"id":"..................[0-9]' | cut -d ":" -f2 | tr -d '"' > media_id
counter="1"
for id in $(cat media_id); do
printf "\e[1;92m%s:\e[0m\e[1;77m %s\e[0m\n" $counter $id
let counter++
done
default_post="0"
read -p $'\e[1;77m[\e[0m\e[1;92m+\e[0m\e[1;77m] Choose a post (1 = last post): ' post
post="${post:-${default_post}}"

media_id=$(sed ''$post'q;d' media_id)

}

flood() {

count=1
for i in $(seq 1 $amount); do

printf "\e[1;77m[\e[0m\e[1;92m+\e[0m\e[1;77m] Sending message:\e[0m\e[1;93m %s\e[0m\e[1;77m/\e[0m\e[1;93m%s ... \e[0m" $i $amount
IFS=$'\n'

comment=$(curl  -i -s -k  -X $'POST'     -H $'Host: www.instagram.com' -H $'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101 Firefox/52.0' -H $'Accept: */*' -H $'Accept-Language: en-US,en;q=0.5' -H $'Accept-Encoding: gzip, deflate'  -H $'X-CSRFToken:'$csrftoken'' -H $'X-Instagram-AJAX: 9de6d949df8f' -H $'Content-Type: application/x-www-form-urlencoded' -H $'X-Requested-With: XMLHttpRequest' -H $'Cookie: csrftoken='$csrftoken'; ' -H $'Connection: close'     -b cookies.txt     --data-binary $'comment_text='$message' '$count'&replied_to_comment_id='     $'https://www.instagram.com/web/comments/'$media_id'/add/' -w "\n%{http_code}\n" | grep -a "HTTP/2 200"); if [[ "$comment" == *'HTTP/2 200'* ]]; then printf "\e[1;92mOK!\e[0m\n";  printf "%s\n" $media_id >> commented.txt ; else printf "\e[1;93mFAIL!\e[0m \e[1;77mSleeping 120 secs...\e[0m\n"; sleep 120;  fi; 
sleep 1
let count++
done
}

dependencies() {

command -v curl > /dev/null 2>&1 || { echo >&2 "I require curl but it's not installed. Run ./install.sh. Aborting."; exit 1; }

}

banner() {

printf "\e[1;77m  _____           _         _____                        \n"
printf " |_   _|         | |       / ____|                       \n"
printf "   | |  _ __  ___| |_ __ _| (___  _ __   __ _ _ __ ___   \n"
printf "   | | | '_ \/ __| __/ _\` |\___ \| '_ \ / _\` | '_ \` _ \  \n"
printf "  _| |_| | | \__ \ || (_| |____) | |_) | (_| | | | | | | \n"
printf " |_____|_| |_|___/\__\__,_|_____/| .__/ \__,_|_| |_| |_| \n"
printf "                                 | | c͔ͣͦ́́͂ͅy͉̝͖̻̯ͮ̒̂ͮ͋ͫͨb͎̣̫͈̥̗͒͌̃͑̔̾ͅe̮̟͈̣̖̰̩̹͈̾ͨ̑͑r̼̯̤̈ͭ̃ͨ̆ k̲̱̠̞̖ͧ̔͊̇̽̿̑ͯͅa̘̫͈̭͌͛͌̇̇̍l͕͖͉̭̰ͬ̍ͤ͆̊ͨl͕͖͉̭̰ͬ̍ͤ͆̊ͨa̘̫͈̭͌͛͌̇̇̍n͉̠̙͉̗̺̋̋̔ͧ̊                    \n"
printf "                                 |_|\e[0m\e[1;92mv1.0 @Cyber kallan\e[0m                     \n"
printf "\n"

}

banner
dependencies
login_user
config
account
flood





