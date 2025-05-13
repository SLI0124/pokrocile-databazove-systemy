import duckdb

def common_word_count(a, b):
    if a is None or b is None:
        return 0
    return len(set(a.lower().split()) & set(b.lower().split()))

def connect_to_database(db_name):
    con = duckdb.connect(db_name)
    print("Databáze byla úspěšně připojena.")
    return con

def register_udf(con):
    con.create_function('common_word_count', common_word_count, return_type=duckdb.typing.INTEGER)
    print("UDF byla úspěšně zaregistrována.")

def load_data(con):
    con.execute("""
        CREATE OR REPLACE TABLE UsedCar AS 
        SELECT * FROM read_csv_auto('csv/used_cars_cleaned.csv')
    """)
    print("Tabulka UsedCar byla úspěšně vytvořena.")

    con.execute("""
        CREATE OR REPLACE TABLE Car AS 
        SELECT * FROM read_csv_auto('csv/CARS_1.csv')
    """)
    print("Tabulka Car byla úspěšně vytvořena.")

def join_tables(con):
    con.execute("""
        CREATE OR REPLACE TABLE UsedCar_joined AS
        SELECT 
            u.*, 
            c.* EXCLUDE (car_name),
            common_word_count(u.car_name, c.car_name) AS common_words
        FROM UsedCar u
        JOIN Car c
            ON common_word_count(u.car_name, c.car_name) > 2
    """)
    print("Tabulka UsedCar_joined byla úspěšně vytvořena.")

def validate_join(con):
    usedcar_count = con.sql("SELECT COUNT(*) FROM UsedCar").fetchone()[0]
    car_count = con.sql("SELECT COUNT(*) FROM Car").fetchone()[0]
    joined_count = con.sql("SELECT COUNT(*) FROM UsedCar_joined").fetchone()[0]
    print(f"Počet záznamů v UsedCar: {usedcar_count}")
    print(f"Počet záznamů v Car: {car_count}")
    print(f"Počet záznamů v UsedCar_joined: {joined_count}")

    missing_usedcar_count = con.sql("""
        SELECT COUNT(*) 
        FROM UsedCar 
        WHERE rowid NOT IN (SELECT DISTINCT rowid FROM UsedCar_joined)
    """).fetchone()[0]
    print(f"Počet záznamů z UsedCar, které chybí ve spojení: {missing_usedcar_count}")

def create_best_match_table(con):
    con.execute("""
        CREATE OR REPLACE TABLE UsedCar_best_match AS
        SELECT DISTINCT ON (u.rowid) 
            u.*, 
            c.* EXCLUDE (car_name),
            common_word_count(u.car_name, c.car_name) AS common_words
        FROM UsedCar u
        LEFT JOIN Car c
            ON common_word_count(u.car_name, c.car_name) > 2
        ORDER BY u.rowid, common_word_count(u.car_name, c.car_name) DESC
    """)
    print("Tabulka UsedCar_best_match byla úspěšně vytvořena.")

def calculate_average_prices(con):
    result = con.sql("""
        SELECT city, AVG(price_numeric) AS avg_price
        FROM UsedCar_best_match
        GROUP BY city
        ORDER BY avg_price DESC
    """).fetchall()
    print("\nPrůměrné ceny v městech:")
    for city, avg_price in result:
        print(f"{city}: {avg_price}")

def find_most_popular_models(con):
    result = con.sql("""
        SELECT c.car_name, COUNT(*) AS ad_count
        FROM UsedCar_best_match u
        JOIN Car c ON common_word_count(u.car_name, c.car_name) > 2
        GROUP BY c.car_name
        ORDER BY ad_count DESC
        LIMIT 20
    """).fetchall()
    print("\nNejoblíbenější modely aut:")
    for car_name, ad_count in result:
        print(f"{car_name}: {ad_count}")

def main():
    con = connect_to_database('car_database.db')
    register_udf(con)
    load_data(con)
    join_tables(con)
    validate_join(con)
    create_best_match_table(con)
    calculate_average_prices(con)
    find_most_popular_models(con)
    con.close()

if __name__ == "__main__":
    main()
