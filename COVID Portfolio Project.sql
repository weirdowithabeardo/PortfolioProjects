
Select *
From PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
order by 3,4

--Select *
--From PortfolioProject.dbo.CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths

Select Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From PortfolioProject.dbo.CovidDeaths
Where location = 'philippines'
and continent is not null
order by 1,2

-- Looking at Total Cases vs Population
-- Shows percentage of population that got covid

Select Location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths
--Where location = 'philippines'
order by 1,2

-- Countries with highest infection rate compared to population

Select Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths
--Where location = 'philippines'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC

-- Countries with highest death count compared per population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
--Where location = 'philippines'
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- By Continent

--Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
--From PortfolioProject.dbo.CovidDeaths
----Where location = 'philippines'
--WHERE continent is not null
--GROUP BY continent
--ORDER BY TotalDeathCount DESC

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
--Where location = 'philippines'
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Global Numbers

Select SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
--Where location = 'philippines'
WHERE continent is null
--GROUP BY date
ORDER BY 1,2

-- Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date =vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- USING CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeoplevaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date =vac.date
WHERE dea.continent is not null
-- ORDER BY 2,3
)

Select *, (RollingPeoplevaccinated/population)*100
FROM PopvsVac

-- Temp Table

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
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date =vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

Select *, (RollingPeoplevaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Creating View to store for later visualizations
GO
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date =vac.date
WHERE dea.continent is not null
-- ORDER BY 2,3
GO
Select *
From PercentPopulationVaccinated

DROP VIEW PercentPopulationVaccinated