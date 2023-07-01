
Select *
From [Portfolio Project]..[Covid Deaths]
Where continent is not Null 
Order by 3,4


--Select Data that we are going to use
Select Location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..[Covid Deaths]
Order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Displays the Likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
From  [Portfolio Project]..[Covid Deaths]
Where Location ='United States'
Order by 1,2

-- Looking at Total cases vs Population
-- Show what percentage of population got Covid 
Select Location, date, population, total_cases, (total_cases/Population) * 100 as PercentofPopulationInfected
From  [Portfolio Project]..[Covid Deaths]
Where Location ='United States'
Order by 1,2


-- Looking at Countries with highest infection rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population)) * 100 as PercentofPopulationInfected
From  [Portfolio Project]..[Covid Deaths]
Group By Location, Population
Order by PercentofPopulationInfected DESC

-- Lets break it down by Continents 
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From  [Portfolio Project]..[Covid Deaths]
Where continent is not Null 
Group By continent
Order by TotalDeathCount DESC


--Showing Countries with Highest Death Count per Population 

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From  [Portfolio Project]..[Covid Deaths]
Where continent is not Null 
Group By Location
Order by TotalDeathCount DESC


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage
From  [Portfolio Project]..[Covid Deaths]
Where continent is not null
Order by 1,2



Select dea.continent, dea.location, dea.date, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..[Covid Vaccinations] vac
JOIN [Portfolio Project]..[Covid Deaths] dea
On vac.location = dea.location
and dea.date = vac.date
where dea.continent is not null
Order by 2,3

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..[Covid Vaccinations] vac
JOIN [Portfolio Project]..[Covid Deaths] dea
On vac.location = dea.location
and dea.date = vac.date
where dea.continent is not null
)

Select * , (RollingPeopleVaccinated/Population) * 100 as PercentageVaccinated 
From PopvsVac


