select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3, 4;

-- select *
-- from PortfolioProject..CovidVaccinations
-- order by 3,4;


-- Select Data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2;


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract Covid in your country (used where clause to find percentage in United States)
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
where continent is not null
order by 1,2;


-- Looking for Total Cases vs Population
-- Shows what percentage of population has been infected with Covid
select location, date, population, total_cases, (total_cases/population)*100 as InfectedPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--where location like '%states%'
order by 1,2;


--Looking at Countries with Highest Infection Rate compared to Population

select location, population, max(total_cases) as HighestInfectionCount, Max((total_cases/population)*100) as InfectedPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by InfectedPercentage desc;


-- Showing Countries with the Highest Death Count per Population

select location, max(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc;



-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc;


-- GLOBAL NUMBERS

select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, 
(sum(new_deaths)/sum(new_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null and new_cases != 0
--group by date
order by 1,2;


-- Looking at Total Population vs Vaccinations

-- USE CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(convert(bigint, vac.new_vaccinations)) over 
	(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *, RollingPeopleVaccinated/Population * 100
from PopvsVac


-- TEMP TABLE

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(convert(bigint, vac.new_vaccinations)) over 
	(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, RollingPeopleVaccinated/Population * 100
from #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(convert(bigint, vac.new_vaccinations)) over 
	(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select * 
from PercentPopulationVaccinated