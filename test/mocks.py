from api.api import RegisterRequest

def api_register_user_mock():
    r = RegisterRequest(user_name="Guilherme", user_email="teste@gmail.com", user_password="123456")
    return r