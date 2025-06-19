import psycopg2
from fastapi import FastAPI
from fastapi import HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, EmailStr, constr, conint, Field
from typing import List, Annotated
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
    
class DrinkItem(BaseModel):
    drink_id: int
    quantity: Annotated[int, Field(ge=1)]

class LaborItem(BaseModel):
    labor_id: int
    quantity: Annotated[int, Field(ge=1)]

class BudgetRequest(BaseModel):
    name: str
    user_id: str
    drinks: List[DrinkItem]
    labors: List[LaborItem]
    hours: Annotated[int, Field(ge=1)]

class DeleteBudget(BaseModel):
    user_id: str
    budget_id: str
    
@app.post("/register/")
def register_user(user: RegisterRequest):
    
    if database.user_signup(user.user_email, user.user_password, user.user_name):
        return {"mensagem": "Item criado com sucesso"}
    else:
        return {"mensagem": "Falha ao criar item"}

@app.post("/login/")
def login_user(user: LoginRequest):
    response = database.user_login(user.user_email, user.user_password)
    
    if response:
        return {"token": "Login realizado", "user_id": response}
    
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
    
@app.get("/budget_labor/")
def get_budget_labor():
    response = database.get_budget_labor()
    
    if response:
        response = JSONResponse(content=response, media_type="application/json; charset=utf-8")
        
        return response
    else:
        return {"mensagem": "Nenhum item encontrado"}

@app.post("/budget_labor/")
def create_budget(budget: BudgetRequest):
    print(budget)
    try:
        new_id = database.create_budget(
            user_id=int(budget.user_id),
            name=budget.name,
            hours=budget.hours,
            drinks=[{"drink_id": d.drink_id, "quantity": d.quantity} for d in budget.drinks],
            labors=[{"labor_id": l.labor_id, "quantity": l.quantity} for l in budget.labors],
        )
        if new_id is None:
            # tratamento de falha interna
            raise HTTPException(status_code=500, detail="Falha ao criar budget")
        return {"budget_id": new_id, "message": "Budget criado com sucesso"}
    except HTTPException:
        raise
    except Exception as e:
        # log se quiser: print(f"Erro em create_budget: {e}")
        raise HTTPException(status_code=500, detail="Erro interno ao criar budget")

@app.post("/delete_budget/")
def delete_budget(info: DeleteBudget):
    # Validações básicas
    if int(info.user_id) <= 0 or int(info.budget_id) <= 0:
        raise HTTPException(status_code=400, detail="IDs inválidos")
    ok = database.delete_budget(int(info.user_id), int(info.budget_id))
    if ok:
        return {"budget_id": int(info.budget_id), "message": "Budget deletado com sucesso"}
    else:
        # Pode ser porque não existia ou erro interno
        # Se quiser diferenciar, o método poderia lançar exceção ou retornar código distinto
        raise HTTPException(status_code=404, detail="Orçamento não encontrado ou não pertence ao usuário")

#print(database.user_login("teste@gmail.com", "123"))

#print(database.get_all_drinks())    
#print(database.get_all_labors())    
    
#print(get_pre_made_budgets())
#print(database.get_pre_made_budgets())

#get_user_budgets(UserRequest(user_id=14))
#print(get_user_budgets(UserRequest(user_id=14)))
#print(database.get_user_budgets(user_mock))
    
#print(get_budget_labor())
#print(database.get_budget_labor())