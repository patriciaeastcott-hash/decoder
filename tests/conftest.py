"""
Shared pytest fixtures and configuration.
"""

import os
import pytest

# Ensure test environment variables are set
os.environ.setdefault('APP_SECRET_KEY', 'test-secret-key')
os.environ.setdefault('FLASK_DEBUG', 'false')
