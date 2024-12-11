SELECT*
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 3,4

--SELECT*
--FROM PortfolioProject.dbo.CovidVaccinations
--ORDER BY 3,4

--Data selection 

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1,2

--Looking at total deaths vs total covid infections
--Likelihood of dying if covid infected in Sri Lanka

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%lanka%'
ORDER BY 1,2

--Looking at total cases vs population in Sri Lanka
--Percentage of population got covid

SELECT location,date,population,total_cases,(total_cases/population)*100 as InfectedPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%lanka%'
ORDER BY 1,2

--Looking at Countries with highest infection Rate compared to thier populations

SELECT location,population,MAX(total_cases) as HighestInfectionCount,(MAX(total_cases)/population)*100 as InfectedPercentage
FROM PortfolioProject.dbo.CovidDeaths
GROUP BY location,population
ORDER BY InfectedPercentage DESC

--Showing Countries with highest death count per population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
where continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--Showing Continents with highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
where continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Globally count of totaldeathspercentage

SELECT SUM(new_cases)as Total_cases,SUM(cast (new_deaths as int)) as total_deaths, SUM(cast( new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
where continent IS NOT NULL
ORDER BY 1,2

--Joining two tables
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CONVERT(INT,new_vaccinations))
OVER(PARTITION BY dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent IS NOT NULL
ORDER BY 2,3

-- Total Population vs vaccinations Using CTE
With PopvsVac(continent,location,date,population,new_vaccination,RollingPeopleVaccinated)
as
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CONVERT(INT,new_vaccinations))
OVER(PARTITION BY dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent IS NOT NULL
)

select* ,(RollingPeopleVaccinated/population)*100 as TotalVaccinatedPercentage
from PopvsVac

-- Total Population vs vaccinations Using Temp Table
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric)

Insert into #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CONVERT(INT,new_vaccinations))
OVER(PARTITION BY dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent IS NOT NULL

select* ,(RollingPeopleVaccinated/population)*100 as TotalVaccinatedPercentage
from #PercentPopulationVaccinated

--Creating view to store data for later visualization

Create view PercentPopulationVaccinated as
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CONVERT(INT,new_vaccinations))
OVER(PARTITION BY dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent IS NOT NULL

select*
from PercentPopulationVaccinated
