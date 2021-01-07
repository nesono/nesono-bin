#!/usr/bin/env bash


usage()
{
    echo "usage certinfo_http www.example.com:25 [-starttls smtp]"
    echo "On a terminal, call the following line to get validity information:"
    echo "certinfo_http.sh www.example.com:587 -starttls smtp | grep -B 4 -A 3 Validity"
}

if [[ -z "$1" ]]; then
    usage
    exit 1
fi

echo "Parameters forwarded to openssl: $@"
echo "Calling openssl"
echo QUIT | openssl s_client -showcerts -connect "$@" </dev/null | openssl x509 -text
echo "Done"
