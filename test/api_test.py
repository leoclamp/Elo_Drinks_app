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
    
    @pytest.mark.pre_made_budgets
    def test_pre_made_budget_success():
        # Criando o mock da resposta
        r = [{"budget_id":5,"user_id":16,"name":"Cervejada","drinks":[{"drink_id":29,"type":"Cerveja","name":"Brahma","price_per_liter":9.0,"dob_id":2,"budget_id":5,"quantity":100},{"drink_id":30,"type":"Cerveja","name":"Heineken","price_per_liter":13.0,"dob_id":3,"budget_id":5,"quantity":150},{"drink_id":31,"type":"Cerveja","name":"Imperio","price_per_liter":8.0,"dob_id":4,"budget_id":5,"quantity":200}],"labor":[{"labor_id":1,"type":"Gar\xc3\xa7om","price_per_hour":13.14,"lob_id":1,"budget_id":5,"quantity":10},{"labor_id":2,"type":"Bartender","price_per_hour":18.32,"lob_id":2,"budget_id":5,"quantity":6}]}]
        mock_response = r

        with patch("api.db_class.Database.get_pre_made_budgets", return_value=mock_response):
            response = client.get("/pre_made_budgets/")    
            
            assert response.status_code == 200
            assert response.json() == mock_response
            
    @pytest.mark.pre_made_budgets
    def test_pre_made_budget_internal_server_error():
        with patch("api.db_class.Database.get_pre_made_budgets", side_effect=Exception("DB Error")):
            response = client.get("/pre_made_budgets/")
            assert response.status_code == 500
            assert response.json() == {"detail": "Internal Server Error"}

    @pytest.mark.pre_made_budgets
    def test_pre_made_budget_empty_result():
    # Simula o método retornando lista vazia
        with patch("api.db_class.Database.get_pre_made_budgets", return_value=[]):
            response = client.get("/pre_made_budgets/")
            assert response.status_code == 200
            assert response.json() == []
            
    @pytest.mark.user_budgets
    def test_get_user_budget_successs():
        # Criando o mock da resposta
        r = [{"budget_id":6,"user_id":14,"name":"Orcamento Teste","drinks":[{"drink_id":32,"type":"Vodka","name":"Absolut","price_per_liter":8.0,"dob_id":8,"budget_id":6,"quantity":15},{"drink_id":33,"type":"Vodka","name":"Askov","price_per_liter":8.0,"dob_id":9,"budget_id":6,"quantity":20},{"drink_id":34,"type":"Rum","name":"Bacardi","price_per_liter":50.9,"dob_id":10,"budget_id":6,"quantity":18}],"labor":[{"labor_id":1,"type":"Gar\xc3\xa7om","price_per_hour":13.14,"lob_id":3,"budget_id":6,"quantity":4},{"labor_id":2,"type":"Bartender","price_per_hour":18.32,"lob_id":4,"budget_id":6,"quantity":5}]}]
        mock_response = r
        
        payload = {"user_id": 14}
        
        with patch("api.db_class.Database.get_user_budgets", return_value=mock_response):
            response = client.post("/user_budgets/", json=payload)    
            
            assert response.status_code == 200
            assert response.json() == mock_response
            
    @pytest.mark.user_budgets
    def test_get_user_budget_user_not_found():
        payload = {"user_id": 9999}  # ID que não existe
        mock_response = []  # Nada encontrado

        with patch("api.db_class.Database.get_user_budgets", return_value=mock_response):
            response = client.post("/user_budgets/", json=payload)

            assert response.status_code == 200
            assert response.json() == {"mensagem": "Nenhum item encontrado"} # Espera uma lista vazia
            
    @pytest.mark.user_budgets
    def test_get_user_budget_invalid_type():
        payload = {"user_id": "abc"}  # Tipo errado, deveria ser int

        response = client.post("/user_budgets/", json=payload)

        assert response.status_code == 422  # Unprocessable Entity
    
    @pytest.mark.budget_labor    
    def test_budgets_labor_get():
        # Criando o mock da resposta
        r = [{'drinks': [{'drink_id': 29, 'type': 'Cerveja', 'name': 'Brahma', 'price_per_liter': 9.0}, {'drink_id': 30, 'type': 'Cerveja', 'name': 'Heineken', 'price_per_liter': 13.0}],
             'labor': [{'labor_id': 1, 'type': 'Garçom', 'price_per_hour': 13.14}, {'labor_id': 2, 'type': 'Bartender', 'price_per_hour': 18.32}]}]
        mock_response = r     
        
        with patch("api.db_class.Database.get_budget_labor", return_value=mock_response):
            response = client.get("/budget/")    

            
            assert response.status_code == 200
            assert response.json() == mock_response
            
    @pytest.mark.budget_labor    
    def test_budgets_labor_get_empty():
        # Criando o mock da resposta
        r = [{'drinks': [{'drink_id': 29, 'type': 'Cerveja', 'name': 'Brahma', 'price_per_liter': 9.0}, {'drink_id': 30, 'type': 'Cerveja', 'name': 'Heineken', 'price_per_liter': 13.0}],
             'labor': [{'labor_id': 1, 'type': 'Garçom', 'price_per_hour': 13.14}, {'labor_id': 2, 'type': 'Bartender', 'price_per_hour': 18.32}]}]
        mock_response = r     
        
        with patch("api.db_class.Database.get_budget_labor", return_value=[]):
            response = client.get("/budget/")    
            
            assert response.status_code == 200
            assert response.json() == {"mensagem": "Nenhum item encontrado"} # Espera uma lista vazia