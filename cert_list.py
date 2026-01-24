#!/usr/bin/env python3

import click
import ssl
import socket
from colorama import Fore, Style
import datetime
from typing import Final, Any, TextIO

import logging

logging.basicConfig(
    format="%(asctime)s %(levelname)s:%(message)s", level=logging.DEBUG
)
logger = logging.getLogger(__file__)

limit_days: Final = 10


def _retrieve_certinfo(hostname: str, port: int) -> dict[str, Any] | None:
    try:
        ctx = ssl.create_default_context()
        with ctx.wrap_socket(socket.socket(), server_hostname=hostname) as s:
            s.connect((hostname, port))
            cert = s.getpeercert()
    except ssl.SSLCertVerificationError:
        click.echo(f"SSL Certification Error with {hostname}:{port}")
        return None

    return cert


def _retrieve_starttls_certinfo(
    hostname: str, port: int
) -> dict[str, Any] | None:
    context = ssl.create_default_context()
    try:
        with socket.create_connection((hostname, port)) as sock:
            sock.recv(1000)
            sock.send(b"EHLO\nSTARTTLS\n")
            sock.recv(1000)
            with context.wrap_socket(
                sock, server_hostname=hostname
            ) as sslsock:
                return sslsock.getpeercert()
    except (ssl.SSLError, socket.error) as e:
        logger.error(
            f"Error retrieving STARTTLS certificate for {hostname}:{port}: {e}"
        )
        return None


def cert_check(
    service: str,
    connect: str,
    now: datetime.datetime = datetime.datetime.now(),
) -> list[str]:
    """Check and print certificate expiry of a specific service."""
    if ":" not in connect:
        raise SystemExit(f"Connect argument is missing the colon: {connect}")

    hostname, port = connect.split(":")
    port = int(port)
    if service.lower() == "https":
        cert = _retrieve_certinfo(hostname, port)
    else:
        cert = _retrieve_starttls_certinfo(hostname, port)

    if not cert:
        raise SystemExit("No certificate found")

    #  formatted as Nov 27 07:32:24 2020 GMT
    not_before = datetime.datetime.strptime(
        cert["notBefore"],
        "%b %d %H:%M:%S %Y %Z",
    )
    not_after = datetime.datetime.strptime(
        cert["notAfter"],
        "%b %d %H:%M:%S %Y %Z",
    )

    verdict = ""

    color = Fore.GREEN

    if not_after < (now + datetime.timedelta(days=10)):
        verdict = f"Some certificates to expire within {limit_days} days"
        color = Fore.YELLOW

    if not_after < now:
        verdict = "SOME CERTIFICATES ARE ALREADY EXPIRED"
        color = Fore.RED

    return [hostname, f"{not_before}", f"{not_after}", verdict, color]


def print_result_table(tokens: list[list[str]]) -> None:
    assert all(len(row) == len(tokens[0]) for row in tokens), (
        "All rows must have the same number of columns"
    )
    max_length = [0] * len(tokens[0])
    for row in tokens:
        for i, col in enumerate(row):
            max_length[i] = max(max_length[i], len(col))
    print("Resulting table")
    for line in tokens:
        print(
            Style.RESET_ALL
            + line[-1]
            + f"{line[0]:<{max_length[0]}} :: "
            + f"{line[1]:<{max_length[1]}} -> "
            + f"{line[2]:<{max_length[2]}} "
            + f"{line[3]:<{max_length[3]}} "
            + Style.RESET_ALL
        )


@click.command()
@click.option(
    "--service",
    type=click.Choice(["HTTPS", "SMTP"], case_sensitive=False),
    default="HTTPS",
    help="Service to connect to (important for starttls)",
)
@click.option(
    "--connect",
    help="Service url to connect to, e.g. www.example.com:443",
)
@click.option(
    "--from_file",
    help="Read 'service endpoint' from file\n"
    "Format: HTTPS www.example.com:443",
    type=click.File("r"),
)
def main(service: str, connect: str | None, from_file: TextIO | None) -> None:
    if from_file:
        now = datetime.datetime.now()

        full_file = from_file.read(2048)
        assert len(full_file) < 2048, (
            "Only files up to 2047 bytes supported for now"
        )

        results = []
        for line in full_file.split("\n"):
            # file could contain empty lines
            if len(line) == 0:
                continue

            tokens = line.strip().split(" ")
            assert len(tokens) == 2, f"Misformed line {line}"

            results.append(cert_check(tokens[0], tokens[1], now))

        print_result_table(results)
    else:
        if not connect:
            raise SystemExit("Missing parameter '--connect'")
        print_result_table([cert_check(service, connect)])


if __name__ == "__main__":
    main()
