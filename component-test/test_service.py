import pytest
import subprocess
import os

def test_service_boot(binary_dir):
    service_path = os.path.join(binary_dir, 'my-application')
    result = subprocess.check_output([service_path])
    assert result == b'Test'
