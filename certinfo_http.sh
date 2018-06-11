#!/usr/bin/env bash


usage()
{
    echo "usage certinfo_http [-starttls smtp] www.example.com:25"
}

if [[ -z "$1" ]]; then
    usage
    exit 1
fi

echo "Parameters forwarded to openssl: $@"
echo "Calling openssl"
openssl s_client -showcerts -connect $@ </dev/null | openssl x509 -text
echo "Done"
