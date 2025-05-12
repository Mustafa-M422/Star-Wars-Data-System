import pandas as pd
import psycopg2
from swapi_data_import import connect_db  # Import database connection from main script

# File path for TMDB dataset
TMDB_FILE = "tmdb_movies.csv"

# Load and filter TMDB dataset
def load_tmdb_data():
    print(" Loading TMDB dataset...")
    try:
        df = pd.read_csv(TMDB_FILE)

        # Ensure required columns exist
        required_columns = ["title", "popularity", "imdb_id"]
        for col in required_columns:
            if col not in df.columns:
                print(f" Error: Missing column '{col}' in dataset.")
                return None

        # Filter for Star Wars movies
        star_wars_movies = df[df["title"].str.contains("Star Wars", case=False, na=False)][required_columns]

        if star_wars_movies.empty:
            print(" No Star Wars movies found in dataset.")
            return None

        # Save filtered data
        star_wars_movies.to_csv("tmdb_movies.csv", index=False)
        print(" Filtered Star Wars movies saved to 'tmdb_movies.csv'.")
        return star_wars_movies
    except Exception as e:
        print(f" Error loading TMDB data: {e}")
        return None

# Create TMDB table in PostgreSQL
def create_tmdb_table(conn):
    cursor = conn.cursor()
    sql = """
        CREATE TABLE IF NOT EXISTS tmdb_movies (
            id SERIAL PRIMARY KEY,
            title VARCHAR(255) NOT NULL,
            imdb_id VARCHAR(20) UNIQUE NOT NULL,
            popularity FLOAT
        );
    """
    try:
        cursor.execute(sql)
        conn.commit()
        print(" TMDB table created successfully.")
    except Exception as e:
        print(f" Error creating TMDB table: {e}")
    finally:
        cursor.close()

# Insert TMDB data into PostgreSQL
def insert_tmdb_data(conn, movie):
    cursor = conn.cursor()
    sql = """
        INSERT INTO tmdb_movies (title, imdb_id, popularity) 
        VALUES (%s, %s, %s)
        ON CONFLICT (imdb_id) DO UPDATE SET 
            popularity = EXCLUDED.popularity;
    """
    values = (movie["title"], movie["imdb_id"], movie["popularity"])

    try:
        cursor.execute(sql, values)
        conn.commit()
        print(f" Inserted/Updated TMDB data for: {movie['title']}")
    except Exception as e:
        print(f" Error inserting TMDB data: {e}")
    finally:
        cursor.close()

# Main function to process TMDB data
def process_tmdb():
    conn = connect_db()  # Use database connection from main script

    if not conn:
        print(" Database connection failed. Exiting...")
        return

    create_tmdb_table(conn)  # Create table if it doesn't exist

    star_wars_data = load_tmdb_data()
    if star_wars_data is None:
        print(" No data to insert. Exiting...")
        return

    # Insert filtered data into PostgreSQL
    for _, row in star_wars_data.iterrows():
        insert_tmdb_data(conn, row)

    conn.close()
    print(" TMDB Data Processing Completed.")

# Run the function when this script is executed
if __name__ == "__main__":
    process_tmdb()
