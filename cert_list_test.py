#!/usr/bin/env python3

import pytest
import datetime
from unittest.mock import Mock, patch
import click.testing
from typing import Any

from cert_list import (
    cert_check,
    print_result_table,
    main,
    limit_days
)


class TestCertCheck:
    def test_cert_check_invalid_connect_format(self) -> None:
        with pytest.raises(SystemExit):
            cert_check('HTTPS', 'invalid-format')

    @patch('cert_list._retrieve_certinfo')
    def test_cert_check_https_valid_cert(
        self, mock_retrieve: Mock
    ) -> None:
        mock_cert = {
            'notBefore': 'Jan  1 00:00:00 2024 GMT',
            'notAfter': 'Dec 31 23:59:59 2025 GMT'
        }
        mock_retrieve.return_value = mock_cert
        test_now = datetime.datetime(2024, 6, 1)

        result = cert_check('HTTPS', 'example.com:443', test_now)

        assert result[0] == 'example.com'
        assert result[1] == '2024-01-01 00:00:00'
        assert result[2] == '2025-12-31 23:59:59'
        assert result[3] == ''  # No warning for valid cert

    @patch('cert_list._retrieve_certinfo')
    def test_cert_check_https_expiring_soon(
        self, mock_retrieve: Mock
    ) -> None:
        mock_cert = {
            'notBefore': 'Jan  1 00:00:00 2024 GMT',
            'notAfter': 'Jun  5 23:59:59 2024 GMT'  # Expires in 4 days
        }
        mock_retrieve.return_value = mock_cert
        test_now = datetime.datetime(2024, 6, 1)
        
        result = cert_check('HTTPS', 'example.com:443', test_now)
        
        assert result[0] == 'example.com'
        expected_msg = (
            f'Some certificates to expire within {limit_days} days'
        )
        assert expected_msg in result[3]

    @patch('cert_list._retrieve_certinfo')
    def test_cert_check_https_expired(
        self, mock_retrieve: Mock
    ) -> None:
        mock_cert = {
            'notBefore': 'Jan  1 00:00:00 2024 GMT',
            'notAfter': 'May 31 23:59:59 2024 GMT'  # Already expired
        }
        mock_retrieve.return_value = mock_cert
        test_now = datetime.datetime(2024, 6, 1)
        
        result = cert_check('HTTPS', 'example.com:443', test_now)
        
        assert result[0] == 'example.com'
        assert 'SOME CERTIFICATES ARE ALREADY EXPIRED' in result[3]

    @patch('cert_list._retrieve_starttls_certinfo')
    def test_cert_check_smtp_service(
        self, mock_retrieve: Mock
    ) -> None:
        mock_cert = {
            'notBefore': 'Jan  1 00:00:00 2024 GMT',
            'notAfter': 'Dec 31 23:59:59 2025 GMT'
        }
        mock_retrieve.return_value = mock_cert
        test_now = datetime.datetime(2024, 6, 1)
        
        result = cert_check('SMTP', 'mail.example.com:587', test_now)
        
        assert result[0] == 'mail.example.com'
        mock_retrieve.assert_called_once_with(
            'mail.example.com', 587
        )

    @patch('cert_list._retrieve_certinfo')
    def test_cert_check_no_cert_returned(
        self, mock_retrieve: Mock
    ) -> None:
        mock_retrieve.return_value = None
        
        with pytest.raises(SystemExit, match="No certificate found"):
            cert_check('HTTPS', 'example.com:443')


class TestPrintResultTable:
    
    @patch('builtins.print')
    def test_print_result_table(self, mock_print: Mock) -> None:
        test_data = [
            [
                'example.com', '2024-01-01 00:00:00',
                '2025-12-31 23:59:59', '', 'color_code'
            ],
            [
                'test.com', '2024-01-01 00:00:00',
                '2024-06-01 23:59:59', 'Warning', 'color_code'
            ]
        ]
        
        print_result_table(test_data)
        
        # Should print header plus one line per data row
        assert mock_print.call_count == len(test_data) + 1
        # First call should be the header
        mock_print.assert_any_call("Resulting table")

    def test_print_result_table_uneven_rows(self) -> None:
        # Test assertion for uneven row lengths
        test_data = [
            ['example.com', '2024-01-01', '2025-12-31'],
            ['test.com', '2024-01-01']  # Missing columns
        ]
        
        with pytest.raises(
            AssertionError,
            match="All rows must have the same number of columns"
        ):
            print_result_table(test_data)


