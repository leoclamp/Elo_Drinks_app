# test_app.py
import pytest
from fastapi.testclient import TestClient
from api.api import *

from mocks import db_register_mock

@pytest.fixture
def cliente():
    return TestClient(app)

def test_hello(client):
    mock = db_register_mock()
    
    response = client.post("/register/")
    assert response.status_code == 200
    assert response.json() == mock
