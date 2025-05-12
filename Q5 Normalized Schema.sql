-- Films Table
CREATE TABLE films (
    film_id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    episode_id INT NOT NULL,
    opening_crawl TEXT,
    director VARCHAR(255),
    producer VARCHAR(255),
    release_date DATE,
    url VARCHAR(255) UNIQUE NOT NULL
);


-- People Table
CREATE TABLE people (
    person_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    height VARCHAR(10),
    mass VARCHAR(10),
    hair_color VARCHAR(50),
    skin_color VARCHAR(50),
    eye_color VARCHAR(50),
    birth_year VARCHAR(20),
    gender VARCHAR(20),
    homeworld VARCHAR(255),
    url VARCHAR(255) UNIQUE NOT NULL
);

-- Planets Table
CREATE TABLE planets (
    planet_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    rotation_period INT,
    orbital_period INT,
    diameter INT,
    climate VARCHAR(100),
    gravity VARCHAR(50),
    terrain VARCHAR(100),
    surface_water VARCHAR(10),
    population BIGINT,
    url VARCHAR(255) UNIQUE NOT NULL
);

-- Species Table
CREATE TABLE species (
    species_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    classification VARCHAR(50),
    designation VARCHAR(50),
    average_height VARCHAR(10),
    skin_colors VARCHAR(100),
    hair_colors VARCHAR(100),
    eye_colors VARCHAR(100),
    average_lifespan VARCHAR(10),
    homeworld_url VARCHAR(255),
    language VARCHAR(100),
    url VARCHAR(255) UNIQUE NOT NULL
);

-- Vehicles Table
CREATE TABLE vehicles (
    vehicle_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    model VARCHAR(255),
    manufacturer VARCHAR(255),
    cost_in_credits VARCHAR(20),
    length VARCHAR(20),
    crew VARCHAR(10),
    passengers VARCHAR(10),
    max_atmosphering_speed VARCHAR(20),
    cargo_capacity VARCHAR(20),
    consumables VARCHAR(100),
    vehicle_class VARCHAR(100),
    url VARCHAR(255) UNIQUE NOT NULL
);

-- Starships Table
CREATE TABLE starships (
    starship_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    model VARCHAR(255),
    manufacturer VARCHAR(255),
    cost_in_credits VARCHAR(20),
    length VARCHAR(20),
    crew VARCHAR(10),
    passengers VARCHAR(10),
    max_atmosphering_speed VARCHAR(20),
    hyperdrive_rating VARCHAR(20),
    MGLT VARCHAR(20),
    cargo_capacity VARCHAR(20),
    consumables VARCHAR(100),
    starship_class VARCHAR(100),
    url VARCHAR(255) UNIQUE NOT NULL
);

-- OMDB Ratings Table
CREATE TABLE omdb_ratings (
    rating_id SERIAL PRIMARY KEY,
    imdb_id VARCHAR(20) NOT NULL,
    title VARCHAR(255) NOT NULL,
    year INT,
    source VARCHAR(100) NOT NULL,
    rating VARCHAR(20),
    url VARCHAR(255) NOT NULL,
    CONSTRAINT unique_rating UNIQUE (imdb_id, source)
);

CREATE TABLE IF NOT EXISTS rating_providers (
    id SERIAL PRIMARY KEY,
    source VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS ratings (
    id SERIAL PRIMARY KEY,
    imdb_id VARCHAR(20) NOT NULL,
    provider_id INT NOT NULL REFERENCES rating_providers(id),
    rating VARCHAR(20),
    movie_title VARCHAR(255),
    year INT,
    CONSTRAINT unique_rating_per_provider UNIQUE (imdb_id, provider_id)
);

CREATE TABLE IF NOT EXISTS keywords (
    id SERIAL PRIMARY KEY,
    movie_id INT REFERENCES films(film_id),
    keyword VARCHAR(100),
    CONSTRAINT unique_keyword_per_movie UNIQUE (movie_id, keyword)
);
