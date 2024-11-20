use PortfolioProject

select *
from Covid_Deaths


--Selecting total cases and total deaths
select location, date, total_cases, total_deaths, population
from Covid_Deaths

--Calculating death_percentage(Total death vs total cases) in all the countries and in india
select location, date, total_cases, total_deaths, round((cast(total_deaths as float)/total_cases)*100, 4) as Death_percentage
from Covid_Deaths

select location, date, total_cases, total_deaths, round((cast(total_deaths as float)/total_cases)*100, 4) as Death_percentage
from Covid_Deaths
where location = 'india'

--Calculating case_percentage(Total cases vs population) in all the countries and in india
select location, date, population, total_cases, round((cast(total_cases as float)/population)*100, 4) as Case_percentage
from Covid_Deaths

select location, date, population, total_cases, round((cast(total_cases as float)/population)*100, 4) as Case_percentage
from Covid_Deaths
where location = 'india'


--Calculating death_population_percentage(Total deaths vs population) in all the countries and in india
select location, date, population, total_deaths, round((cast(total_deaths as float)/population)*100, 4) as death_vs_population_percentage
from Covid_Deaths

select location, date, population, total_deaths, round((cast(total_deaths as float)/population)*100, 4) as death_vs_population_percentage
from Covid_Deaths
where location = 'india'


--Finding maximum cases in each location
select location, population, max(total_cases) as max_case
from Covid_Deaths
where continent is not null
group by location, population
order by max(total_cases) desc


--Finding maximum deaths in each location
select location, population, max(total_deaths) as max_deaths
from Covid_Deaths
where continent is not null
group by location, population
order by max(total_deaths) desc

-- Deaths by continent
with cte as(
select continent, location, max(total_deaths) as max_death_country
from Covid_Deaths
where continent is not null
group by continent, location
)
select continent, sum(max_death_country) as total_death_continent
from cte
group by continent
order by total_death_continent desc
--order by max(total_deaths) desc


-- Deaths percentage for total population
with cte as(
select continent, location, population, max(total_deaths) as max_death_country
from Covid_Deaths
where continent is not null
group by continent, location, population
)
select sum(cast(max_death_country as float))/sum(population) * 100 as death_percentage_entire_population
from cte

select * from Covid_Deaths
select * from Covid_Vaccinations

--Joining covid_deaths and covid_vaccinations and checking vaccination details
select cd.location, cd.date, cd.total_cases, cd.population, cv.new_vaccinations
from Covid_Deaths as cd
join Covid_Vaccinations as cv
on cd.location = cv.location and cd.date = cv.date

-- Running sum of the new_vaccination by location/country
select location, date, new_vaccinations, sum(new_vaccinations) over(partition by location order by location, date) as running_sum_vaccination
from Covid_Vaccinations
where continent is not null

-- Temp table

create table #percentofpopulationvaccinated(
location varchar(50),
date date,
total_case int,
population int,
new_vaccinations int,
running_sum_vaccination int
)

insert into #percentofpopulationvaccinated
select cd.location, cd.date, cd.total_cases, cd.population, cv.new_vaccinations, 
	sum(cv.new_vaccinations) over(partition by cv.location order by cv.location, cv.date) as running_sum_vaccination
from Covid_Deaths as cd
join Covid_Vaccinations as cv
on cd.location = cv.location and cd.date = cv.date
where cv.continent is not null
order by cd.location, cd.date

select *, (running_sum_vaccination / convert(float, population)) * 100 as  vaccination_percentage
from #percentofpopulationvaccinated

--creating a view
create view percentofpopulationvaccinated as
select cd.location, cd.date, cd.total_cases, cd.population, cv.new_vaccinations, 
	sum(cv.new_vaccinations) over(partition by cv.location order by cv.location, cv.date) as running_sum_vaccination
from Covid_Deaths as cd
join Covid_Vaccinations as cv
on cd.location = cv.location and cd.date = cv.date
where cv.continent is not null

select * 
from percentofpopulationvaccinated