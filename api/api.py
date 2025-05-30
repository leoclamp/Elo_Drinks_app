import psycopg2
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.encoders import jsonable_encoder
from pydantic import BaseModel
import json
from fastapi.responses import JSONResponse

DATABASE = 'elo_drinks'
SCHEMA = 'public'
PMB_USER_ID = 16
PMB_BDG_ID = 5

class Database:
    def __init__(self):
        self.db = None
        self.cursor = None
        
        self.connect()

    def connect(self):
        self.db = psycopg2.connect(
            database=DATABASE,
            host='localhost',
            user='postgres',
            password='root',
            port='5432'
        )

        self.cursor = self.db.cursor()
        

    def close(self):
        self.db.close()
        
    def __response_treatment(self, response):
        #Tratando os dados de response
        response = jsonable_encoder(response)
        
        # Pega os nomes das colunas
        col_names = [desc[0] for desc in self.cursor.description]
        
        # Transforma em lista de dicionários
        result = [dict(zip(col_names, row)) for row in response]

        # Converte para JSON
        json_result = json.dumps(result, ensure_ascii=False)
        
        json_result = json.loads(json_result)
        
        return json_result
        
    def user_login(self, email, password):
        self.cursor.execute("SELECT user_email, user_password FROM %s.\"user\" WHERE user_email = '%s' AND user_password = '%s';"%(SCHEMA, email, password))

        response = self.cursor.fetchall()
        
        if response != []:
            return True
        else:
            return False
        
    def user_signup(self, email, password, name):
        try:
            self.cursor.execute("INSERT INTO %s.\"user\" (user_email, user_password, user_name) VALUES ('%s', '%s', '%s');"%(SCHEMA, email, password, name))
            self.db.commit()
        except:
            return False
        
        return True
    
    def get_all_drinks(self):
        self.cursor.execute("SELECT * FROM %s.drink;"%(SCHEMA))

        response = self.cursor.fetchall()
        
        json_result = self.__response_treatment(response)
        
        if response != []:
            return json_result
        else:
            return False
        
    def get_all_labors(self):
        self.cursor.execute("SELECT * FROM %s.drink;"%(SCHEMA))

        response = self.cursor.fetchall()
        
        json_result = self.__response_treatment(response)
        
        if response != []:
            return json_result
        else:
            return False
        
        
    def get_pre_made_budgets(self):
        
        self.cursor.execute("SELECT * FROM %s.budget WHERE user_id = %s;"%(SCHEMA, PMB_USER_ID))
            
        response = self.cursor.fetchall()

        # Converte para JSON e realiza o tratamento
        result = self.__response_treatment(response)
        
        # Selecionando os drinks no budget
        query = "SELECT * FROM %s.drink d JOIN %s.drink_on_budget dob ON d.drink_id = dob.drink_id WHERE dob.budget_id = %s"%(SCHEMA, SCHEMA, result[0]["budget_id"])
        
        self.cursor.execute(query)
        drinks_on_budget = self.cursor.fetchall()
        drinks_on_budget = self.__response_treatment(drinks_on_budget)
        
        # Selecionando os labors do budget
        query = "SELECT * FROM %s.labor l JOIN %s.labor_on_budget lob ON l.labor_id = lob.labor_id WHERE lob.budget_id = %s"%(SCHEMA, SCHEMA, result[0]["budget_id"])
        
        self.cursor.execute(query)
        labor_on_budget = self.cursor.fetchall()
        labor_on_budget = self.__response_treatment(labor_on_budget)
        
        result[0]["drinks"] = drinks_on_budget
        result[0]["labor"] = labor_on_budget
        
        if response != []:
            return result
        else:
            return False
    
    def get_user_budgets(self, user_id):
        
        self.cursor.execute("SELECT * FROM %s.budget WHERE user_id = %s;"%(SCHEMA, user_id))
            
        response = self.cursor.fetchall()

        # Converte para JSON e realiza o tratamento
        result = self.__response_treatment(response)
        
        if result == []:
            return False
                
        # Selecionando os drinks no budget
        query = "SELECT * FROM %s.drink d JOIN %s.drink_on_budget dob ON d.drink_id = dob.drink_id WHERE dob.budget_id = %s"%(SCHEMA, SCHEMA, result[0]["budget_id"])
        
        self.cursor.execute(query)
        drinks_on_budget = self.cursor.fetchall()
        drinks_on_budget = self.__response_treatment(drinks_on_budget)
        
        # Selecionando os labors do budget
        query = "SELECT * FROM %s.labor l JOIN %s.labor_on_budget lob ON l.labor_id = lob.labor_id WHERE lob.budget_id = %s"%(SCHEMA, SCHEMA, result[0]["budget_id"])
        
        self.cursor.execute(query)
        labor_on_budget = self.cursor.fetchall()
        labor_on_budget = self.__response_treatment(labor_on_budget)
        
        result[0]["drinks"] = drinks_on_budget
        result[0]["labor"] = labor_on_budget
        
        if response != []:
            return result
        else:
            return False
    
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
class RegisterRequest(BaseModel):
    user_name: str
    user_email: str
    user_password: str

class LoginRequest(BaseModel):
    user_email: str
    user_password: str
    
class UserRequest(BaseModel):
    user_id: int
    
@app.post("/register/")
def register_user(user: RegisterRequest):
    if database.user_signup(user.user_email, user.user_password, user.user_name):
        return {"mensagem": "Item criado com sucesso"}

@app.post("/login/")
def login_user(user: LoginRequest):
    if database.user_login(user.user_email, user.user_password):
        return {"token": "Login realizado"}
    
@app.get("/pre_made_budgets/")
def get_pre_made_budgets():
    response = database.get_pre_made_budgets()
    
    if response:
        response = JSONResponse(content=response, media_type="application/json; charset=utf-8")

        return response
    
@app.get("/user_budgets/")
def get_user_budgets(user: UserRequest):
    response = database.get_user_budgets(user.user_id)
    
    print(response)
    if response:
        response = JSONResponse(content=response, media_type="application/json; charset=utf-8")

        return response
    
#print(get_pre_made_budgets())
#print(database.get_pre_made_budgets())

#user_mock = UserRequest(user_id=14)
#print(get_user_budgets(user_mock))
#print(database.get_user_budgets(user_mock))
    