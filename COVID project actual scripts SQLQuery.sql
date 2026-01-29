select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

select Location, date, total_cases, new_cases, total_deaths, population from PortfolioProject ..CovidDeaths
where continent is not null
order by 1,2

-- Looking at total cases vs total deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject ..CovidDeaths 
where location like '%Brazil%'
and continent is not null
order by 1,2

-- Looking at total cases vs population
-- Show what percentage of population got Covid

select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulatinInfected
from PortfolioProject ..CovidDeaths 
--where location like '%new zealand%'
order by 1,2

--Looking at countries with highest infection rate compared to population

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulatinInfected
from PortfolioProject ..CovidDeaths 
--where location like '%new zealand%'
group by location, population
order by PercentPopulatinInfected desc

-- Showing countries with highest death count per population

select location, max(cast(total_deaths as int)) as TotaldDeathCount
from PortfolioProject ..CovidDeaths 
--where location like '%new zealand%'
where continent is not null
group by location
order by TotaldDeathCount desc

--Breaking things down by continent

select continent, max(cast(total_deaths as int)) as TotaldDeathCount
from PortfolioProject ..CovidDeaths 
--where location like '%new zealand%'
where continent is not null
group by continent
order by TotaldDeathCount desc

-- Showing continents with highest death count per population

select continent, max(cast(total_deaths as int)) as TotaldDeathCount
from PortfolioProject ..CovidDeaths 
--where location like '%new zealand%'
where continent is not null
group by continent
order by TotaldDeathCount desc

-- Global numbers grouped by date

select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)* 100 as DeathPercentage
from PortfolioProject.. CovidDeaths
--Where location like '%Brazil%
where continent is not null
Group by date
order by 1,2

-- Global numbers

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)* 100 as DeathPercentage
from PortfolioProject.. CovidDeaths
--Where location like '%Brazil%
where continent is not null
order by 1,2

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3



Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert (int, vac.new_vaccinations)) OVER (partition by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT (int, vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


-- TEMP TABLE
 
drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT (int, vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from  #PercentPopulationVaccinated


-- Creating view to store data for later  visualizations

create view percentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT (int, vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select*
from percentPopulationVaccinated























