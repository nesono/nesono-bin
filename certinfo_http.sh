#!/usr/bin/env bash


usage()
{
    echo "usage certinfo_http [-starttls smtp] www.example.com:25"
    echo "On a Mac, call the following line to get validity information:"
    echo "certinfo_http.sh www.example.com:587 -starttls smtp | grep -B 4 -A 3 Validity"
}

if [[ -z "$1" ]]; then
    usage
    exit 1
fi

echo "Parameters forwarded to openssl: $@"
echo "Calling openssl"
openssl s_client -showcerts -connect $@ </dev/null | openssl x509 -text
echo "Done"
