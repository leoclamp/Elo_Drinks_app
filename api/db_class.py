import psycopg2

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