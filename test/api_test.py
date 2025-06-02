from fastapi.testclient import TestClient
from unittest.mock import patch, MagicMock

with patch("api.db_class.psycopg2.connect", return_value=MagicMock()):
    
    from api.api import app  # importa sua API (ajuste o nome se necessário)

    from mocks import api_register_user_mock  # importa o modelo de registro (ajuste o nome se necessário)

    client = TestClient(app)

    def test_register_user():
        # Criando o mock da resposta
        mock_register_user = MagicMock()
        mock_register_user.mensagem = "Item criado com sucesso"

        payload = {"user_name": "Guilherme", "user_email": "guilherme@gmail.com", "user_password": "123456"}

        with patch("api.db_class.Database.user_signup", return_value=mock_register_user):
            response = client.post("/register/", json=payload)

            assert response.status_code == 200
            assert response.json() == {"mensagem": "Item criado com sucesso"}
        
    def test_register_user_invalid_email():
        # Criando o mock da resposta
        mock_register_user = MagicMock()
        mock_register_user.mensagem = "Falha ao criar o item"
        
        payload = {"user_name": "Guilherme", "user_email": "", "user_password": "123456"}

        with patch("api.db_class.Database.user_signup", return_value=mock_register_user):
            response = client.post("/register/", json=payload)

            assert response.status_code == 400
            assert response.json() == {"mensagem": "Falha ao criar o item"}
        
    def test_register_user_invalid_password():
        # Criando o mock da resposta
        mock_register_user = MagicMock()
        mock_register_user.mensagem = "Falha ao criar o item"
        
        payload = {"user_name": "Guilherme", "user_email": "guilherme@gmail.com", "user_password": ""}

        assert response.status_code == 200
        assert response.json() == {"mensagem": "Falha ao criar o item"}