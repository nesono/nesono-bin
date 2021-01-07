#!/usr/bin/env python3

import click
import ssl
import socket
import colorama
from colorama import Fore, Style
import datetime


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

@click.command()
@click.option('--service', 
        type=click.Choice(['HTTPS', 'SMTP'], 
        case_sensitive=False), 
        default="http", help='Service to connect to (important for starttls)')
@click.option('--connect',
        help='The service url to connect to in the form <address>:<port>, e.g. www.example.com:443')
def cert_check(service, connect):
    """Function to check the certificate expiry of a specific server"""
    # print(f'Connecting to {service} url {connect}')
    # print(Fore.BLUE + f'Connecting to {service} url {connect}')
    # print(Style.RESET_ALL)

    if not ':' in connect:
        print(f'Connect argument does not contain a colon: {connect}')
        return -1

    hostname, port = connect.split(':')
    port = int(port)
    # print(f'hostname {hostname}, port: {port}')
    if service.lower() == 'https':
        cert = retrieve_certinfo(hostname, port)
    else:
        cert = retrieve_starttls_certinfo(hostname, port)

    #  Nov 27 07:32:24 2020 GMT
    not_before = datetime.datetime.strptime(cert['notBefore'], "%b %d %H:%M:%S %Y %Z") 
    not_after = datetime.datetime.strptime(cert['notAfter'], "%b %d %H:%M:%S %Y %Z") 

    if not_after < datetime.datetime.now():
        print(Style.RESET_ALL + Fore.RED + f'{hostname}: {not_before} - {not_after}')
    else:
        print(Style.RESET_ALL + Fore.GREEN + f'{hostname}: {not_before} - {not_after}')


if __name__ == '__main__':
    cert_check()
