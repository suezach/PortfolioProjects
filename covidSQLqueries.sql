select distinct * from PortfolioProject..coviddeaths
--where continent is null


select * from PortfolioProject..covidvaccinations
order by 3, 4

--Select Data that we are going to be using
select continent,location,date,total_cases,new_cases,total_deaths,population 
from PortfolioProject..coviddeaths
where continent is not null
order by 1,2

--looking at the total cases against total deaths
--Shows the likelihood of dying if you contract covid your country
select location,date,total_cases,total_deaths, (total_deaths/total_cases) * 100 as deathpercentage
from PortfolioProject..coviddeaths
where location like '%states%'
order by 1,2

--looking at the total cases against population
--shows what percentage of population got covid
select location,date,total_cases,population, (total_cases/population) * 100 as percentageopopulationinfected
from PortfolioProject..coviddeaths
--where location like '%states%'
order by 1,2

--looking at countries with highest infection rate compared to population
select location,population,max(total_cases) as highestinfectioncount, max((total_cases/population))*100 as percentageofpopulationinfected
from PortfolioProject..coviddeaths
group by location,population
order by percentageofpopulationinfected desc

--showing countries with the highest death count per population
select location,max(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..coviddeaths
where continent is not null
group by location
order by totaldeathcount desc

--query to show that 13 locations (which are not countries) have the continent NULL
select continent,location,max(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..coviddeaths
where continent is null
group by continent, location
order by totaldeathcount desc

-- test query to get the total counts for the locations

select location,max(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..coviddeaths
--where continent is null
group by location
order by totaldeathcount desc

--LET'S BREAK THINGS DOWN BY CONTINENTS(that is have locations with continents
-- Query gives us the countries with the highest covid death count and the continent it is in

select continent,location,max(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..coviddeaths
where continent is not null
group by continent, location
order by totaldeathcount desc

--query now gives us the exact total deaths for every region(continents and other)

select location,max(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..coviddeaths
where continent is null
group by location
order by totaldeathcount desc


--query showing the continents with highest death count per population
select continent,max(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..coviddeaths
where continent is not null
group by continent
order by totaldeathcount desc

--Global Numbers
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths , sum(cast(new_deaths as int))/ sum(new_cases)* 100 as deathpercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

--Query that gives the total cases and total deaths
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths , sum(cast(new_deaths as int))/ sum(new_cases)* 100 as deathpercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2


-- Query to join both tables on location and date
select * 
from PortfolioProject..CovidDeaths D
join PortfolioProject..CovidVaccinations V
on D.location = V.location
and D.date = V.date

--Query total population vs vaccinations

select D.continent,D.location,D.date, D.population, V.new_vaccinations 
from PortfolioProject..CovidDeaths D
join PortfolioProject..CovidVaccinations V
on D.location = V.location
and D.date = V.date
where D.continent is not null
order by 2,3


--Query to find the rolling number of people vaccinated for every country. We first partition by location, and order by location
--and date. we get the sum of new_vacination and use OVER keyword to get the rollingpeoplevaccinated for every location and date.
--Also, use CONVERT to convert the new_vaccinations from varchar to float (same as CAST)
select D.continent,D.location,D.date, D.population, V.new_vaccinations,
       sum(convert(float,V.new_vaccinations)) OVER (Partition by D.location order by D.location, D.date)
	   as rollingpeoplevaccinated 
from PortfolioProject..CovidDeaths D
join PortfolioProject..CovidVaccinations V
on D.location = V.location
and D.date = V.date
where D.continent is not null
order by 2,3

-- To find percentage of population vaccinated for a every country and date.
-- we create a temporary table to perform calculation on rollingpeoplevaccinated

--USE CTE

with popvsvac (continent,location,date,population,new_vaccinations,rollingpeoplevaccinated)
as
(
	select D.continent,D.location,D.date, D.population, V.new_vaccinations,
           sum(convert(float,v.new_vaccinations)) OVER (Partition by D.location order by D.location, D.date) as rollingpeoplevaccinated 
	from PortfolioProject..CovidDeaths D
	join PortfolioProject..CovidVaccinations V
	on D.location = V.location
	and D.date = V.date
	where D.continent is not null
)
select * , (rollingpeoplevaccinated/population) * 100 as percentagevaccinated
from popvsvac

--TEMP table 
-- Creating table to get the same output as when using the above CTE
-- use drop table
Drop table if exists #percentpopulationvaccinated
Create table #percentpopulationvaccinated
( 
   continent nvarchar(255),
   location nvarchar(255),
   date Datetime,
   population numeric,
   new_vaccinations numeric,
   rollingpeoplevaccinated numeric,
)
Insert into #percentpopulationvaccinated
select D.continent,D.location,D.date, D.population, V.new_vaccinations,
           sum(convert(float,v.new_vaccinations)) OVER (Partition by D.location order by D.location, D.date) as rollingpeoplevaccinated 
	from PortfolioProject..CovidDeaths D
	join PortfolioProject..CovidVaccinations V
	on D.location = V.location
	and D.date = V.date
	where D.continent is not null

select * , (rollingpeoplevaccinated/population) * 100 as percentagevaccinated
from #percentpopulationvaccinated


-- create view to store data for later visualization

create View percentpopulationvaccinated as
select D.continent,D.location,D.date, D.population, V.new_vaccinations,
           sum(convert(float,v.new_vaccinations)) OVER (Partition by D.location order by D.location, D.date) as rollingpeoplevaccinated 
	from PortfolioProject..CovidDeaths D
	join PortfolioProject..CovidVaccinations V
	on D.location = V.location
	and D.date = V.date
	where D.continent is not null

select * 
from percentpopulationvaccinated
