class TestMainCLI:
    
    def test_main_single_check(self) -> None:
        runner = click.testing.CliRunner()
        
        with patch('cert_list.cert_check') as mock_cert_check, \
             patch('cert_list.print_result_table') as mock_print_table:
            
            mock_cert_check.return_value = [
                'example.com', '2024-01-01', '2025-12-31', '', 'color_code'
            ]
            
            result = runner.invoke(
                main, ['--service', 'HTTPS', '--connect', 'example.com:443']
            )
            
            assert result.exit_code == 0
            mock_cert_check.assert_called_once_with(
                'HTTPS', 'example.com:443'
            )
            mock_print_table.assert_called_once()

    def test_main_from_file(self) -> None:
        runner = click.testing.CliRunner()
        test_file_content = (
            "HTTPS example.com:443\nSMTP mail.example.com:587\n"
        )
        
        with patch('cert_list.cert_check') as mock_cert_check, \
             patch('cert_list.print_result_table') as mock_print_table:
            
            mock_cert_check.side_effect = [
                [
                    'example.com', '2024-01-01', '2025-12-31',
                    '', 'color_code'
                ],
                [
                    'mail.example.com', '2024-01-01', '2025-12-31',
                    '', 'color_code'
                ]
            ]
            
            with runner.isolated_filesystem():
                with open('test_hosts.txt', 'w') as f:
                    f.write(test_file_content)
                
                result = runner.invoke(
                    main, ['--from_file', 'test_hosts.txt']
                )
                
                assert result.exit_code == 0
                assert mock_cert_check.call_count == 2
                mock_print_table.assert_called_once()

    def test_main_from_file_with_empty_lines(self) -> None:
        runner = click.testing.CliRunner()
        test_file_content = (
            "HTTPS example.com:443\n\nSMTP mail.example.com:587\n\n"
        )
        
        with patch('cert_list.cert_check') as mock_cert_check, \
             patch('cert_list.print_result_table') as mock_print_table:
            
            mock_cert_check.side_effect = [
                [
                    'example.com', '2024-01-01', '2025-12-31',
                    '', 'color_code'
                ],
                [
                    'mail.example.com', '2024-01-01', '2025-12-31',
                    '', 'color_code'
                ]
            ]
            
            with runner.isolated_filesystem():
                with open('test_hosts.txt', 'w') as f:
                    f.write(test_file_content)
                
                result = runner.invoke(
                    main, ['--from_file', 'test_hosts.txt']
                )
                
                assert result.exit_code == 0
                # Empty lines should be skipped
                assert mock_cert_check.call_count == 2

    def test_main_from_file_malformed_line(self) -> None:
        runner = click.testing.CliRunner()
        test_file_content = "HTTPS example.com:443 extra_token\n"
        
        with runner.isolated_filesystem():
            with open('test_hosts.txt', 'w') as f:
                f.write(test_file_content)
            
            result = runner.invoke(
                main, ['--from_file', 'test_hosts.txt']
            )
            
            # Should raise AssertionError for malformed line
            assert result.exit_code != 0

    def test_main_file_too_large(self) -> None:
        runner = click.testing.CliRunner()
        
        with runner.isolated_filesystem():
            with open('large_file.txt', 'w') as f:
                # Exactly at the limit + 1
                f.write('A' * 2048)
            
            result = runner.invoke(
                main, ['--from_file', 'large_file.txt']
            )
            
            # Should raise AssertionError for file too large
            assert result.exit_code != 0


class TestConstants:
    
    def test_limit_days_constant(self) -> None:
        assert limit_days == 10
        assert isinstance(limit_days, int)


if __name__ == '__main__':
    pytest.main([__file__])
