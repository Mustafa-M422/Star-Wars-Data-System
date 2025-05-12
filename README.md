# Star-Wars-Data-System

## How to Run

To run the application, use the following command in your terminal:

**_python swapi_data_import.py_**

## Expected Output

Upon running the script, you will see output messages indicating the progress and results of the data fetching and insertion process.

- The script connects to the PostgreSQL database.
- It fetches data from the SWAPI API for:
  - Films
  - People
  - Planets
  - Species
  - Vehicles
  - Starships
- After fetching each dataset, the script inserts the data into the corresponding tables in the database.
- The script then processes data from TMDB and inserts the relevant Star Wars movie data.
- Finally, the script fetches and stores OMDB ratings for Star Wars movies.


To run the application, use the following command in your terminal:

This project implements a local PostgreSQL database of Star Wars movies by aggregating data from multiple APIs and datasets. The system is divided into three phases: data collection, data normalization and migration, and advanced SQL querying.

## Q1 – DDL for Intermediary Tables

Implemented in: **`Q1 DDL.sql`**  
Creates intermediary tables to store raw data from the Star Wars API. Tables include:
- films
- people
- planets
- species
- vehicles
- starships

Each table includes a unique `url` column to prevent duplicate entries and supports flexible data formats.

## Q2 – Star Wars API Data Collection Program

Implemented in: **`swapi_data_import.py`**  
Uses Python and the `psycopg2` library to connect to PostgreSQL and retrieve data from the Star Wars API. The script:
- Fetches JSON data from the API
- Maps fields to intermediary database columns
- Converts invalid or "unknown" values to NULL
- Inserts data with conflict handling

## Q3 – OMDB API Data Integration

Also implemented in: **`swapi_data_import.py`**  
Creates the `omdb_ratings` table to store data from the OMDB API. The script:
- Fetches ratings and IMDb IDs for each movie
- Inserts ratings per provider (e.g., IMDb, Rotten Tomatoes)
- Defines constraints for uniqueness using `(imdb_id, source)`
- Prepares normalized tables: `rating_providers` and `ratings`

## Q4 – TMDB Dataset Integration (CSV)

Implemented in: **`process_tmdb.py`**  
Uses the TMDB dataset downloaded from Kaggle. The script:
- Loads the CSV with pandas
- Filters for Star Wars titles
- Extracts and saves relevant fields (title, imdb_id, popularity)
- Inserts into the `tmdb_movies` table with conflict resolution

## Q5 – Normalized Schema

Implemented in: **`Q5 Normalized Schema.sql`**  
Designs a normalized database schema that maintains relationships and supports constraints. All primary keys use `_id` suffixes, and foreign keys are introduced where appropriate. A separate `keywords` table is linked to `films`.

## Q6 – Data Migration

Implemented in: **`Q6 Migrate.sql`**  
Migrates data from intermediary tables to the normalized schema. This includes:
- Type conversions (e.g., string to integer)
- Conflict handling using `ON CONFLICT`
- Referential integrity across entities
- Migrating ratings and linking them to rating providers

## Q7 – Advanced SQL Queries

Implemented in: **`Q7 Full SQL Query Set.sql`**  
Includes the following queries:
1. Count of movies, people, and planets (one query)
2. Top 3 movies by keyword count
3. Most frequent keyword(s) and their associated movies
4. Highest rated movies per provider
5. Batch update to round all ratings

Dummy keyword data is included for testing purposes.

## Q8 ERD 

The Entity Relationship Diagram (ERD) was generated using pgAdmin's reverse engineering tool. It visualizes the normalized schema used for the Star Wars database, showing key entities such as **films**, **_people_**, **_planets_**, **_vehicles_**, **_starships_**, and **_species_**, as well as supporting data from OMDB and TMDB. Relationships between tables are established using foreign keys, including mapping tables like **_film_species_**, **_film_starships_**, and **_film_vehicles_** to handle many-to-many relationships. Additional tables for **_ratings_**, **_rating_providers_**, and **_keywords_** ensure data from external APIs is properly integrated and queryable.

![Q8 ERD](https://github.com/user-attachments/assets/a42ef531-7607-4f42-afd7-71fe6fe31a3e)

-------------------------------------------------------------------------------
## Q9 DML

All DML queries are included in **`Q9 DML_inserts.sql`**. Insert conflicts are safely handled using `ON CONFLICT DO NOTHING`.

****
