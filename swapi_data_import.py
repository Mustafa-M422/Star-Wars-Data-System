import requests
import psycopg2
import os

# Database Connection Details
DB_NAME = "starwars"
DB_USER = "postgres"
DB_PASSWORD = "root"  # Replace with your actual PostgreSQL password
DB_HOST = "localhost"
DB_PORT = "5432"

# API Base URL
BASE_URL = "https://swapi.dev/api"

# OMDB API Details
OMDB_API_KEY = "3979b446"
OMDB_BASE_URL = "http://www.omdbapi.com/"

# PostgreSQL Connection Function
def connect_db():
    try:
        conn = psycopg2.connect(
            dbname=DB_NAME,
            user=DB_USER,
            password=DB_PASSWORD,
            host=DB_HOST,
            port=DB_PORT
        )
        print(" Connected to PostgreSQL database.")
        return conn
    except Exception as e:
        print("Error connecting to the database:", e)
        return None

# PostgreSQL Insert Data Function
def insert_data(conn, table, data):
    cursor = conn.cursor()
    columns = ", ".join(data.keys())
    placeholders = ", ".join(["%s"] * len(data))
    update_clause = ", ".join([f"{col} = EXCLUDED.{col}" for col in data.keys()])

    sql = f"""
        INSERT INTO {table} ({columns}) 
        VALUES ({placeholders}) 
        ON CONFLICT (url) DO UPDATE SET {update_clause}
    """
    values = tuple(data.values())

    try:
        cursor.execute(sql, values)
        conn.commit()
        print(f" Inserted data into {table}")
    except Exception as e:
        print(f" Error inserting into {table}: {e}")
    finally:
        cursor.close()

#  Updated: Supports optional int_fields
def fetch_and_store_data(conn, endpoint, table, data_mapping, int_fields=None):
    print(f"📡 Fetching data for {table}...")
    url = f"{BASE_URL}/{endpoint}/"

    if int_fields is None:
        int_fields = []

    while url:
        response = requests.get(url)

        if response.status_code == 200:
            json_data = response.json()

            if "results" not in json_data:
                print(f" Warning: No results found for {table}.")
                break  

            for item in json_data['results']:
                data = {db_field: item.get(api_field, None) for db_field, api_field in data_mapping.items()}

                for field in int_fields:
                    if field in data:
                        value = data[field]
                        data[field] = int(value) if str(value).isdigit() else None

                insert_data(conn, table, data)

            url = json_data.get('next')  
        else:
            print(f" Failed to retrieve data for {table}: {response.status_code}")
            break

# OMDB Ratings Table
def create_omdb_table(conn):
    cursor = conn.cursor()
    sql = """
        CREATE TABLE IF NOT EXISTS omdb_ratings (
            id SERIAL PRIMARY KEY,
            imdb_id VARCHAR(20) NOT NULL,
            title VARCHAR(255) NOT NULL,
            year INT,
            source VARCHAR(100) NOT NULL,
            rating VARCHAR(20),
            url VARCHAR(255) NOT NULL,
            CONSTRAINT unique_rating UNIQUE (imdb_id, source)
        );
    """
    try:
        cursor.execute(sql)
        conn.commit()
        print(" OMDB Ratings table created successfully.")
    except Exception as e:
        print(" Error creating OMDB Ratings table:", e)
    finally:
        cursor.close()

def fetch_omdb_data(movie_title):
    params = {
        "t": movie_title,
        "apikey": OMDB_API_KEY
    }
    
    response = requests.get(OMDB_BASE_URL, params=params)

    if response.status_code == 200:
        data = response.json()
        if data.get("Response") == "True" and "imdbID" in data:
            return {
                "imdb_id": data["imdbID"],
                "title": data["Title"],
                "year": data.get("Year"),
                "ratings": data.get("Ratings", []),
                "url": f"https://www.imdb.com/title/{data['imdbID']}/"
            }
    return None

