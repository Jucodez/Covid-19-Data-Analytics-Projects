# Covid 19 Data Analytics Project


## Introduction

This data analytics project aims to gain more insight into the COVID-19 pandemic from inception till the present date (2021-04-30). Using Covid 19 data from [ourworldindata.org](https://ourworldindata.org/coronavirus), various questions about the pandemic would be answered using SQL to query the data.

##  ETL (Extract Transform and Load)

CSV files on the pandemic were downloaded from [ourworldindata.org](https://ourworldindata.org/coronavirus). These files were converted to Microsoft Excel files.

Then MS Server Integration Services (SSIS) was used to load the data from the Microsoft Excel files to a Microsoft SQL Server database.

This database was then queried using the SQL queries below.

## Data Analysis

1. What is the possibility of dying from COVID-19 in your country (death rate)?

            SELECT
                  location,
                  date,
                  total_cases,
                  total_deaths,
                  ROUND(((total_deaths/total_cases)*100),2) AS [death_rate(%)]
            FROM CovidDeaths
            WHERE continent IS NOT NULL
            ORDER BY location, date DESC;

![death rate](https://github.com/Jucodez/Covid-19-Data-Analytics-Projects/assets/102746691/aad19ab5-d62e-4768-92c8-5fa9dd366d9b)

2. What is the present likelihood of dying if you contract COVID-19 in your country (present death rate)?

            SELECT
                  location,
                  MAX(total_cases) AS present_total_cases,
                  MAX(total_deaths) AS present_total_deaths,
                  ROUND((MAX(total_deaths)/MAX(total_cases)*100),5) AS [present_death_rate(%)]
            FROM CovidDeaths
            WHERE continent IS NOT NULL
            GROUP BY location
            ORDER BY [present_death_rate(%)] DESC;

![Present death rate](https://github.com/Jucodez/Covid-19-Data-Analytics-Projects/assets/102746691/3f7a431e-551b-4c8b-a116-1a7cf161f3a6)

3. What is the death rate in Nigeria for all date entries available?

            SELECT
                  location,
                  date,
                  total_cases,
                  total_deaths,
                  ROUND(((total_deaths/total_cases)*100),5) AS [death_rate(%)]
            FROM CovidDeaths
            WHERE location = 'Nigeria'
            ORDER BY date DESC;

![nigeria death rate](https://github.com/Jucodez/Covid-19-Data-Analytics-Projects/assets/102746691/1de71815-d190-46ca-a2e2-c3ae59f65927)

4. For each country, what percentage of the population has been killed by the pandemic?

            SELECT
                  location,
                  population,
                  MAX(total_deaths) AS present_total_deaths,
                  ROUND((MAX(total_deaths)/population)*100,5) AS [population_death_percentage(%)]
            FROM CovidDeaths
            WHERE continent IS NOT NULL
            GROUP BY location, population
            ORDER BY [population_death_percentage(%)] DESC;


![percentage death](https://github.com/Jucodez/Covid-19-Data-Analytics-Projects/assets/102746691/e670398c-cc95-4685-a2f3-0e18330ffed5)


5. For each country, what percentage of the population has had COVID (including recovered, dead, and still infected) (infection rate) at various times?

            SELECT
                  location,
                  date,
                  total_cases,
                  total_deaths,
                  population,
                  ROUND((total_cases/population)*100,5) AS [infection_rate(%)]
            FROM CovidDeaths
            WHERE continent IS NOT NULL
            ORDER BY location, date DESC;

![infection rate](https://github.com/Jucodez/Covid-19-Data-Analytics-Projects/assets/102746691/3d11e504-70d7-4683-9226-2a14c4ff0ce5)


6. What is the infection rate in Nigeria at various times?

            SELECT
                  location,
                  date,
                  total_cases,
                  total_deaths,
                  population,
                  ROUND((total_cases/population)*100,3) AS [infection_rate(%)]
            FROM CovidDeaths
            WHERE location = 'Nigeria'
            ORDER BY date DESC;

![Nigeria infection rate](https://github.com/Jucodez/Covid-19-Data-Analytics-Projects/assets/102746691/22062ba5-f56d-4f0a-b1d3-d9507525cbc1)

7. What is the present infection rate for each country?

            SELECT
                  location,
                  population,
                  MAX(total_cases) AS latest_total_cases,
                  ROUND((MAX(total_cases)/population),5) AS [present_infection_rate(%)]
            FROM CovidDeaths
            WHERE continent IS NOT NULL
            GROUP BY location, population
            ORDER BY [present_infection_rate(%)] DESC;

![present infection rate](https://github.com/Jucodez/Covid-19-Data-Analytics-Projects/assets/102746691/be257232-cff5-404f-922c-05c6f89cf65f)

8. What is the present death count for each continent?

            SELECT
                  location,
                  population,
                  MAX(total_deaths) AS latest_total_deaths
            FROM CovidDeaths
            WHERE continent IS NULL
            AND location NOT IN ('World', 'international')
            GROUP BY location, population
            ORDER BY latest_total_deaths DESC;

![continent death count](https://github.com/Jucodez/Covid-19-Data-Analytics-Projects/assets/102746691/c4a7fec6-e6a2-4a39-bf79-fea84f18c80a)


9. What is the present death rate for each continent?

            SELECT
                  location,
                  MAX(population) AS population,
                  MAX(total_cases) AS present_total_cases,
                  MAX(total_deaths) AS present_total_deaths,
                  ROUND((MAX(total_deaths)/MAX(total_cases)*100),5) AS [present_death_rate(%)]
            FROM CovidDeaths
            WHERE continent IS NULL
            AND location NOT IN ('World', 'international')
            GROUP BY location
            ORDER BY [present_death_rate(%)] DESC;

![continent present death rate ](https://github.com/Jucodez/Covid-19-Data-Analytics-Projects/assets/102746691/e32226cb-092a-40e4-9b55-389277e37efa)

10. What is the present global death rate?

            SELECT
                  SUM(new_cases) AS present_total_cases,
                  SUM(CAST(new_deaths AS FLOAT)) AS present_total_deaths,
                  (ROUND((SUM(CAST(new_deaths AS FLOAT))/SUM(new_cases))*100,3)) AS [present_death_rate(%)]
            FROM CovidDeaths
            WHERE continent IS NOT NULL;

![global present death rate](https://github.com/Jucodez/Covid-19-Data-Analytics-Projects/assets/102746691/db6128a5-045c-49ce-84b3-02f4ba34fa70)


11. For each day, examine the total vaccinations in each country.

            SELECT
                  death.location,
                  death.date,
                  death.population,
                  vaccine.new_vaccinations,
                  SUM(vaccine.new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS rolling_people_vaccination,
                  ROUND((SUM(vaccine.new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.location, death.date)/death.population)*100,5) AS [percentage_population_vaccinated(%)]
            FROM CovidDeaths death
            JOIN CovidVaccinations vaccine
                  ON death.location = vaccine.location
                  AND death.date = vaccine.date
            WHERE death.continent IS NOT NULL
            ORDER BY 2 desc;

![vaccination rate](https://github.com/Jucodez/Covid-19-Data-Analytics-Projects/assets/102746691/eaad5009-5132-4821-895c-5c5b64257d8d)


Another approach.

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


12. What portion of the population tested for each country (using temp tables)?

            DROP TABLE IF EXISTS #PopulationTested;
            CREATE TABLE #PopulationTested (
                  location NVARCHAR(255),
                  date DATETIME,
                  population BIGINT,
                  new_tests INT,
                  total_people_tested INT
                  );

            INSERT INTO #PopulationTested
            SELECT
                  death.location,
                  death.date,
                  death.population,
                  vaccine.new_tests,
                  vaccine.total_tests
            FROM CovidDeaths death
            JOIN CovidVaccinations vaccine
                  ON death.location = vaccine.location
                  AND death.date = vaccine.date
            WHERE death.continent IS NOT NULL;

            SELECT
                  location,
                  MAX(date) AS date,
                  population,
                  MAX(total_people_tested) AS present_number_tested,
                  ROUND((MAX(CAST(total_people_tested AS FLOAT))/population)*100,4) AS [testing_rate(%)]
            FROM #PopulationTested
            GROUP BY location, population
            ORDER BY location;

![testing rate](https://github.com/Jucodez/Covid-19-Data-Analytics-Projects/assets/102746691/7bb67bca-6caf-47bd-acbb-ff4cb076c2ea)

## Next Steps
Data visualization can be taken as a next step after this data analysis project. This would help even better understand the data. To achieve this, the SQL database can be connected to a business intelligence tool. However, a view can be used to extract only a selected portion of the data for visualization.

            CREATE OR ALTER VIEW populationpercentagevaccinated
            AS
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
            WHERE death.continent IS NOT NULL;
            
            SELECT * 
            FROM populationpercentagevaccinated
            ORDER BY date desc;

Also, the dataset can be updated, and the queries would still be able to extract the desired insights.

## Conclusion 

Overall, this data analysis project helps us gain better insight into the COVID-19 pandemic on a global and national scale.
