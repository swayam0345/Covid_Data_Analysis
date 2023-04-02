-- Selecting data that we will be using.
SELECT
  location,
  date,
  total_cases,
  new_cases,
  total_deaths,
  population
FROM
  `coviddata-382220.Covid.Covid_Deaths`
WHERE continent IS NOT NULL
ORDER BY
  1,
  2;

-- Total Cases Vs Total Deaths
SELECT
  location,
  date,
  total_cases,
  total_deaths,
  (total_deaths / total_cases) * 100 AS DeathPercentage
FROM
  `coviddata-382220.Covid.Covid_Deaths` --WHERE location = "India"
WHERE continent IS NOT NULL
ORDER BY
  1,
  2;


-- Totoal Cases Vs Population
-- Queries what percentage of population got infected by Covid
SELECT
  location,
  date,
  population,
  total_cases,
  (total_cases / population) * 100 AS InfectedPercentage
FROM
  `coviddata-382220.Covid.Covid_Deaths` --WHERE location = "India"
WHERE continent IS NOT NULL
ORDER BY
  1,
  2;


-- Peak infection rate w.r.t their location & population
SELECT
  location,
  population,
  MAX(total_cases) MaxInfectionCount,
  MAX((total_cases / population) * 100) AS MaxInfectedPercentage
FROM
  `coviddata-382220.Covid.Covid_Deaths`
WHERE continent IS NOT NULL
GROUP BY
  1,
  2
ORDER BY
  3 DESC,
  4 DESC;


-- Countries with highest death count per population
SELECT
  location,
  population,
  MAX(total_deaths) AS TotalDeathCount
FROM
  `coviddata-382220.Covid.Covid_Deaths`
WHERE continent IS NOT NULL
GROUP BY
  1,
  2
ORDER BY 3 DESC;


-- Breaking things down by continents
-- Quering the continents with most deaths
SELECT
  continent,
  MAX(total_deaths) AS TotalDeathCount
FROM
  `coviddata-382220.Covid.Covid_Deaths`
WHERE continent IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC;


-- GLOBAL NUMBERS
-- Daily death percentage w.r.t daily new cases
SELECT
  date,
  SUM(new_cases) AS DailyInfectedCount,
  SUM(new_deaths) AS DailyDeathCount,
  (
    NULLIF(SUM(new_deaths), 0) / NULLIF(SUM(new_cases), 0)
  ) * 100 AS DailyDeathPercentage
FROM
  `coviddata-382220.Covid.Covid_Deaths`
WHERE continent IS NOT NULL
GROUP BY 1
ORDER BY
  1,
  2;


-- Population Vs Vaccinations
WITH PopVsVacc AS (
    SELECT
      d.continent AS Continent,
      d.location AS Location,
      d.date AS Date,
      d.population AS Population,
      v.new_vaccinations AS NewVaccination,
      SUM(v.new_vaccinations) OVER(
        PARTITION BY d.location
        ORDER BY
          d.location,
          d.date
      ) AS RollingPeopleVaccinated
    FROM
      `coviddata-382220.Covid.Covid_Deaths` AS d
      JOIN `coviddata-382220.Covid.Covid_Vaccination` AS v ON d.location = v.location
      AND d.date = v.date
    WHERE d.continent IS NOT NULL
  )
SELECT
  *,
  (RollingPeopleVaccinated / Population) * 100 AS VaccinatedPopulationPercentage
FROM PopVsVacc
ORDER BY
  2,
  3;


-- Creating a view for the above query, in order to use it further for visualization
CREATE OR REPLACE VIEW coviddata-382220.Covid.PercentPopulationVaccinated AS
SELECT
  d.continent AS Continent,
  d.location AS Location,
  d.date AS Date,
  d.population AS Population,
  v.new_vaccinations AS NewVaccination,
  SUM(v.new_vaccinations) OVER(
    PARTITION BY d.location
    ORDER BY
      d.location,
      d.date
  ) AS RollingPeopleVaccinated
FROM
  `coviddata-382220.Covid.Covid_Deaths` AS d
  JOIN `coviddata-382220.Covid.Covid_Vaccination` AS v ON d.location = v.location
  AND d.date = v.date
WHERE d.continent IS NOT NULL