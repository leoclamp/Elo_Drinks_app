import db_class
from fastapi import FastAPI
from pydantic import BaseModel

# Conectando ao banco de dados PostgreSQL local
database = db_class.Database()
# Executando uma consulta SELECT
#print(database.user_signup("jesus@deus", "123", "Jesus"))
#print(database.user_login("jesus@deus", "123"))

app = FastAPI()

# Modelo de dados de entrada
class User(BaseModel):
    user_name: str
    user_email: str
    user_password: str
    
@app.post("/register/")
def register_user(user: User):
    database.user_signup(user.user_email, user.user_password, user.user_name)
    return {"mensagem": "Item criado com sucesso"}