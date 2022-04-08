/*
COVID 19 Data Exploration

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views

*/

select *
from [Portfolio Project]..CovidDeaths
Where continent is not null
order by 3, 4

--select *
--from [Portfolio Project].dbo.CovidVaccinations
--Where continent is not null
--order by 3, 4

--Select Data we are going to be using

Select location, continent, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..CovidDeaths
order by 1, 2


--Looking at Total Cases vs Total Deaths
-- Shows likeihood of dying if you contract covid in your country



Select location, continent, date, total_cases, total_deaths, ( total_deaths / total_cases ) * 100 as DeathsPercentage
From [Portfolio Project]..CovidDeaths
Where location like '%states%'
order by 1, 5 desc


--Looking at the Total Cases vs Population
--Shows what percentage of population got Covid

Select location, continent, date, total_cases, population, ( total_cases / population ) * 100 as PercentPopulationInfected
From [Portfolio Project]..CovidDeaths
--Where location like '%states%'
order by 1, 5 desc


--Looking at Countries with Highest Infection Rate compared to Population

Select Location, Continent, Population, MAX(total_cases) as HighestInfectionCount,
MAX(total_cases / Population ) * 100 as PercentagePopulationInfected
From [Portfolio Project]..CovidDeaths
--Where location like '%states%'
Group by location, population, continent
order by PercentagePopulationInfected desc


--Showing the Countries with the Highest Death Count per Population

Select Location, Continent, MAX( cast( total_deaths as int) ) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by location, continent
Order by TotalDeathCount desc


--LET'S BREAK THINGS DOWN BY CONTINENT



--Showing the Continents with the Highest Death Count per Population


Select continent, MAX( cast( total_deaths as int) ) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc


--GLOBAL NUMBERS

--Daily
Select date, SUM( new_cases ) as total_cases, 
SUM(cast( new_deaths as int ) ) as total_deaths, 
SUM( cast( new_deaths as int ) ) / SUM( new_cases ) * 100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by date
order by 1, 2

--Aggregate
Select SUM( new_cases ) as total_cases, 
SUM(cast( new_deaths as int ) ) as total_deaths, 
SUM( cast( new_deaths as int ) ) / SUM( new_cases ) * 100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group by date
order by 1, 2


--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
SUM( CONVERT ( bigint, vac.new_vaccinations) ) OVER ( Partition by dea.location Order by dea.location, dea.date ) as RollingPeopleVaccinated
--( RollingPeopleVaccinated / population ) * 100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2, 3 


--USE CTE ( Common Table Expression - temp view )

With PopvsVac --Population Vs Vaccination
(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
SUM( CONVERT ( bigint, vac.new_vaccinations) ) OVER ( Partition by dea.location Order by dea.location, dea.date ) as RollingPeopleVaccinated
--( RollingPeopleVaccinated / population ) * 100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2, 3 
)
Select *, ( RollingPeopleVaccinated / Population) * 100
From PopvsVac


-- TEMP TABLE

Drop Table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM( CONVERT( bigint, vac.new_vaccinations ) ) OVER (Partition By dea.location Order By dea.location,
dea.date ) as RollingPeopleVaccinated
--(RollingPeopleVaccinated / Population ) * 100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and  dea.date = vac.date
--Where dea.continent is not null
--order by 2, 3

Select *, ( RollingPeopleVaccinated / Population) * 100
From #PercentagePopulationVaccinated


--Creating View to store data for later visualizations

Create View PercentagePopulationVaccinated As
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM( CONVERT( bigint, vac.new_vaccinations ) ) OVER (Partition By dea.location Order By dea.location,
dea.date ) as RollingPeopleVaccinated
--(RollingPeopleVaccinated / Population ) * 100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and  dea.date = vac.date
Where dea.continent is not null
--order by 2, 3


Select *
From PercentagePopulationVaccinated
