import pytest
import subprocess
import os

application_name = 'example-ptest'

def test_service_systemd_boot():
    result = subprocess.run(['systemctl','start',application_name])
    assert result.returncode == 0

def test_service_shows_logs():
    result = subprocess.check_output(['journalctl','-u',application_name])
    assert b"Test" in result
