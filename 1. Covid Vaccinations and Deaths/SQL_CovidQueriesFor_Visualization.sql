--SQL QUERIES TO GET RELEVANT DATA FOR VISUALIZATION

Select SUM(cast(new_cases as int)) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(convert(float ,New_Cases))*100 as DeathPercentage
From [Covid Death & Vaccination]..CovidDeaths
--Where location like '%india%'
where continent is not null 
order by 1,2
------------------------------------------------------------------------------------------------------------------------------------

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From [Covid Death & Vaccination]..CovidDeaths
--Where location like '%india%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc
------------------------------------------------------------------------------------------------------------------------------------

SELECT 
    Location, Population, 
    MAX(CAST(total_cases AS INT)) AS HighestInfectionCount,  
    MAX((CONVERT(NUMERIC, total_cases) * 100) / NULLIF(CONVERT(NUMERIC, population), 0)) AS PercentPopulationInfected
FROM [Covid Death & Vaccination]..CovidDeaths
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC;
------------------------------------------------------------------------------------------------------------------------------------

Select 
	Location, Population,convert (date ,date) as Date,
    MAX(convert(int,total_cases)) as HighestInfectionCount,
	Max(convert(numeric,total_cases)/convert (numeric,population))*100 as PercentPopulationInfected
From [Covid Death & Vaccination]..CovidDeaths
--Where location like '%india%'
Group by Location, Population, date
order by PercentPopulationInfected desc
------------------------------------------------------------------------------------------------------------------------------------