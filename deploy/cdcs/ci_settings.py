""" CI Settings
"""
from .settings import *

# Override Defender and Django Simlpe Captcha settings to allow for automatic
# regression testing.
DEFENDER_LOGIN_FAILURE_LIMIT = 1000
CAPTCHA_TEST_MODE = True

SSL_CERTIFICATES_DIR = "certs"
