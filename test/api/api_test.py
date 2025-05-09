# test_app.py
import pytest
from fastapi.testclient import TestClient
from api.api import *

@pytest.fixture
def cliente():
    return TestClient(app)

def test_hello(client):
    response = client.post("/register/")
    assert response.status_code == 200
    assert response.json() == {
        "user_email": "guilherme@email.com",
        "user_password": "123456",
        "user_name": "Guilherme"}
