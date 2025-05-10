from fastapi.testclient import TestClient
from api.api import app  # importa sua API (ajuste o nome se necessário)
from mocks import db_register_mock

client = TestClient(app)
mock_response = db_register_mock()

def test_register_user():
    payload = {
        "user_name": "Teste",
        "user_email": "teste@email.com",
        "user_password": "123456"
    }
    
    response = client.post("/register/", json=payload)
    
    assert response.status_code == 200
    assert response.json() == {"mensagem": "Item criado com sucesso"}
