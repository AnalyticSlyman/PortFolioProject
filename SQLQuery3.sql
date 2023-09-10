SELECT *
from PortfolioProject01..CovidDeaths
where continent is not null
order by 3,4

--SELECT *
--FROM PortfolioProject01..CovidVaccinations

--select data to be used

SELECT location, total_cases,new_cases,total_deaths,population
from  PortfolioProject01..CovidDeaths
order by 1,2


--Looking at total cases vs total deaths
--shows the likelihood of dying if you contract covid in your country
SELECT location, total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from  PortfolioProject01..CovidDeaths
where location like '%states%'
order by 1,2

-- looking at total cases vs population
-- shows whats percentage of population got covid
SELECT location, population,total_cases,(total_deaths/population)*100 as percentagepopulationinfected
from  PortfolioProject01..CovidDeaths
where location like '%states%'
order by 1,2


--countries with highest infection rate

SELECT location, population,max(total_cases) as highestinfectioncount,max(total_deaths/population)*100 as percentagepopulationinfected
from  PortfolioProject01..CovidDeaths
--where location like '%states%'
group by location,population
order by percentagepopulationinfected desc

--countries with the highest death count per population

SELECT continent,location, max(cast(total_deaths as int)) as TotalDeathCount
from  PortfolioProject01..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent,location
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

SELECT location, max(cast(total_deaths as int)) as TotalDeathCount
from  PortfolioProject01..CovidDeaths
--where location like '%states%'
where continent is null
group by location
order by TotalDeathCount desc

SELECT continent, max(cast(total_deaths as int)) as TotalDeathCount
from  PortfolioProject01..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS
SELECT date, SUM(new_cases) as totalcases,SUM(Cast(new_deaths as int)) as totaldeaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from  PortfolioProject01..CovidDeaths
--where location like '%states%'
where continent is not null
GROUP BY date
order by 1,2

----------------------------

-- GLOBAL NUMBERS
SELECT  SUM(new_cases) as totalcases,SUM(Cast(new_deaths as int)) as totaldeaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from  PortfolioProject01..CovidDeaths
--where location like '%states%'
where continent is not null
--GROUP BY date
order by 1,2

-- LOOKING AT TOTAL POPULATION VS VACCINATION
SELECT dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as SummingPeopleVaccinated
FROM PortfolioProject01..CovidDeaths dea
JOIN PortfolioProject01..CovidVaccinations vac
	ON  dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE

WITH PopvsVac (continent,location,date, population,new_vaccinations,SummingPeopleVaccinated)
as
(
SELECT dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as SummingPeopleVaccinated
FROM PortfolioProject01..CovidDeaths dea
JOIN PortfolioProject01..CovidVaccinations vac
	ON  dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *, (SummingPeopleVaccinated/population)*100
from PopvsVac

-- temptable

DROP TABLE IF EXISTS #PercentagePopulationVaccinated

CREATE TABLE #PercentagePopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
SummingPeopleVaccinated numeric
)

insert into #PercentagePopulationVaccinated
SELECT dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as SummingPeopleVaccinated
FROM PortfolioProject01..CovidDeaths dea
JOIN PortfolioProject01..CovidVaccinations vac
	ON  dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3


select *, (SummingPeopleVaccinated/population)*100
from  #PercentagePopulationVaccinated


-- CREATING VIEW TO STORE DATA FOR LATER VISUALISATIONS

CREATE VIEW PercentagePopulationVaccinated AS
SELECT dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as SummingPeopleVaccinated
FROM PortfolioProject01..CovidDeaths dea
JOIN PortfolioProject01..CovidVaccinations vac
	ON  dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


-- QUERYING OFF VIEW
SELECT *
FROM PercentagePopulationVaccinated