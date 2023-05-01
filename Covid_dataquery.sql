
-- death percentage

SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS decimal(10,2))/total_cases))*100 AS death_percentage
FROM [dbo].[Covid_deaths]
WHERE location IN ('United states')
ORDER BY 1,2 ;

--- percentage of population that got infected in 2021

SELECT location, date, total_cases, population,  (CAST(total_cases AS decimal(10,2))/population)*100 AS percentage_infected
FROM [dbo].[Covid_deaths]
WHERE location IN ('United states') and YEAR(date) = '2021'
ORDER BY 1,2 ;

--Looking for countries with highest infection rate compared to its population
SELECT location, population, MAX(total_cases) AS Highest_infection_count,
	(CAST(MAX(total_cases) AS DECIMAL(18, 2)) / population) * 100 AS percent_pop_infected
FROM [dbo].[Covid_deaths]
WHERE YEAR(date)='2021'
GROUP BY location, population
ORDER BY percent_pop_infected DESC
;

-- Showing highest death count per population

-- By Continent
SELECT continent, MAX(total_deaths) AS total_death_count	
FROM [dbo].[Covid_deaths]
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC;


-- Total population vs vaccinations

WITH popvacc AS (
  SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations,
    SUM(CAST(vacc.new_vaccinations AS int)) OVER(partition by death.location ORDER BY death.location, death.date) as cummulative_vacced
  FROM [dbo].[Covid_deaths] as death
  JOIN [dbo].[Covid_vaccinations] as vacc
  ON death. location = vacc.location and death.date = vacc.date
  where death.location = 'United States' and death.continent IS NOT NULL 
)
SELECT *, (CAST(cummulative_vacced as decimal(18,2))/population)*100 as perc_vacced
FROM popvacc;

--Creating View to store data for later visualizations

CREATE VIEW Percpopvaccinated AS
WITH popvacc AS (
    SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations,
        SUM(CAST(vacc.new_vaccinations AS int)) OVER(partition by death.location ORDER BY death.location, death.date) as cummulative_vacced
    FROM [dbo].[Covid_deaths] as death
    JOIN [dbo].[Covid_vaccinations] as vacc
    ON death.location = vacc.location and death.date = vacc.date
    WHERE death.location = 'United States' and death.continent IS NOT NULL 
)
SELECT *, (CAST(cummulative_vacced as decimal(18,2))/population)*100 as perc_vacced
FROM popvacc;
