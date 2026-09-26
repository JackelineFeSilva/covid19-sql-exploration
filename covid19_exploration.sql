-- COVID-19 data exploration in SQL Server
-- Tutorial practice based on Alex The Analyst. Requires the CovidDeaths and
-- CovidVaccinations tables in the PortfolioProject database.

-- Preview country-level records
SELECT location, date, population, total_cases, new_cases, total_deaths
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date;

-- Total deaths as a percentage of reported cases in Brazil, by date
SELECT location, date, total_cases, total_deaths,
       100.0 * total_deaths / NULLIF(total_cases, 0) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'Brazil' AND continent IS NOT NULL
ORDER BY location, date;

-- Reported cases as a percentage of population, by country and date
SELECT location, date, population, total_cases,
       100.0 * total_cases / NULLIF(population, 0) AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date;

-- Highest reported case count and highest infection percentage by country
SELECT location, population,
       MAX(total_cases) AS HighestInfectionCount,
       MAX(100.0 * total_cases / NULLIF(population, 0)) AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

-- Highest reported total death count by country
SELECT location, MAX(TRY_CONVERT(bigint, total_deaths)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- Highest country-level death count within each continent
-- This is not a sum of deaths across all countries in the continent.
SELECT continent, MAX(TRY_CONVERT(bigint, total_deaths)) AS HighestCountryDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestCountryDeathCount DESC;

-- Global new cases and new deaths by date (country-level rows only)
SELECT date,
       SUM(new_cases) AS NewCases,
       SUM(TRY_CONVERT(bigint, new_deaths)) AS NewDeaths,
       100.0 * SUM(TRY_CONVERT(bigint, new_deaths)) / NULLIF(SUM(new_cases), 0) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;

-- Global totals across the dates in the source tables
SELECT SUM(new_cases) AS NewCases,
       SUM(TRY_CONVERT(bigint, new_deaths)) AS NewDeaths,
       100.0 * SUM(TRY_CONVERT(bigint, new_deaths)) / NULLIF(SUM(new_cases), 0) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL;

-- Join the daily deaths and vaccination records
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
  ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.date;

-- Running sum of new vaccinations within each country, in date order
-- This sums vaccination doses reported, not distinct people vaccinated.
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(TRY_CONVERT(bigint, vac.new_vaccinations)) OVER (
           PARTITION BY dea.location ORDER BY dea.date
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS RollingVaccinations
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
  ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.date;

-- CTE: rolling reported vaccinations relative to population
-- This ratio is doses per population, not a share of unique people vaccinated.
;WITH PopvsVac AS (
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
           SUM(TRY_CONVERT(bigint, vac.new_vaccinations)) OVER (
               PARTITION BY dea.location ORDER BY dea.date
               ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
           ) AS RollingVaccinations
    FROM PortfolioProject..CovidDeaths AS dea
    JOIN PortfolioProject..CovidVaccinations AS vac
      ON dea.location = vac.location AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT *, 100.0 * RollingVaccinations / NULLIF(population, 0) AS VaccinationDosesPerPopulationPercent
FROM PopvsVac
ORDER BY location, date;

-- Temporary table: the same calculation stored for subsequent queries
DROP TABLE IF EXISTS #VaccinationProgress;
CREATE TABLE #VaccinationProgress (
    continent nvarchar(255),
    location nvarchar(255),
    date datetime,
    population float,
    new_vaccinations float,
    RollingVaccinations bigint
);

INSERT INTO #VaccinationProgress
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(TRY_CONVERT(bigint, vac.new_vaccinations)) OVER (
           PARTITION BY dea.location ORDER BY dea.date
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       )
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
  ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT *, 100.0 * RollingVaccinations / NULLIF(population, 0) AS VaccinationDosesPerPopulationPercent
FROM #VaccinationProgress
ORDER BY location, date;

-- View for reusing the joined vaccination calculation
-- GO starts the CREATE VIEW statement in its own SQL Server batch.
GO
CREATE VIEW percentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(TRY_CONVERT(bigint, vac.new_vaccinations)) OVER (
           PARTITION BY dea.location ORDER BY dea.date
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS RollingVaccinations
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
  ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
GO

SELECT *
FROM percentPopulationVaccinated
ORDER BY location, date;
