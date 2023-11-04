USE CovidPortfolioProject;

-- Query 1
--CovidDeaths data exploration
SELECT TOP 5 *
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date;

-- Query 2
-- Change data type of total_death column
-- instead of using cast repeatedly
ALTER TABLE CovidDeaths
ALTER COLUMN total_deaths FLOAT;

-- Query 3
-- Change data type of new_vaccinations column
-- instead of using cast repeatedly
ALTER TABLE CovidVaccinations
ALTER COLUMN new_vaccinations FLOAT;

-- Query 4
-- Let's see the data that would be interacting with often
SELECT
    location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date DESC;

-- Query 5
-- Death rate
-- Shows the likelihood of dying if you contract covid in your country at a particular date
SELECT
    location,
    date,
    total_cases,
    total_deaths,
    ROUND(((total_deaths/total_cases)*100),2) AS death_rate
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date DESC;

-- Query 6
-- Present likelihood of dying if you contract covid in your country (present death rate)
SELECT
    location,
    MAX(total_cases) AS present_total_cases,
    MAX(total_deaths) AS present_total_deaths,
    ROUND((MAX(total_deaths)/MAX(total_cases)*100),5) AS present_death_rate
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY present_death_rate DESC;

-- Query 7
-- Examine death rate in Nigeria
SELECT
    location,
    date,
    total_cases,
    total_deaths,
    ROUND(((total_deaths/total_cases)*100),2) AS death_rate
FROM CovidDeaths
WHERE location = 'Nigeria'
ORDER BY date DESC;

-- Query 8
-- Present percentage of population killed by COVID
SELECT
    location,
    population,
    MAX(total_deaths) AS present_total_deaths,
    ROUND((MAX(total_deaths)/population)*100,5) AS population_death_percentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY population_death_percentage DESC;

-- Query 9
-- Infection rate
-- Shows what percentage of the population has had COVID (including recovered, dead, and still infected)
SELECT
    location,
    date,
    total_cases,
    total_deaths,
    population,
    ROUND((total_cases/population)*100,3) AS infection_rate
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date DESC;

-- Query 10
-- Examine infection rate in Nigeria
SELECT
    location,
	date,
	total_cases,
    total_deaths,
    population,
    ROUND((total_cases/population)*100,3) AS infection_rate
FROM CovidDeaths
WHERE location = 'Nigeria'
ORDER BY date DESC;

-- Query 11
-- Examining countries by the present infection rate
SELECT
    location,
    population,
    MAX(total_cases) AS latest_total_cases,
    ROUND((MAX(total_cases)/population),5) AS present_infection_rate
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY present_infection_rate DESC;

-- Query 12
-- Exploring data on a continent basis
-- Examining continent by present death count
SELECT
    location,
    population,
    MAX(total_deaths) AS latest_total_deaths
FROM CovidDeaths
WHERE continent IS NULL
    AND location NOT IN ('World', 'international')
GROUP BY location, population
ORDER BY latest_total_deaths DESC;

-- Query 13
-- Examining continents by the present death rate
SELECT
    location,
    MAX(population) AS population,
    MAX(total_cases) AS present_total_cases,
    MAX(total_deaths) AS present_total_deaths,
    ROUND((MAX(total_deaths)/MAX(total_cases)*100),5) AS present_death_rate
FROM CovidDeaths
WHERE continent IS NULL
    AND location NOT IN ('World', 'international')
GROUP BY location
ORDER BY present_death_rate DESC;

-- Query 14
-- GLOBAL NUMBERS
-- Global death rate
SELECT
    SUM(new_cases) AS present_total_cases,
    SUM(CAST(new_deaths AS FLOAT)) AS present_total_deaths,
    (ROUND((SUM(CAST(new_deaths AS FLOAT))/SUM(new_cases))*100,3)) AS present_death_rate
FROM CovidDeaths
WHERE continent IS NOT NULL;

-- Query 15
-- (Global death rate using 'total' fields and subquery)
SELECT
    date,
    SUM(total_cases) AS total_cases,
    SUM(total_deaths) AS total_deaths,
    ROUND(SUM(total_deaths)/SUM(total_cases)*100,4) AS Deathrate
FROM CovidDeaths
WHERE continent IS NOT NULL
    AND date = (SELECT MAX(date) FROM CovidDeaths)
GROUP BY date;

-- Query 16
-- Examining COVID vaccination
-- Exploring COVID vaccination data
SELECT *
FROM CovidVaccinations
WHERE continent IS NOT NULL
ORDER BY location, date;

-- Query 17
SELECT SUM(CAST(new_tests AS INT))
FROM CovidVaccinations
WHERE continent IS NOT NULL
    AND location = 'Australia';

-- Query 18
SELECT MAX(population)
FROM CovidDeaths
WHERE continent IS NOT NULL
    AND location = 'Australia';

-- Query 19
-- Examining the total vaccination on a country basis
SELECT
    death.location,
    death.date,
    death.population,
    vaccine.new_vaccinations,
    SUM(vaccine.new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS rolling_people_vaccination,
    ROUND((SUM(vaccine.new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.location, death.date)/death.population)*100,5) AS percentage_population_vaccinated
FROM CovidDeaths death
JOIN CovidVaccinations vaccine
    ON death.location = vaccine.location
    AND death.date = vaccine.date
WHERE death.continent IS NOT NULL
ORDER BY 1,2;

-- Query 20
-- Present percentage of population vaccinated by country using CTE and new vaccinations field (window function)
WITH vac AS (
    SELECT
        death.location,
        death.date,
        death.population,
        vaccine.new_vaccinations,
        SUM(vaccine.new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS rolling_people_vaccination
    FROM CovidDeaths death
    JOIN CovidVaccinations vaccine
        ON death.location = vaccine.location
        AND death.date = vaccine.date
    WHERE death.continent IS NOT NULL
)
SELECT
    location,
    MAX(date) AS date,
    population,
    MAX(rolling_people_vaccination) AS present_number_vaccinated,
    ROUND((MAX(rolling_people_vaccination)/population)*100,4) AS vaccination_rate
FROM vac
GROUP BY location, population
ORDER BY location;

-- Query 21
-- Present percentage of population tested by country using temp tables
DROP TABLE IF EXISTS #PopulationTested;
CREATE TABLE #PopulationTested (
    location NVARCHAR(255),
    date DATETIME,
    population BIGINT,
    new_tests INT,
   
