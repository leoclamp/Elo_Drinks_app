from fastapi.testclient import TestClient

from api.api import app  # importa sua API (ajuste o nome se necessário)

from mocks import api_register_user_mock  # importa o modelo de registro (ajuste o nome se necessário)

client = TestClient(app)

def test_register_user():
    payload = api_register_user_mock()
    
    response = client.post("/register/", json=payload)
    
    assert response.status_code == 200
    assert response.json() == {"mensagem": "Item criado com sucesso"}
