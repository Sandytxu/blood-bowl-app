-- Extensión para UUID (Claves primarias)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ===========================================
-- Modulo 1: Usuarios (Identidad y seguridad)
-- ===========================================

CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR UNIQUE NOT NULL,
    email VARCHAR UNIQUE NOT NULL,
    password_hash VARCHAR NOT NULL,
    naf_number VARCHAR,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===========================================
-- Módulo 2: Reglas oficiales (LA BIBLIA)
-- ===========================================

CREATE TABLE IF NOT EXISTS rules_versions (
    id VARCHAR PRIMARY KEY,
    name VARCHAR NOT NULL,
    is_active BOOLEAN DEFAULT true
);

CREATE TABLE IF NOT EXISTS rules_skills (
    id VARCHAR PRIMARY KEY,
    version_id VARCHAR REFERENCES rules_versions(id),
    name VARCHAR NOT NULL,
    category VARCHAR, -- General, Mutación, Agilidad, Fuerza, Pase, Triquinuela
    description TEXT
);

CREATE TABLE IF NOT EXISTS rules_traits (
    id VARCHAR PRIMARY KEY,
    version_id VARCHAR REFERENCES rules_versions(id),
    name VARCHAR NOT NULL,
    description TEXT
);

CREATE TABLE IF NOT EXISTS rules_alliances (
    id VARCHAR PRIMARY KEY,
    version_id VARCHAR REFERENCES rules_versions(id),
    name VARCHAR NOT NULL
);

CREATE TABLE IF NOT EXISTS rules_races (
    id VARCHAR PRIMARY KEY,
    version_id VARCHAR REFERENCES rules_versions(id),
    name VARCHAR NOT NULL,
    tier INT NOT NULL,
    reroll_cost INT NOT NULL,
    apothecary_cost INT DEFAULT -1 -- -1 significa que no pueden contratar apotecario
);

CREATE TABLE IF NOT EXISTS rules_race_alliances (
    race_id VARCHAR REFERENCES rules_races(id),
    alliance_id VARCHAR REFERENCES rules_alliances(id),
    PRIMARY KEY (race_id, alliance_id)
);

CREATE TABLE IF NOT EXISTS rules_positionals (
    id VARCHAR PRIMARY KEY,
    race_id VARCHAR REFERENCES rules_races(id),
    name VARCHAR NOT NULL,
    qty_limit INT NOT NULL,
    cost INT NOT NULL,
    ma INT NOT NULL,
    st INT NOT NULL,
    ag VARCHAR NOT NULL,
    pa VARCHAR,
    av VARCHAR NOT NULL,
    primary_access JSONB,
    secondary_access JSONB,
    initial_skills_ids JSONB
);

CREATE TABLE IF NOT EXISTS rules_star_players (
    id VARCHAR PRIMARY KEY,
    version_id VARCHAR REFERENCES rules_versions(id),
    name VARCHAR NOT NULL,
    cost INT NOT NULL,
    hiring_fee INT NOT NULL,
    ma INT NOT NULL,
    st INT NOT NULL,
    ag VARCHAR NOT NULL,
    pa VARCHAR,
    av VARCHAR NOT NULL,
    skills_and_traits_ids JSONB,
    special_rule TEXT
);

CREATE TABLE IF NOT EXISTS rules_star_player_alliances (
    star_player_id VARCHAR REFERENCES rules_star_players(id),
    alliance_id VARCHAR REFERENCES rules_alliances(id),
    PRIMARY KEY (star_player_id, alliance_id)
);

-- ===========================================
-- Módulo 3: Equipos y jugadores 
-- ===========================================

CREATE TABLE IF NOT EXISTS teams (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    rules_version_id VARCHAR REFERENCES rules_versions(id),
    race_id VARCHAR REFERENCES rules_races(id),
    name VARCHAR NOT NULL,
    treasury INT DEFAULT 1000000,
    rerolls INT DEFAULT 0,
    fans INT DEFAULT 0,
    assistant_coaches INT DEFAULT 0,
    cheerleaders INT DEFAULT 0,
    apothecary BOOLEAN DEFAULT false,
    status VARCHAR DEFAULT 'DRAFT' -- DRAFT / READY / RETIRED
);

CREATE TABLE IF NOT EXISTS players (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    team_id UUID REFERENCES teams(id),
    positional_id VARCHAR REFERENCES rules_positionals(id),
    name VARCHAR NOT NULL,
    jersey_number INT NOT NULL,
    spp INT DEFAULT 0,
    cost INT NOT NULL,
    status VARCHAR DEFAULT 'ACTIVE' -- ACTIVE / DEAD / MISSING_NEXT_GAME
);

CREATE TABLE IF NOT EXISTS player_acquired_skills (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    player_id UUID REFERENCES players(id),
    skill_id VARCHAR REFERENCES rules_skills(id),
    cost_in_tv INT NOT NULL
);

CREATE TABLE IF NOT EXISTS player_injuries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    player_id UUID REFERENCES players(id),
    injury_type VARCHAR NOT NULL
);

-- ===========================================
-- Módulo 4: Ligas y actas
-- ===========================================
CREATE TABLE IF NOT EXISTS leagues (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR NOT NULL,
    commissioner_id UUID REFERENCES users(id),
    rules_version_id VARCHAR REFERENCES rules_versions(id),
    status VARCHAR DEFAULT 'UPCOMING' -- UPCOMING / ONGOING / COMPLETED / DRAFT
);

CREATE TABLE IF NOT EXISTS league_members (
    user_id UUID REFERENCES users(id),
    league_id UUID REFERENCES leagues(id),
    is_commissioner BOOLEAN DEFAULT false,
    is_coach BOOLEAN DEFAULT true,
    PRIMARY KEY (user_id, league_id)
);

CREATE TABLE IF NOT EXISTS league_enrollments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    league_id UUID REFERENCES leagues(id),
    team_id UUID REFERENCES teams(id),
    matches_played INT DEFAULT 0,
    wins INT DEFAULT 0,
    draws INT DEFAULT 0,
    losses INT DEFAULT 0,
    td_for INT DEFAULT 0,
    td_against INT DEFAULT 0,
    cas_for INT DEFAULT 0,
    cas_against INT DEFAULT 0,
    passes INT DEFAULT 0,
    interceptions INT DEFAULT 0,
    final_snapshots JSONB, -- Para guardar stats adicionales o eventos importantes
    UNIQUE (league_id, team_id)
);