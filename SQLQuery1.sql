Use PortfolioProject

Select *
From PortfolioProject..CovidDeaths
where continent is not null
Order by 3, 4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3, 4

-- Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1, 2


--Looking at total cases vs total deaths.
-- Shows the liklihood of dying if you contract covid in your country.
--total_deaths column is in the data type 'nvarchar' and hence that has to be converted to 'float' data type inorder to be used for calculations.
-- I have used 'try_convert' here.

Select location, date, total_cases, total_deaths, (try_convert(float, total_deaths))/(try_convert(float,total_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%states%' 
Order by 1, 2


-- Looking at total cases vs population
-- Shows what percentage of population got covid

Select location, date, population, total_cases, (try_convert(float, total_cases))/(try_convert(float,population))*100 as PercentPopulation
From PortfolioProject..CovidDeaths
--where location like '%states%' 
Order by 1, 2


-- Looking at countries with highest infection rate compared to population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((try_convert(float, total_cases))/(try_convert(float,population)))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%states%' 
Group by location, population
Order by PercentPopulationInfected desc

--Showing countries with highest death count per population

-- I have used CAST to change the data type of total_deaths in the below query.

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%states%' 
where continent is not null
Group by location
Order by TotalDeathCount desc


-- Lets break thing down by continent

--Showing continents with the highest death count

--Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
--From PortfolioProject..CovidDeaths
----where location like '%states%' 
--where continent is null
--Group by location
--Order by TotalDeathCount desc

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%states%' 
where continent is not null
Group by continent
Order by TotalDeathCount desc

-- Global Numbers 


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/nullif(SUM(new_cases), 0)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
--Group by date
order by 1,2

-- Covid Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Use CTE


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccintions)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccintions/Population)*100
From PopvsVac


-- Temp table

--In the below query for the calculation I have used CAST as bigint instead of int as the sum exceeds the range supported by the int data type and hence throws an error.

DROP table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- View

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
from PercentPopulationVaccinated