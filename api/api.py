import psycopg2
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

class Database:
    def __init__(self):
        self.db = None
        self.cursor = None
        
        self.connect()

    def connect(self):
        self.db = psycopg2.connect(
            database='login_teste',
            host='localhost',
            user='postgres',
            password='root',
            port='5432'
        )

        self.cursor = self.db.cursor()
        

    def close(self):
        self.db.close()
        
    def user_login(self, email, password):
        self.cursor.execute("SELECT user_email, user_password FROM teste.\"users\" WHERE user_email = '%s' AND user_password = '%s';"%(email, password))

        response = self.cursor.fetchall()
        
        if response != []:
            return True
        else:
            return False
        
    def user_signup(self, email, password, name):
        try:
            self.cursor.execute("INSERT INTO teste.\"users\" (user_email, user_password, user_name) VALUES ('%s', '%s', '%s');"%(email, password, name))
            self.db.commit()
        except:
            return False
        
        return True
    
# Conectando ao banco de dados PostgreSQL local
database = Database()
# Executando uma consulta SELECT
#print(database.user_signup("jesus@deus", "123", "Jesus"))
#print(database.user_login("jesus@deus", "123"))

app = FastAPI()
#uvicorn api.api:app --reload

# Permitir o Flutter acessar a API
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # ou coloque ["http://localhost:3000"] se quiser restringir
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Modelo de dados de entrada
class User(BaseModel):
    user_name: str
    user_email: str
    user_password: str
    
@app.post("/register/")
def register_user(user: User):
    database.user_signup(user.user_email, user.user_password, user.user_name)
    return {"mensagem": "Item criado com sucesso"}