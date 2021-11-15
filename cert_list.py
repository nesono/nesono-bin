#!/usr/bin/env python3

import click
import ssl
import socket
import colorama
from colorama import Fore, Style
import datetime

# import logging

# logging.basicConfig(format='%(asctime)s %(levelname)s:%(message)s', level=logging.DEBUG)
# logger = logging.getLogger(__file__)

def retrieve_certinfo(hostname, port):
    ctx = ssl.create_default_context()
    with ctx.wrap_socket(socket.socket(), server_hostname=hostname) as s:
        s.connect((hostname, port))
        cert = s.getpeercert()

    return cert

def retrieve_starttls_certinfo(hostname, port):
    context = ssl.create_default_context()
    with socket.create_connection((hostname, port)) as sock:
        sock.recv(1000)
        sock.send(b'EHLO\nSTARTTLS\n')
        sock.recv(1000)
        with context.wrap_socket(sock, server_hostname=hostname) as sslsock:
            return sslsock.getpeercert()
    return None

def print_cert_check(service, connect, now=datetime.datetime.now()):
    """Function to check and print the certificate expiry of a specific service"""

    if not ':' in connect:
        print(f'Connect argument does not contain a colon: {connect}')
        return -1

    hostname, port = connect.split(':')
    port = int(port)
    if service.lower() == 'https':
        cert = retrieve_certinfo(hostname, port)
    else:
        cert = retrieve_starttls_certinfo(hostname, port)

    #  formatted as Nov 27 07:32:24 2020 GMT
    not_before = datetime.datetime.strptime(cert['notBefore'], "%b %d %H:%M:%S %Y %Z") 
    not_after = datetime.datetime.strptime(cert['notAfter'], "%b %d %H:%M:%S %Y %Z") 

    color = Fore.GREEN

    if not_after < (now + datetime.timedelta(days=10)):
        color = Fore.YELLOW

    if not_after < now:
        color = Fore.RED

    print(Style.RESET_ALL + color + f'{hostname}: {not_before} - {not_after}' + Style.RESET_ALL)


@click.command()
@click.option('--service', 
        type=click.Choice(['HTTPS', 'SMTP'], 
        case_sensitive=False), 
        default="HTTPS", help='Service to connect to (important for starttls)')
@click.option('--connect',
        help='The service url to connect to in the form <address>:<port>, e.g. www.example.com:443')
@click.option('--from_file',
        help='Reading the service and endpoint from file line by line.\nFormat:\nHTTPS www.example.com:443',
        type=click.File('r'))
def main(service, connect, from_file):
    if from_file:
        now = datetime.datetime.now()

        full_file = from_file.read(2048)
        assert len(full_file) < 2048, "Only files up to 2047 bytes supported for now"

        for line in full_file.split('\n'):
            # file could contain empty lines
            if len(line) == 0:
               return 

            tokens = line.strip().split(' ')
            assert len(tokens) == 2, f"Misformed line {line}"

            print_cert_check(tokens[0], tokens[1], now)
    else:
        print_cert_check(service, connect)


if __name__ == '__main__':
    main()
