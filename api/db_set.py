import psycopg2
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

DATABASE = 'elo_drinks'
SCHEMA = 'public'
PMB_ID = 16 # PRE_MADE_BUDGETS ID

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
        
    def set_all_drinks(self):
        try:
            self.cursor.execute("INSERT INTO %s.drink (type, name, price_per_liter) VALUES ('%s', '%s', %s);"%(SCHEMA, 'Cerveja', 'Brahma', 9.0))
            self.cursor.execute("INSERT INTO %s.drink (type, name, price_per_liter) VALUES ('%s', '%s', %s);"%(SCHEMA, 'Cerveja', 'Heineken', 13.0))
            self.cursor.execute("INSERT INTO %s.drink (type, name, price_per_liter) VALUES ('%s', '%s', %s);"%(SCHEMA, 'Cerveja', 'Imperio', 8.0))
            self.cursor.execute("INSERT INTO %s.drink (type, name, price_per_liter) VALUES ('%s', '%s', %s);"%(SCHEMA, 'Vodka', 'Absolut', 8.0))
            self.cursor.execute("INSERT INTO %s.drink (type, name, price_per_liter) VALUES ('%s', '%s', %s);"%(SCHEMA, 'Vodka', 'Askov', 8.0))
            self.cursor.execute("INSERT INTO %s.drink (type, name, price_per_liter) VALUES ('%s', '%s', %s);"%(SCHEMA, 'Rum', 'Bacardi', 50.90))
            self.cursor.execute("INSERT INTO %s.drink (type, name, price_per_liter) VALUES ('%s', '%s', %s);"%(SCHEMA, 'Rum', 'Havana Club', 60.90))
            self.cursor.execute("INSERT INTO %s.drink (type, name, price_per_liter) VALUES ('%s', '%s', %s);"%(SCHEMA, 'Gin', 'Tanqueray', 70.00))
            self.cursor.execute("INSERT INTO %s.drink (type, name, price_per_liter) VALUES ('%s', '%s', %s);"%(SCHEMA, 'Gin', 'Beefeater', 69.90))
            self.cursor.execute("INSERT INTO %s.drink (type, name, price_per_liter) VALUES ('%s', '%s', %s);"%(SCHEMA, 'Tequila', 'José Cuervo', 80.00))
            self.cursor.execute("INSERT INTO %s.drink (type, name, price_per_liter) VALUES ('%s', '%s', %s);"%(SCHEMA, 'Cachaça', '51', 15.0))
            self.cursor.execute("INSERT INTO %s.drink (type, name, price_per_liter) VALUES ('%s', '%s', %s);"%(SCHEMA, 'Whisky', 'Johnnie Walker', 150.0))
            self.cursor.execute("INSERT INTO %s.drink (type, name, price_per_liter) VALUES ('%s', '%s', %s);"%(SCHEMA, 'Whisky', 'Jack Daniels', 200.0))
            self.cursor.execute("INSERT INTO %s.drink (type, name, price_per_liter) VALUES ('%s', '%s', %s);"%(SCHEMA, 'Energético', 'Red Bull', 30.0))
            self.cursor.execute("INSERT INTO %s.drink (type, name, price_per_liter) VALUES ('%s', '%s', %s);"%(SCHEMA, 'Energético', 'TNT', 35.0))
            self.cursor.execute("INSERT INTO %s.drink (type, name, price_per_liter) VALUES ('%s', '%s', %s);"%(SCHEMA, 'Energético', 'Fusion', 40.0))

            self.db.commit()
        except:
            return False
        
        return True# Conectando ao banco de dados PostgreSQL local
    
    def clear_all_drinks(self):
        try:
            self.cursor.execute("DELETE FROM %s.drink;"%(SCHEMA))
            
            self.db.commit()
        except:
            return False
    
        return True
    
    def set_all_labors(self):
        try:
            self.cursor.execute("INSERT INTO %s.labor (type, price_per_hour) VALUES ('%s', %s);"%(SCHEMA, 'Garçom', 13.14)) 
            self.cursor.execute("INSERT INTO %s.labor (type, price_per_hour) VALUES ('%s', %s);"%(SCHEMA, 'Bartender', 18.32)) 

            self.db.commit()
        except:
            return False
        
        return True# Conectando ao banco de dados PostgreSQL local
    
    def clear_all_drinks(self):
        try:
            self.cursor.execute("DELETE FROM %s.labor;"%(SCHEMA))
            
            self.db.commit()
        except:
            return False
    
        return True
    
    def set_pre_made_budgets(self):
        try:
            self.cursor.execute("INSERT INTO %s.budget (user_id, name) VALUES (%s, '%s');"%(SCHEMA, PMB_ID, 'Cervejada'))
            self.cursor.execute("SELECT budget_id FROM %s.budget WHERE name = '%s';"%(SCHEMA, 'Cervejada'))
            
            response = self.cursor.fetchall()
            budget_id = response[0][0]
            
            self.cursor.execute("INSERT INTO %s.drink_on_budget (budget_id, drink_id, quantity) VALUES (%s, %s, %s);"%(SCHEMA, budget_id, 29, 100)) 
            self.cursor.execute("INSERT INTO %s.drink_on_budget (budget_id, drink_id, quantity) VALUES (%s, %s, %s);"%(SCHEMA, budget_id, 30, 150)) 
            self.cursor.execute("INSERT INTO %s.drink_on_budget (budget_id, drink_id, quantity) VALUES (%s, %s, %s);"%(SCHEMA, budget_id, 31, 200)) 
            
            self.cursor.execute("INSERT INTO %s.labor_on_budget (budget_id, labor_id, quantity) VALUES (%s, %s, %s);"%(SCHEMA, budget_id, 1, 10)) 
            self.cursor.execute("INSERT INTO %s.labor_on_budget (budget_id, labor_id, quantity) VALUES (%s, %s, %s);"%(SCHEMA, budget_id, 2, 6)) 
            
            self.db.commit()
        except:
            return False
        
        return True# Conectando ao banco de dados PostgreSQL local
    
    def clear_all_pre_made_budgets(self):
        try:
            self.cursor.execute("DELETE FROM %s.budgte WHER user_id = %s;"%(SCHEMA, PMB_ID))
            
            self.db.commit()
        except:
            return False
    
        return True
    
    def get_pre_made_budgets(self):
        self.cursor.execute("SELECT * FROM %s.budget WHERE user_id = %s;"%(SCHEMA, PMB_ID))
            
        response = self.cursor.fetchall()
        
        print(response)
        
        if response != []:
            return True
        else:
            return False
    
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

#database.set_all_drinks()
#database.set_all_labors()
#database.set_pre_made_budgets()
#database.clear_all_drinks()
#database.clear_all_labors()
#database.clear_pre_made_budgets()
database.get_pre_made_budgets()