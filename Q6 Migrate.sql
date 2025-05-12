-- 1️⃣ Migrate Films (from intermediary 'films' to normalized 'films')
INSERT INTO films (title, episode_id, opening_crawl, director, producer, release_date, url)
SELECT DISTINCT title, episode_id, opening_crawl, director, producer, release_date, url
FROM films
ON CONFLICT (url) DO UPDATE SET
    title = EXCLUDED.title,
    episode_id = EXCLUDED.episode_id,
    opening_crawl = EXCLUDED.opening_crawl,
    director = EXCLUDED.director,
    producer = EXCLUDED.producer,
    release_date = EXCLUDED.release_date;


-- 2️⃣ Migrate Planets
INSERT INTO planets (
    name, rotation_period, orbital_period, diameter, climate,
    gravity, terrain, surface_water, population, url
)
SELECT DISTINCT
    name,
    CASE WHEN rotation_period::TEXT ~ '^\d+$' THEN rotation_period::INT ELSE NULL END,
    CASE WHEN orbital_period::TEXT ~ '^\d+$' THEN orbital_period::INT ELSE NULL END,
    CASE WHEN diameter::TEXT ~ '^\d+$' THEN diameter::INT ELSE NULL END,
    climate,
    gravity,
    terrain,
    surface_water,
    CASE WHEN population::TEXT ~ '^\d+$' THEN population::BIGINT ELSE NULL END,
    url
FROM planets
ON CONFLICT (url) DO UPDATE SET
    rotation_period = EXCLUDED.rotation_period,
    orbital_period = EXCLUDED.orbital_period,
    diameter = EXCLUDED.diameter,
    climate = EXCLUDED.climate,
    gravity = EXCLUDED.gravity,
    terrain = EXCLUDED.terrain,
    surface_water = EXCLUDED.surface_water,
    population = EXCLUDED.population;



-- 3️⃣ Migrate People
INSERT INTO people (name, height, mass, hair_color, skin_color, eye_color, birth_year, gender, homeworld, url)
SELECT DISTINCT name, height, mass, hair_color, skin_color, eye_color, birth_year, gender, homeworld, url
FROM people
ON CONFLICT (url) DO UPDATE SET
    height = EXCLUDED.height,
    mass = EXCLUDED.mass,
    hair_color = EXCLUDED.hair_color,
    skin_color = EXCLUDED.skin_color,
    eye_color = EXCLUDED.eye_color,
    birth_year = EXCLUDED.birth_year,
    gender = EXCLUDED.gender,
    homeworld = EXCLUDED.homeworld;

-- 4️⃣ Migrate Species
INSERT INTO species (
    name, classification, designation, average_height,
    skin_colors, hair_colors, eye_colors, average_lifespan,
    homeworld_url, language, url
)
SELECT DISTINCT
    name,
    classification,
    designation,
    average_height,
    skin_colors,
    hair_colors,
    eye_colors,
    average_lifespan,
    homeworld_url,  -- ✅ using the actual column name now
    language,
    url
FROM species
ON CONFLICT (url) DO UPDATE SET
    classification = EXCLUDED.classification,
    designation = EXCLUDED.designation,
    average_height = EXCLUDED.average_height,
    skin_colors = EXCLUDED.skin_colors,
    hair_colors = EXCLUDED.hair_colors,
    eye_colors = EXCLUDED.eye_colors,
    average_lifespan = EXCLUDED.average_lifespan,
    homeworld_url = EXCLUDED.homeworld_url,
    language = EXCLUDED.language;


-- 5️⃣ Migrate Vehicles
INSERT INTO vehicles (name, model, manufacturer, cost_in_credits, length, crew, passengers, max_atmosphering_speed, cargo_capacity, consumables, vehicle_class, url)
SELECT DISTINCT name, model, manufacturer, cost_in_credits, length, crew, passengers, max_atmosphering_speed, cargo_capacity, consumables, vehicle_class, url
FROM vehicles
ON CONFLICT (url) DO UPDATE SET
    model = EXCLUDED.model,
    manufacturer = EXCLUDED.manufacturer,
    cost_in_credits = EXCLUDED.cost_in_credits,
    length = EXCLUDED.length,
    crew = EXCLUDED.crew,
    passengers = EXCLUDED.passengers,
    max_atmosphering_speed = EXCLUDED.max_atmosphering_speed,
    cargo_capacity = EXCLUDED.cargo_capacity,
    consumables = EXCLUDED.consumables,
    vehicle_class = EXCLUDED.vehicle_class;

-- 6️⃣ Migrate Starships
INSERT INTO starships (name, model, manufacturer, cost_in_credits, length, crew, passengers, max_atmosphering_speed, hyperdrive_rating, MGLT, cargo_capacity, consumables, starship_class, url)
SELECT DISTINCT name, model, manufacturer, cost_in_credits, length, crew, passengers, max_atmosphering_speed, hyperdrive_rating, MGLT, cargo_capacity, consumables, starship_class, url
FROM starships
ON CONFLICT (url) DO UPDATE SET
    model = EXCLUDED.model,
    manufacturer = EXCLUDED.manufacturer,
    cost_in_credits = EXCLUDED.cost_in_credits,
    length = EXCLUDED.length,
    crew = EXCLUDED.crew,
    passengers = EXCLUDED.passengers,
    max_atmosphering_speed = EXCLUDED.max_atmosphering_speed,
    hyperdrive_rating = EXCLUDED.hyperdrive_rating,
    MGLT = EXCLUDED.MGLT,
    cargo_capacity = EXCLUDED.cargo_capacity,
    consumables = EXCLUDED.consumables,
    starship_class = EXCLUDED.starship_class;


-- 7️⃣ Migrate Rating Providers
INSERT INTO rating_providers (source)
SELECT DISTINCT source FROM omdb_ratings
ON CONFLICT (source) DO NOTHING;

-- 8️⃣ Migrate Ratings
INSERT INTO ratings (imdb_id, provider_id, rating, movie_title, year)
SELECT o.imdb_id, rp.id, o.rating, o.title, o.year
FROM omdb_ratings o
JOIN rating_providers rp ON o.source = rp.source
ON CONFLICT (imdb_id, provider_id) 
DO UPDATE SET 
    rating = EXCLUDED.rating,
    movie_title = EXCLUDED.movie_title,
    year = EXCLUDED.year;
