/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/
Select * 
from PortfolioProject..CovidDeath
where continent is not null
order by 3,4

--Select * from PortfolioProject..CovidVaccination
--order by 3, 4

--Selecting the data to start with

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeath
where continent is not null
order by 1, 2

--Looking at the Total cases vs Total deaths
    
--Converting the data types in the RAW data
--ALTER TABLE PortfolioProject..CovidDeath
--ALTER COLUMN Total_deaths
--FLOAT;
--ALTER TABLE PortfolioProject..CovidDeath
--ALTER COLUMN Total_cases
--FLOAT

--Shows likelihood of dying if you contract corona in your country; You can pic any country from the ARW Data
    
select location, date, total_cases, total_deaths, (total_deaths)/(total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeath
where location like '%ASia%' and continent is not null
order by 1, 2

--Looking at the Total cases vs The population
--Shows what % of the population got infected with Covid
--To check for particualr location
select location, date, population, total_cases, (total_cases)/(population)*100 as DeathPercentage
from PortfolioProject..CovidDeath
where location like '%India%' 
order by 1, 2

--To Check overall % of Population
select location, date, population, total_cases, (total_cases)/(population)*100 as PercentageofPopulationInfected
from PortfolioProject..CovidDeath
--where location like '%India%'
order by 1, 2

--Looking at Countries with highest infection rate compared to population 

select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases)/(population))*100 as PercentageofPopulationInfected
from PortfolioProject..CovidDeath
--where location like '%India%'
Group by location, population
order by PercentageofPopulationInfected desc

--Showing the contries with Highest Death count per Population

select location, Max(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeath
--where location like '%Asia%'
where continent is not null
Group by location
order by TotalDeathCount desc

--LETS breat things down by CONTINENT

--Showing the continents with the highest death count per population

select continent, Max(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeath
--where location like '%Asia%'
where continent is not null
Group by continent
order by TotalDeathCount desc


--Global Numbers

--Rectifying the errors made 

--select date, Sum(new_cases), SUM(new_deaths), sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
--from PortfolioProject..CovidDeath
----where location like '%ASia%' and 
--where continent is not null 
--Group by date
--order by 1, 2

--SELECT new_cases, new_deaths,
-- CASE 
-- WHEN new_deaths = 0 OR new_cases = 0 THEN NULL
-- ELSE CAST(new_cases AS FLOAT) / NULLIF(New_Deaths, 0)
-- END AS Result
--FROM PortfolioProject..CovidDeath

--Generating the entire data from RAW Dataset
    
SELECT date, SUM(new_cases) AS TotalNewCases, SUM(new_deaths) AS TotalNewDeaths,
SUM(new_deaths) / NULLIF(SUM(new_cases), 0) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeath
WHERE continent IS NOT NULL 
GROUP BY date
ORDER BY date;

--Calculating DeathPercentage according to Date

SELECT date, TotalNewCases,TotalNewDeaths,DeathPercentage
FROM (SELECT date, SUM(new_cases) AS TotalNewCases,
SUM(new_deaths) AS TotalNewDeaths,
SUM(new_deaths) / NULLIF(SUM(new_cases), 0) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeath
WHERE continent IS NOT NULL 
group by date) AS sub
WHERE
TotalNewCases IS NOT NULL
AND TotalNewDeaths IS NOT NULL
AND DeathPercentage IS NOT NULL
ORDER BY 1, 2;

--Total Number of Deaths in two methods (Comment any method you don't want)

--Method (1) Derived Table/InlineView

SELECT TotalNewCases,TotalNewDeaths,DeathPercentage
FROM (SELECT SUM(new_cases) AS TotalNewCases,
SUM(new_deaths) AS TotalNewDeaths,
SUM(new_deaths) / NULLIF(SUM(new_cases), 0) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeath
WHERE continent IS NOT NULL 
) AS sub
WHERE
TotalNewCases IS NOT NULL
AND TotalNewDeaths IS NOT NULL
AND DeathPercentage IS NOT NULL
ORDER BY 1, 2;

--Method (2) Common Table Expression

WITH CTE AS (
SELECT 
SUM(new_cases) AS TotalNewCases,
SUM(new_deaths) AS TotalNewDeaths,
SUM(new_deaths) / NULLIF(SUM(new_cases), 0) * 100 AS DeathPercentage
FROM  PortfolioProject..CovidDeath
WHERE  continent IS NOT NULL 
)
SELECT  TotalNewCases, TotalNewDeaths,  DeathPercentage
FROM  CTE
WHERE
TotalNewCases IS NOT NULL
AND TotalNewDeaths IS NOT NULL
AND DeathPercentage IS NOT NULL
ORDER BY 1, 2;


----Looking at Total population vs Vaccinations

--ALTER TABLE PortfolioProject..CovidVaccination
--ALTER COLUMN New_vaccinations
--Float

--Exploring Join Concepts
--Showing % of Population that have taken at least one Covid Vaccine Shoot

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeath dea
join PortfolioProject..CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--dea.location like '%Canada%' and 
order by 2, 3

--Using CTE to perfom calculation on Partition By in above query

with PopulatioNvsVaccinE (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
As(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeath dea
join PortfolioProject..CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--dea.location like '%Canada%' and 
--order by 2, 3
)
Select *, (RollingPeopleVaccinated/population)*100 as PeopleVaccinated
from PopulatioNvsVaccinE


--Using TEMP TABLE to perform calculation on Partition By

DROP TABLE if exists #PercentPeopleVaccinated
Create table #PercentPeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPeopleVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeath dea
join PortfolioProject..CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--dea.location like '%Canada%' and 
--order by 2, 3
Select *, (RollingPeopleVaccinated/population)*100 as PeopleVaccinated
from #PercentPeopleVaccinated


--Creating view to store data for later visuaization

Create View PercentPeopleVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeath dea
join PortfolioProject..CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--dea.location like '%Canada%' and 
--order by 2, 3

-- To get data from the VIEW creaed
Select * from PercentPeopleVaccinated
