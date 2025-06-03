from fastapi.testclient import TestClient
from fastapi.responses import JSONResponse
from unittest.mock import patch, MagicMock
import pytest

with patch("api.db_class.psycopg2.connect", return_value=MagicMock()):
    
    from api.routes import app  # importa sua API (ajuste o nome se necessário)

    from mocks import api_register_user_mock  # importa o modelo de registro (ajuste o nome se necessário)

    client = TestClient(app)

    @pytest.mark.register
    def test_register_user_success():
        # Criando o mock da resposta
        mock_register_user = MagicMock()
        mock_register_user.mensagem = "Item criado com sucesso"

        payload = {"user_name": "Guilherme", "user_email": "guilherme@gmail.com", "user_password": "123456"}

        with patch("api.db_class.Database.user_signup", return_value=mock_register_user):
            response = client.post("/register/", json=payload)

            assert response.status_code == 200
            assert response.json() == {"mensagem": "Item criado com sucesso"}
        
    @pytest.mark.register
    def test_register_user_invalid_email():
        # Criando o mock da resposta
        mock_register_user = MagicMock()
        mock_register_user.mensagem = "Falha ao criar o item"
        
        payload = {"user_name": "Guilherme", "user_email": "", "user_password": "123456"}

        with patch("api.db_class.Database.user_signup", return_value=mock_register_user):
            response = client.post("/register/", json=payload)

            assert response.status_code == 422
            assert any("email address" in err["msg"] for err in response.json()["detail"])

    @pytest.mark.register
    def test_register_user_invalid_password():
        # Criando o mock da resposta
        mock_register_user = MagicMock()
        mock_register_user.mensagem = "Falha ao criar o item"
        
        payload = {"user_name": "Guilherme", "user_email": "guilherme@gmail.com", "user_password": ""}
        
        with patch("api.db_class.Database.user_signup", return_value=mock_register_user):
            response = client.post("/register/", json=payload)
            
            assert response.status_code == 422

    @pytest.mark.register
    def test_register_user_invalid_name():
        # Criando o mock da resposta
        mock_register_user = MagicMock()
        mock_register_user.mensagem = "Falha ao criar o item"
        
        payload = {"user_name": "", "user_email": "guilherme@gmail.com", "user_password": "123456"}
        
        with patch("api.db_class.Database.user_signup", return_value=mock_register_user):
            response = client.post("/register/", json=payload)
            
            assert response.status_code == 422
            
    @pytest.mark.login
    def test_user_login_success():
        # Criando o mock da resposta
        mock_register_user = MagicMock()
        mock_register_user.token = "Login realizado"
        
        payload = {"user_email": "teste@gmail.com", "user_password": "123456"}
        
        with patch("api.db_class.Database.user_signup", return_value=mock_register_user):
            response = client.post("/login/", json=payload)
            
            assert response.status_code == 200
            assert response.json() == {"token": "Login realizado"}
            
    @pytest.mark.login
    def test_user_login_invalid_password():
        payload = {"user_email": "teste@gmail.com", "user_password": ""}
        
        with patch("api.db_class.Database.user_signup"):
            response = client.post("/login/", json=payload)
            
            assert response.status_code == 422
            
    @pytest.mark.login
    def test_user_login_invalid_email():
        payload = {"user_email": "", "user_password": "123456"}
        
        with patch("api.db_class.Database.user_signup"):
            response = client.post("/login/", json=payload)
            
            assert response.status_code == 422
    
    @pytest.mark.pre_made_budget
    def test_pre_made_budget_success():
        # Criando o mock da resposta

        r = [{"budget_id":5,"user_id":16,"name":"Cervejada","drinks":[{"drink_id":29,"type":"Cerveja","name":"Brahma","price_per_liter":9.0,"dob_id":2,"budget_id":5,"quantity":100},{"drink_id":30,"type":"Cerveja","name":"Heineken","price_per_liter":13.0,"dob_id":3,"budget_id":5,"quantity":150},{"drink_id":31,"type":"Cerveja","name":"Imperio","price_per_liter":8.0,"dob_id":4,"budget_id":5,"quantity":200}],"labor":[{"labor_id":1,"type":"Gar\xc3\xa7om","price_per_hour":13.14,"lob_id":1,"budget_id":5,"quantity":10},{"labor_id":2,"type":"Bartender","price_per_hour":18.32,"lob_id":2,"budget_id":5,"quantity":6}]}]
        mock_response = r
        

        with patch("api.db_class.Database.get_pre_made_budgets", return_value=mock_response):
            response = client.get("/pre_made_budgets/")    
            
            payload = [{"budget_id":5,"user_id":16,"name":"Cervejada","drinks":[{"drink_id":29,"type":"Cerveja","name":"Brahma","price_per_liter":9.0,"dob_id":2,"budget_id":5,"quantity":100},{"drink_id":30,"type":"Cerveja","name":"Heineken","price_per_liter":13.0,"dob_id":3,"budget_id":5,"quantity":150},{"drink_id":31,"type":"Cerveja","name":"Imperio","price_per_liter":8.0,"dob_id":4,"budget_id":5,"quantity":200}],"labor":[{"labor_id":1,"type":"Gar\xc3\xa7om","price_per_hour":13.14,"lob_id":1,"budget_id":5,"quantity":10},{"labor_id":2,"type":"Bartender","price_per_hour":18.32,"lob_id":2,"budget_id":5,"quantity":6}]}]
            
            assert response.status_code == 200
            assert response.json() == mock_response
            
    @pytest.mark.pre_made_budget
    def test_pre_made_budget_internal_server_error():
        with patch("api.db_class.Database.get_pre_made_budgets", side_effect=Exception("DB Error")):
            response = client.get("/pre_made_budgets/")
            assert response.status_code == 500
            assert response.json() == {"detail": "Internal Server Error"}

    @pytest.mark.pre_made_budget
    def test_pre_made_budget_empty_result():
    # Simula o método retornando lista vazia
        with patch("api.db_class.Database.get_pre_made_budgets", return_value=[]):
            response = client.get("/pre_made_budgets/")
            assert response.status_code == 200
            assert response.json() == []
