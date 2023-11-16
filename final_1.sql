select * 
from portfolio_project.dbo.CovidDeaths

select *
from portfolio_project.dbo.CovidVaccinations
order by 3,4

-- SELECT DATA THAT WE ARE GOING TO BE USING 

select location, date, total_cases, new_cases, total_deaths, population
from portfolio_project.dbo.CovidDeaths
Where continent is NOT NULL
order by 1, 2



-- loking at total cases vs total deaths 
-- shows likelyhood of dying if you are in contact in your company
select location, total_cases, date, total_deaths, cast((total_deaths*1.0/total_cases)*100 as decimal(5,2)) as death_percentage
from portfolio_project.dbo.CovidDeaths
where location like 'india' and total_deaths is NOT NULL and date like '%2020%' and continent is NOT NULL
order by 1, 2


--LOOKING AT THE TOTAL CASES VS POPULATION 
-- Shows what percentage of population got covid
 SELECT location, date, population, total_cases, cast((total_cases*1.0/population)*100 as decimal(8, 2)) as Affected_population
 from portfolio_project.dbo.CovidDeaths
 Where continent is NOT NULL and location like '%states%'
 order by 1, 2, 3


 --LOOKING AT COUNTRIES WITH HIGHEST INFECTED RATE COMPARED TO THE POPULATION 

 SELECT location, population, MAX(total_cases) as Highest_Infected_Count, MAX((total_cases*1.0/population)*100) as Highest_Infected_Percentage
 from portfolio_project..CovidDeaths
 -- where location like'i%'
  Where continent is NOT NULL
 group by location, population
 order by Highest_Infected_Percentage desc


 --LOOKING AT COUNTRIES WITH HIGHEST DEATH COUNT COMPARED TO THE POPULATION 

 SELECT location, population, max(total_deaths) as Highest_Death_Rate, Max((total_deaths*1.0/population)*100) as death_percentage
 from portfolio_project..CovidDeaths
 Where continent is NOT NULL
 GROUP BY location, population
 order by Highest_Death_Rate desc

 -- SHOWING CONTINENTS WITH THE HIGHEST DEATH COUNT

 Select continent, max(total_deaths) as Death_Count
 from portfolio_project..CovidDeaths
 where continent is not NULL
 GROUP by continent
 order by Death_Count desc

 select location, MAX(total_deaths) as Death_Count
 from portfolio_project..CovidDeaths
 where continent is NULL
 GROUP by location
 ORDER by Death_Count desc




--  LOOKING FOR HOW MUCH POPULATION IS VACCINATED TILL NOW


--  USING CTE
with Popu_vs_Vacc(continent, location, date, population, new_vaccinations, rolling_people_vaccination)
AS
(
Select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
sum(convert(int,vacc.new_vaccinations)) over (partition by dea.location order by dea.date) as rolling_people_vaccination
FROM portfolio_project..CovidDeaths dea
JOIN portfolio_project..CovidVaccinations vacc
    on dea.date = vacc.date
    and dea.location = vacc.location
where dea.continent is not null
-- order by 2, 3
)

select *, (rolling_people_vaccination*1.0/population)*100 AS Vaccination_Percentage
from Popu_vs_Vacc



-- USING TEMP TABLE 
-- DROP TABLE IF EXISTS
create table #vaccinationPercentage
(
    continent nvarchar(255),
    location nvarchar(255),
    date DATETIME,
    population NUMERIC,
    new_vaccinaton NUMERIC,
    rolling_people_vaccination NUMERIC
)

insert into #vaccinationPercentage
Select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
sum(convert(int,vacc.new_vaccinations)) over (partition by dea.location order by dea.date, dea.location) as rolling_people_vaccination
FROM portfolio_project..CovidDeaths dea
JOIN portfolio_project..CovidVaccinations vacc
    on dea.date = vacc.date
    and dea.location = vacc.location
--where dea.continent is not null
order by 2, 3

SELECT *, (rolling_people_vaccination*1.0/population)*100 as Vaccination_Percentage
from #vaccinationPercentage

-- WE CAN ALSO FIND THE Max Percentage of Vaccinated Population



--  CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

CREATE view vaccinationPercentage AS

Select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
sum(convert(int,vacc.new_vaccinations)) over (partition by dea.location order by dea.date, dea.location) as rolling_people_vaccination
FROM portfolio_project..CovidDeaths dea
JOIN portfolio_project..CovidVaccinations vacc
    on dea.date = vacc.date
    and dea.location = vacc.location
where dea.continent is not null
--order by 2, 3
 