import psycopg2
from fastapi.encoders import jsonable_encoder
import json

DATABASE = 'elo_drinks'
SCHEMA = 'public'
PMB_USER_ID = 16
PMB_BDG_ID = 5

DB_CONFIG = {
    "database": DATABASE,
    "user": "elo_drinks_owner",
    "password": "npg_AMeGik5Rl0QH",
    "host": "ep-shy-base-ac3dzbd5-pooler.sa-east-1.aws.neon.tech",
    "port": "5432",
    "sslmode": "require"
}

class Database:
    def __init__(self):
        self.db = None
        self.cursor = None
        
        self.connect()

    def connect(self):
        self.db = psycopg2.connect(**DB_CONFIG)
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
        self.cursor.execute("SELECT user_id FROM %s.\"user\" WHERE user_email = '%s' AND user_password = '%s';"%(SCHEMA, email, password))

        response = self.cursor.fetchall()
        
        response = self.__response_treatment(response)
        
        if response != []:
            return response[0]['user_id']
        else:
            return False
        
    def user_signup(self, email, password, name):
        if email == None or password == None or name == None:
            return False
        elif len(email) == 0 or len(password) == 0 or len(name) == 0:
            return False
        
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
        self.cursor.execute("SELECT * FROM %s.labor;"%(SCHEMA))

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
        if result == []:
            return False
        
        # Selecionando os drinks em cada budget
        for index in range(len(result)):
            query = "SELECT * FROM %s.drink d JOIN %s.drink_on_budget dob ON d.drink_id = dob.drink_id WHERE dob.budget_id = %s"%(SCHEMA, SCHEMA, result[index]["budget_id"])

            self.cursor.execute(query)
            drinks_on_budget = self.cursor.fetchall()
            drinks_on_budget = self.__response_treatment(drinks_on_budget)

            # Selecionando os labors do budget
            query = "SELECT * FROM %s.labor l JOIN %s.labor_on_budget lob ON l.labor_id = lob.labor_id WHERE lob.budget_id = %s"%(SCHEMA, SCHEMA, result[index]["budget_id"])

            self.cursor.execute(query)
            labor_on_budget = self.cursor.fetchall()
            labor_on_budget = self.__response_treatment(labor_on_budget)

            result[index]["drinks"] = drinks_on_budget
            result[index]["labor"] = labor_on_budget       
        
        if response != []:
            return result
        else:
            return False
    
    def get_user_budgets(self, user_id):
        if user_id <= 0:
            return False
        
        self.cursor.execute("SELECT * FROM %s.budget WHERE user_id = %s;"%(SCHEMA, user_id))
            
        response = self.cursor.fetchall()

        # Converte para JSON e realiza o tratamento
        result = self.__response_treatment(response)
        
        if result == []:
            return False
        
        # Selecionando os drinks em cada budget
        for index in range(len(result)):
            query = "SELECT * FROM %s.drink d JOIN %s.drink_on_budget dob ON d.drink_id = dob.drink_id WHERE dob.budget_id = %s"%(SCHEMA, SCHEMA, result[index]["budget_id"])

            self.cursor.execute(query)
            drinks_on_budget = self.cursor.fetchall()
            drinks_on_budget = self.__response_treatment(drinks_on_budget)

            # Selecionando os labors do budget
            query = "SELECT * FROM %s.labor l JOIN %s.labor_on_budget lob ON l.labor_id = lob.labor_id WHERE lob.budget_id = %s"%(SCHEMA, SCHEMA, result[index]["budget_id"])

            self.cursor.execute(query)
            labor_on_budget = self.cursor.fetchall()
            labor_on_budget = self.__response_treatment(labor_on_budget)

            result[index]["drinks"] = drinks_on_budget
            result[index]["labor"] = labor_on_budget       
        
        if response != []:
            return result
        else:
            return False
        
    def get_budget_labor(self):
        drinks = self.get_all_drinks()
        
        labor = self.get_all_labors()
        
        response = {
                    "drinks": drinks,
                    "labor": labor
                }
        
        return response
    
    def create_budget(self, user_id: int, name: str, hours: int,
                      drinks: list[dict], labors: list[dict]) -> int | None:
        """
        Insere um novo budget e associa bebidas e mão de obra.
        Espera:
          drinks: lista de dicts com 'drink_id' e 'quantity'
          labors: lista de dicts com 'labor_id' e 'quantity'
        Retorna o budget_id criado, ou None em falha.
        """
        try:
            # 1) Insere na tabela principal de budgets. Ajuste nome da tabela e colunas conforme seu esquema.
            # Exemplo de tabela: budgets(id serial primary key, user_id int references users, name text, hours int, created_at timestamp default now())
            insert_budget = """
                INSERT INTO %s.budget (user_id, name, hours)
                VALUES (%s, '%s', %s)
                RETURNING budget_id;
            """%(SCHEMA, user_id, name, hours)
            self.cursor.execute(insert_budget)
            result = self.cursor.fetchone()
            if result is None:
                self.db.rollback()
                return None
            budget_id = result[0]
            # "SELECT user_id FROM %s.\"user\" WHERE user_email = '%s' AND user_password = '%s';"%(SCHEMA, email, password)

            # 2) Inserir bebidas associadas:
            # Supondo tabela drink_on_budget(budget_id int references budgets, drink_id int references drinks, quantity int)
            for item in drinks:
                drink_id = item["drink_id"]
                qty = item["quantity"]
                insert_drink = """
                    INSERT INTO %s.drink_on_budget (budget_id, drink_id, quantity)
                    VALUES (%s, %s, %s);
                """%(SCHEMA, budget_id, drink_id, qty)
                # Opcional: verificar se drink_id existe e preço, se quiser calcular total aqui
                self.cursor.execute(insert_drink)

            # 3) Inserir labors associadas:
            # Supondo tabela labor_on_budget(budget_id int references budgets, labor_id int references labors, quantity int)
            for item in labors:
                labor_id = item["labor_id"]
                qty = item["quantity"]
                insert_labor = """
                    INSERT INTO %s.labor_on_budget (budget_id, labor_id, quantity)
                    VALUES (%s, %s, %s);
                """%(SCHEMA, budget_id, labor_id, qty)
                self.cursor.execute(insert_labor)

            # 4) Se você quiser armazenar total no banco, pode calcular aqui:
            #    - Buscar preço de cada drink e multiplicar por quantidade
            #    - Buscar preço por hora de cada labor, multiplicar por qty e por hours
            # E então atualizar budget com total:
            # Exemplo:
            # total_drinks = 0.0
            # for item in drinks:
            #     self.cursor.execute("SELECT price_per_liter FROM drinks WHERE id=%s", (item["drink_id"],))
            #     row = self.cursor.fetchone()
            #     if row:
            #         price = row[0]
            #         total_drinks += price * item["quantity"]
            # total_labors = 0.0
            # for item in labors:
            #     self.cursor.execute("SELECT price_per_hour FROM labors WHERE id=%s", (item["labor_id"],))
            #     row = self.cursor.fetchone()
            #     if row:
            #         price_h = row[0]
            #         total_labors += price_h * item["quantity"] * hours
            # total_geral = total_drinks + total_labors
            # 
            # self.cursor.execute("UPDATE budgets SET total_drinks=%s, total_labors=%s, total_geral=%s WHERE id=%s",
            #             (total_drinks, total_labors, total_geral, budget_id))

            # 5) Commit final
            self.db.commit()
            return budget_id
        except Exception as e:
            self.db.rollback()
            # opcional: log do erro
            print(f"[Database.create_budget] erro: {e}")
            return None
        
    def delete_budget(self, user_id: int, budget_id: int) -> bool:
        """
        Tenta deletar o budget com given budget_id que pertença a este user_id.
        Retorna True se excluiu (rowcount > 0), False caso não exista ou erro.
        """
        try:
            # DELETE com WHERE user_id = %s AND budget_id = %s garante que só usuário dono pode excluir
            delete_sql = f"DELETE FROM {SCHEMA}.budget WHERE budget_id = %s AND user_id = %s;"
            self.cursor.execute(delete_sql, (budget_id, user_id))
            if self.cursor.rowcount == 0:
                # Nenhum orçamento encontrado para esse user_id e budget_id
                self.db.rollback()
                return False
            # Se chegou aqui, rowcount > 0, e as FKs com ON DELETE CASCADE removem drink_on_budget e labor_on_budget automaticamente
            self.db.commit()
            return True
        except Exception as e:
            self.db.rollback()
            print(f"[Database.delete_budget] erro: {e}")
            return False