/*
Covid 19 Data Exploration 
*/

Select *
From [Covid Death & Vaccination] ..CovidDeaths
Where continent is not null 
order by 3,4


-- Select Data needed for exploration
Select Location, convert (date,date) as Date, total_cases, new_cases, total_deaths, population
From [Covid Death & Vaccination]..CovidDeaths
Where continent is not null 
order by 1,2


--SHOWING DATA BY COUNTRY

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if are infected by covid
Select continent, Location, convert(date,date) as date, total_cases,total_deaths, convert(decimal (20,10),(convert(float, total_deaths)/convert (float,total_cases))*100) as DeathPercentage
From [Covid Death & Vaccination]..CovidDeaths
--Where location like '%india%' or any other country (
where continent is not null
order by 1,2,3


-- Total Cases vs Population
-- Shows percentage of population infected with Covid
Select continent, Location, convert(date,date) as date, total_cases, Population, convert(decimal (20,10),(convert(float, total_cases)/convert (float,population))*100) as PercentPopulationInfected
From [Covid Death & Vaccination]..CovidDeaths
--Where location like '%india%' or any other country
where continent is not null
order by 1,2,3

--show Countries with Highest Infection Rate compared to Population
Select continent, Location, Population, Max (convert(decimal(20,0) , total_cases)) as HighestInfectedCount, max (convert(decimal (20,10),(convert(float, total_cases)/convert (float,population))*100)) as PercentPopulationInfected
From [Covid Death & Vaccination]..CovidDeaths
where continent is not null
--Where location like '%india%' or any other country
group by continent, location, population
order by PercentPopulationInfected desc

--showing country with Highest death count
Select Location, Population, Max (convert(decimal(20,0) , total_deaths)) as HighestDeathCount
From [Covid Death & Vaccination]..CovidDeaths
--Where location like '%india%' (or any other country)
where continent is not null
group by location, population
order by HighestDeathCount desc


--showing country with Highest death count for total polulation
Select continent, Location, Population, Max (convert(decimal(20,0) , total_deaths)) as HighestDeathCount,max (convert(decimal (20,10),(convert(float, total_deaths)/convert (float,population))*100)) as DeathPercentOfPopulation
From [Covid Death & Vaccination]..CovidDeaths
--Where location like '%india%' (or any other country)
where continent is not null
group by continent, location, population
order by HighestDeathCount desc




--SHOWING DATA BY CONTINENT

--showing continent with Highest death count
Select location, Max (cast( total_deaths as int)) as HighestDeathCount
From [Covid Death & Vaccination]..CovidDeaths
--Where location like '%asia%' --(or any other continent)
where continent is null and location not in ('international', 'European Union')
group by location
order by HighestDeathCount desc


-- WORLD WIDE DATA
SELECT convert(date, date) as date, SUM(cast(new_cases as int)) as CaseCount, SUM(cast(new_deaths as int)) as DeathCount,  round((SUM(convert(float, new_deaths))) / (SUM(convert(float, new_cases))), 10) * 100 as DeathPercentage   
FROM  [Covid Death & Vaccination]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY convert(date, date)
ORDER BY 1,2

--looking at entire dataset by joining both tables
Select *
From [Covid Death & Vaccination] ..CovidDeaths cd
JOIN [Covid Death & Vaccination] ..CovidVaccinations cv 
on cd.location = cv.location and cd.date = cv.date and cd.continent =cv.continent


--New Data to work with by JOINing the tables
select cd.continent,  cd.location, CONVERT(date, cd.date) as Date, cd.population, cv.new_vaccinations
FROM [Covid Death & Vaccination]..CovidDeaths cd
join [Covid Death & Vaccination]..CovidVaccinations cv 
ON cd.location = cv.location AND CONVERT(date, cd.date) = CONVERT(date, cv.date) AND cd.continent = cv.continent 
WHERE cd.continent IS NOT NULL
ORDER BY 2,3

--showing people vaccinated vs country on date basis
select cd.continent,  cd.location, CONVERT(date, cd.date) as Date, cd.population, cv.new_vaccinations,
SUM(Convert(int,cv.new_vaccinations))
over (partition by cd.location order  by CONVERT(date, cd.date)) as PeopleVaccinated
FROM [Covid Death & Vaccination]..CovidDeaths cd
join [Covid Death & Vaccination]..CovidVaccinations cv 
ON cd.location = cv.location AND CONVERT(date, cd.date) = CONVERT(date, cv.date) AND cd.continent = cv.continent 
WHERE cd.continent IS NOT NULL
ORDER BY 2,3

--Using CTE for People Vaccinated percentage
WITH PopulationVsVaccination (Continent, location, date, population, new_vaccinations, PeopleVaccinated) AS
(
SELECT cd.continent, cd.location,CONVERT(date, cd.date) as Date, CONVERT(int, cd.population) as population, cv.new_vaccinations,
SUM(CONVERT(float, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY CONVERT(date, cd.date)) as PeopleVaccinated
from [Covid Death & Vaccination]..CovidDeaths cd
join [Covid Death & Vaccination]..CovidVaccinations cv 
on cd.location = cv.location AND CONVERT(date, cd.date) = CONVERT(date, cv.date) AND cd.continent = cv.continent 
WHERE cd.continent IS NOT NULL
)
SELECT *,CONVERT(decimal(20,10), (PeopleVaccinated/ population) * 100) as VaccinatedPopulation
FROM PopulationVsVaccination;

--Temporary table for calculation People Vaccinated percentage

DROP TABLE IF EXISTS #PopulationVsVaccination;
CREATE TABLE #PopulationVsVaccination (
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,
    Population INT,
    New_vaccinations INT,
    PeopleVaccinated INT
);
Insert into #PopulationVsVaccination (Continent, Location, Date, Population, New_vaccinations, PeopleVaccinated)
select cd.continent,cd.location,CONVERT(DATE, cd.date) as DATE,CONVERT(INT, cd.population) as population,cv.new_vaccinations
,sum(CONVERT(FLOAT, cv.new_vaccinations)) over (partition by cd.location order by CONVERT(DATE, cd.date)) AS PeopleVaccinated
from [Covid Death & Vaccination]..CovidDeaths cd
inner join [Covid Death & Vaccination]..CovidVaccinations cv
on cd.location = cv.location AND CONVERT(DATE, cd.date) = CONVERT(DATE, cv.date) AND cd.continent = cv.continent
where cd.continent IS NOT NULL;
select *, CONVERT(DECIMAL(20, 10), (convert (float,PeopleVaccinated) / NULLIF(Population, 0)) * 100) AS VaccinatedPopulation
from #PopulationVsVaccination;




--Creating View to store data for visualization

create view DeathTableStats as
SELECT
	cd.continent, cd.Location, cd.Date, cd.total_cases,cd.total_deaths, cd.Population,
	CONVERT(DECIMAL(20, 10), (CONVERT(FLOAT, cd.total_cases) / NULLIF(CONVERT(FLOAT, cd.Population), 0)) * 100) AS PercentPopulationInfected,
    CONVERT(DECIMAL(20, 10), (CONVERT(FLOAT, cd.total_deaths) / NULLIF(CONVERT(FLOAT, cd.total_cases), 0)) * 100) AS DeathPercentageForInfected
-- Inorder to View all maximum the Death Table Stats
--    ,inf.HighestInfectedCount AS HighestInfectedCount
--    ,inf.PercentPopulationInfected AS PercentPopulationInfected_Max
--    ,max_deaths.HighestDeathCount AS HighestDeathCount
--    ,max_deaths.DeathPercentOfPopulation AS DeathPercentOfPopulation_Max
FROM [Covid Death & Vaccination]..CovidDeaths cd
LEFT JOIN
(
    SELECT continent,Location,Population,MAX(CONVERT(DECIMAL(20, 0), total_cases)) AS HighestInfectedCount,
	MAX(CONVERT(DECIMAL(20, 10), (CONVERT(FLOAT, total_cases) / NULLIF(CONVERT(FLOAT, population), 0)) * 100)) AS PercentPopulationInfected
    FROM [Covid Death & Vaccination]..CovidDeaths
    WHERE continent IS NOT NULL
    GROUP BY continent, Location, Population
)
	AS inf ON cd.continent = inf.continent AND cd.Location = inf.Location
LEFT JOIN
(
    SELECT Location, Population,
	MAX(CONVERT(DECIMAL(20, 0), total_deaths)) AS HighestDeathCount,
	MAX(CONVERT(DECIMAL(20, 10),(CONVERT(FLOAT, total_deaths) / NULLIF(CONVERT(FLOAT, population), 0)) * 100)) AS DeathPercentOfPopulation
    FROM [Covid Death & Vaccination]..CovidDeaths
    WHERE continent IS NOT NULL
    GROUP BY Location, Population
) 
	AS max_deaths --Name Of Aggrigated Table
	ON cd.Location = max_deaths.Location
WHERE cd.continent IS NOT NULL
ORDER BY cd.continent, cd.Location, cd.Date;



create view PopulationVsVaccination as
SELECT cd.continent,cd.location,CONVERT(DATE, cd.date) as Date,CONVERT(INT, cd.population) as population,cv.new_vaccinations
,SUM(CONVERT(FLOAT, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY CONVERT(DATE, cd.date)) AS PeopleVaccinated
FROM [Covid Death & Vaccination]..CovidDeaths cd
JOIN [Covid Death & Vaccination]..CovidVaccinations cv
ON cd.location = cv.location AND CONVERT(DATE, cd.date) = CONVERT(DATE, cv.date) AND cd.continent = cv.continent
WHERE cd.continent IS NOT NULL