def insert_omdb_data(conn, movie_data):
    cursor = conn.cursor()
    
    for rating in movie_data["ratings"]:
        source = rating["Source"]
        value = rating["Value"]

        sql = """
            INSERT INTO omdb_ratings (imdb_id, title, year, source, rating, url) 
            VALUES (%s, %s, %s, %s, %s, %s)
            ON CONFLICT (imdb_id, source)
            DO UPDATE SET rating = EXCLUDED.rating, title = EXCLUDED.title;
        """
        values = (movie_data["imdb_id"], movie_data["title"], movie_data["year"], source, value, movie_data["url"])

        try:
            cursor.execute(sql, values)
            conn.commit()
            print(f" Inserted/Updated OMDB data for: {movie_data['title']} ({source}: {value})")
        except Exception as e:
            print(f" Error inserting OMDB data: {e}")

    cursor.close()

def get_star_wars_movies(conn):
    cursor = conn.cursor()
    cursor.execute("SELECT title FROM films;")
    movies = [row[0] for row in cursor.fetchall()]
    cursor.close()
    return movies
    
conn = connect_db()
if __name__ == "__main__":

    if conn:
        try:
            #  SWAPI: Fetch & insert once
            fetch_and_store_data(conn, 'films', 'films', {
                'title': 'title',
                'episode_id': 'episode_id',
                'opening_crawl': 'opening_crawl',
                'director': 'director',
                'producer': 'producer',
                'release_date': 'release_date',
                'url': 'url'
            })

            fetch_and_store_data(conn, 'people', 'people', {
                'name': 'name',
                'height': 'height',
                'mass': 'mass',
                'hair_color': 'hair_color',
                'skin_color': 'skin_color',
                'eye_color': 'eye_color',
                'birth_year': 'birth_year',
                'gender': 'gender',
                'homeworld': 'homeworld',
                'url': 'url'
            })

            fetch_and_store_data(conn, 'planets', 'planets', {
                'name': 'name',
                'rotation_period': 'rotation_period',
                'orbital_period': 'orbital_period',
                'diameter': 'diameter',
                'climate': 'climate',
                'gravity': 'gravity',
                'terrain': 'terrain',
                'surface_water': 'surface_water',
                'population': 'population',
                'url': 'url'
            }, int_fields=["rotation_period", "orbital_period", "diameter", "population"])

            fetch_and_store_data(conn, 'species', 'species', {
                'name': 'name',
                'classification': 'classification',
                'designation': 'designation',
                'average_height': 'average_height',
                'skin_colors': 'skin_colors',
                'hair_colors': 'hair_colors',
                'eye_colors': 'eye_colors',
                'average_lifespan': 'average_lifespan',
                'language': 'language',
                'url': 'url'
            }, int_fields=["average_height", "average_lifespan"])

            fetch_and_store_data(conn, 'vehicles', 'vehicles', {
                'name': 'name',
                'model': 'model',
                'manufacturer': 'manufacturer',
                'cost_in_credits': 'cost_in_credits',
                'length': 'length',
                'crew': 'crew',
                'passengers': 'passengers',
                'max_atmosphering_speed': 'max_atmosphering_speed',
                'cargo_capacity': 'cargo_capacity',
                'consumables': 'consumables',
                'vehicle_class': 'vehicle_class',
                'url': 'url'
            })

            fetch_and_store_data(conn, 'starships', 'starships', {
                'name': 'name',
                'model': 'model',
                'manufacturer': 'manufacturer',
                'cost_in_credits': 'cost_in_credits',
                'length': 'length',
                'crew': 'crew',
                'passengers': 'passengers',
                'max_atmosphering_speed': 'max_atmosphering_speed',
                'hyperdrive_rating': 'hyperdrive_rating',
                'MGLT': 'MGLT',
                'cargo_capacity': 'cargo_capacity',
                'consumables': 'consumables',
                'starship_class': 'starship_class',
                'url': 'url'
            })

            print(" Star Wars API data collection completed.")

            #  Run TMDB Data Processing
            print(" Running TMDB Data Processing...")
            os.system("python process_tmdb.py")
            print(" TMDB Processing Completed.")

            #  Run OMDB Data Processing
            print(" Running OMDB Data Processing...")
            create_omdb_table(conn)
            movies = get_star_wars_movies(conn)

            for title in movies:
                print(f" Fetching OMDB data for: {title}")
                movie_data = fetch_omdb_data(title)

                if movie_data:
                    insert_omdb_data(conn, movie_data)
                else:
                    print(f"No OMDB data found for {title}")

            print(" OMDB Processing Completed.")

        except Exception as e:
            print(f" Error during execution: {e}")
        finally:
            conn.close()
            print(" Database connection closed.")
    else:
        print(" Could not connect to database.")
