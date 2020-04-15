import pytest

def pytest_addoption(parser):
    parser.addoption('--binary-dir', action="store", help='Directory of the AUT')

@pytest.fixture
def binary_dir(request):
    return request.config.getoption('--binary-dir')
