import psycopg2
from fastapi import FastAPI
from fastapi import HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, EmailStr, constr
from fastapi.responses import JSONResponse

try:
    from .db_class import Database
except:
    from db_class import Database
    
# Conectando ao banco de dados PostgreSQL local
database = Database()

app = FastAPI()
#uvicorn api.routes:app --reload

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
    user_name: constr(min_length=1) # type: ignore
    user_email: EmailStr
    user_password: constr(min_length=1) # type: ignore

class LoginRequest(BaseModel):
    user_email: constr(min_length=1) # type: ignore
    user_password: constr(min_length=1) # type: ignore
    
class UserRequest(BaseModel):
    user_id: int
    
class BudgetRequest(BaseModel):
    user_id: int
    
@app.post("/register/")
def register_user(user: RegisterRequest):
    
    if database.user_signup(user.user_email, user.user_password, user.user_name):
        return {"mensagem": "Item criado com sucesso"}
    else:
        return {"mensagem": "Falha ao criar item"}

@app.post("/login/")
def login_user(user: LoginRequest):
    if database.user_login(user.user_email, user.user_password):
        return {"token": "Login realizado"}
    
@app.get("/pre_made_budgets/")
def get_pre_made_budgets():
    try:
        response = database.get_pre_made_budgets()
    
        response = JSONResponse(content=response, media_type="application/json; charset=utf-8")
        
        return response
    except Exception as e:
        raise HTTPException(status_code=500, detail="Internal Server Error")
    
@app.post("/user_budgets/")
def get_user_budgets(user: UserRequest):
    response = database.get_user_budgets(user.user_id)
    
    if response:
        response = JSONResponse(content=response, media_type="application/json; charset=utf-8")
        
        return response
    else:
        return {"mensagem": "Nenhum item encontrado"}
    
@app.get("/budget/")
def get_budget_labor():
    response = database.get_budget_labor()
    
    if response:
        response = JSONResponse(content=response, media_type="application/json; charset=utf-8")
        
        return response
    else:
        return {"mensagem": "Nenhum item encontrado"}
    
@app.post("/budget/")
def create_budget(budget: BudgetRequest):
    pass

#print(database.get_all_drinks())    
#print(database.get_all_labors())    
    
#print(get_pre_made_budgets())
#print(database.get_pre_made_budgets())

#print(get_user_budgets(UserRequest(user_id=14)))
#print(database.get_user_budgets(user_mock))
    
print(get_budget_labor())
#print(database.get_budget_labor())