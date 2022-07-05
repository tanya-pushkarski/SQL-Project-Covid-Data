Select *
from PortfolioProject..CovidDeaths
Where continent is null
order by 3,4

--Select *
--from [SQL Projects]..CovidVaccination
--order by 3,4

-- Select data we are going to use 

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

-- Looking  at Total cases vs Total Deaths
-- The possibility of deaths from covid in Canada (%)   
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPrecentage
from PortfolioProject..CovidDeaths
Where location like 'Canada' 
order by 1,2

-- Looking at Total Cases vs Population
-- Shows percentage of cases 
Select location, date, population, total_cases, (total_cases/population)*100 as CasesPrecentage
from PortfolioProject..CovidDeaths
Where location like 'Canada' 
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as CasesPrecentage
from PortfolioProject..CovidDeaths
--Where location like 'Canada' 
Where continent is not null
and location not like '%income%'
Group by location, Population
order by CasesPrecentage desc


-- Showing continents with Highest Death Count per Population
Select continent, MAX(cast(Total_deaths as bigint)) as TotalDeathsCount
from PortfolioProject..CovidDeaths
Where continent is not null
and location not like '%income%' 
Group by continent
order by TotalDeathsCount desc


-- Showing countries with Highest Death Count per Population
Select Location, MAX(cast(Total_deaths as bigint)) as TotalDeathsCount
from PortfolioProject..CovidDeaths
Where continent is not null
and location not like '%income%' 
--Where location like 'Canada' 
Group by Location
order by TotalDeathsCount desc


-- Showing Total Deaths by income class
Select location, MAX(cast(Total_deaths as bigint)) as TotalDeathsCount
from PortfolioProject..CovidDeaths
Where continent is null
and location like '%income%' 
Group by location
order by TotalDeathsCount desc


--GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths, SUM(cast(new_deaths as bigint))/SUM(new_cases)*100 as DeathPrecentage
from PortfolioProject..CovidDeaths
Where continent is not null
--Group by date
order by 1,2


-- Looking at Total Population vs Vaccinations
-- USE CTE

With PopvsVac (Continent, Locaton, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Create View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select * from dbo.PercentPopulationVaccinated