# Covid_data_exploration

## Table of Content
- Project Overview
- Data Source
- Tools
- Exploratory Data Analysis
- Computed Metrics
- Practical Use Cases of This Analysis

## Project Overview

This project focuses on analyzing a global COVID-19 dataset to derive critical insights regarding the pandemic's progression and impact.

## Data Source
- Our World in Data : https://ourworldindata.org/covid-deaths

## Tools
- MS SQL Server

## Exploratory Data Analysis
1. Basic Data Exploration
   > Queries to view total cases, deaths, and populations across all locations
```sql
select location, date, total_cases, total_deaths, population
from Covid_Deaths
```

2. Death Percentage
   > Calculates the proportion of deaths relative to total cases globally and specifically for India:
```sql
select location, date, total_cases, total_deaths, round((cast(total_deaths as float)/total_cases)*100, 4) as Death_percentage
from Covid_Deaths

select location, date, total_cases, total_deaths, round((cast(total_deaths as float)/total_cases)*100, 4) as Death_percentage
from Covid_Deaths
where location = 'india'
```
Purpose: To assess the severity of COVID-19 across different regions.

3. Case Percentage
   > Measures the percentage of cases relative to the population:
```sql
select location, date, population, total_cases, round((cast(total_cases as float)/population)*100, 4) as Case_percentage
from Covid_Deaths

select location, date, population, total_cases, round((cast(total_cases as float)/population)*100, 4) as Case_percentage
from Covid_Deaths
where location = 'india'
```
Purpose: Understand how widely COVID-19 has affected the population in each location.

4. Death vs. Population Percentage
   > Evaluates the proportion of deaths in comparison to the total population:
```sql
select location, date, population, total_deaths, round((cast(total_deaths as float)/population)*100, 4) as death_vs_population_percentage
from Covid_Deaths
```
Purpose: Provides insight into the mortality impact of COVID-19 in different regions.

5. Maximum Cases and Deaths
   > Identifies countries with the highest number of cases and deaths:
```sql
select location, population, max(total_cases) as max_case
from Covid_Deaths
where continent is not null
group by location, population
order by max(total_cases) desc
```
Grouping by location helps rank regions based on their maximum reported cases or deaths.

6. Deaths by Continent
   > Aggregates total deaths for each continent:
```sql
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
```
Purpose: To provide a regional overview of the pandemic’s mortality impact.

7. Global Death Percentage Relative to Population
   > Uses a Common Table Expression (CTE) to calculate the percentage of deaths in the global population:
```sql
with cte as(
select continent, location, population, max(total_deaths) as max_death_country
from Covid_Deaths
where continent is not null
group by continent, location, population
)
select sum(cast(max_death_country as float))/sum(population) * 100 as death_percentage_entire_population
from cte
```
Purpose: Offers a macro-level understanding of the pandemic's impact.

8. Vaccination Analysis
   > Joins the Covid_Deaths and Covid_Vaccinations datasets to compare vaccination progress with cases and deaths:
```sql
--Joining covid_deaths and covid_vaccinations and checking vaccination details
select cd.location, cd.date, cd.total_cases, cd.population, cv.new_vaccinations
from Covid_Deaths as cd
join Covid_Vaccinations as cv
on cd.location = cv.location and cd.date = cv.date

-- Running sum of the new_vaccination by location/country
select location, date, new_vaccinations, sum(new_vaccinations) over(partition by location order by location, date) as running_sum_vaccination
from Covid_Vaccinations
where continent is not null
```
Purpose: Tracks vaccination trends and calculates the cumulative percentage of vaccinated populations.

9. Temporary Tables and Views
   > Temporary Table: #percentofpopulationvaccinated
     * Stores calculated vaccination percentages for quick access.
   ```sql
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
   ```
  > View: percentofpopulationvaccinated
   * A reusable query to extract vaccination statistics dynamically.
  ```sql
  create view percentofpopulationvaccinated as
  select cd.location, cd.date, cd.total_cases, cd.population, cv.new_vaccinations, 
  	sum(cv.new_vaccinations) over(partition by cv.location order by cv.location, cv.date) as running_sum_vaccination
  from Covid_Deaths as cd
  join Covid_Vaccinations as cv
  on cd.location = cv.location and cd.date = cv.date
  where cv.continent is not null
  
  select * 
  from percentofpopulationvaccinated
  ```
## Computed Metrics
- Death percentage.
- Case percentage.
- Death vs. population percentage.
- Cumulative vaccination percentage.

## Practical Use Cases of This Analysis
Health Policy Insights: Helps governments and organizations focus on high-impact regions.
Vaccine Strategy: Identifies gaps in vaccination coverage to optimize resource allocation.
Pandemic Trends: Tracks how the pandemic evolved across different geographies over time.
Global Comparisons: Provides a macro and micro view of COVID-19's impact on populations.
By blending basic queries with advanced analytics (CTEs, joins, and aggregate functions), the analysis delivers a comprehensive picture of the pandemic and vaccination efforts.














