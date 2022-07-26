lilSelect *
From PortfoliProject..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From PortfoliProject..Sheet1$
--order by 3,4

Select Location, date,total_cases,new_cases, total_deaths, population
From PortfoliProject..CovidDeaths
order by 1,2

--Looking at Total Caea vs Total Deaths

Select Location, date,total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfoliProject..CovidDeaths
Where location like '%states%'
order by 1,2

--Looking at Total Cases vs Population
Select Location, date,total_cases, Population, (total_cases/population)*100 as CasesPerPopulation
From PortfoliProject..CovidDeaths
--Where location like '%states%'
order by 1,2

--looking at countries with Highest Infection Rtae compared to Population
Select Location, Population ,MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as
 PercentPopulationInfected
From PortfoliProject..CovidDeaths
Group by Location, Population 
--Where location like '%states%'
order by  PercentPopulationInfected desc

-- Countries with highest deaths Counts per Population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount 
From PortfoliProject..CovidDeaths
Where continent is not null
Group by Location 
--Where location like '%states%'
order by  TotalDeathCount desc

--Grouping by 
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
From PortfoliProject..CovidDeaths
Where continent is not null
Group by continent 
--Where location like '%states%'
order by  TotalDeathCount desc

--Global Numbers
Select  date,SUM(new_cases) as Total_of_Cases, SUM(cast(new_deaths as int)) as Total_Deaths,
SUM(cast(new_deaths as int))/ SUM(New_Cases) as DeathPercentage
From PortfoliProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group By date
order by 1,2


--Looking at Total Population vs Vaccinations
Select *
From PortfoliProject..CovidDeaths dea
Join PortfoliProject..CovidVaccinations  vac
 On dea.location = vac.location
 and dea.date = vac.date
 

Select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location,dea.Date)
as RollingPeopleVaccinations
From PortfoliProject..CovidDeaths dea
Join PortfoliProject..CovidVaccinations  vac
   On dea.location = vac.location
   and dea.date = vac.date
 where dea.continent is not null
 order by 2,3
 
 
--USE CTE

With PopvsVac(Continent,Location, Date, Population,new_vaccinations, RollingPeopleVaccinations)
as
(
Select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location,dea.Date)
as RollingPeopleVaccinations
From PortfoliProject..CovidDeaths dea
Join PortfoliProject..CovidVaccinations  vac
   On dea.location = vac.location
   and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3
)

Select * ,(RollingPeopleVaccinations/Population)*100
From PopvsVac

--Temp Table

DROP Table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated

(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinations numeric
)

Insert into #PercentagePopulationVaccinated
Select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,dea.Date)
as RollingPeopleVaccinations
From PortfoliProject..CovidDeaths dea
Join PortfoliProject..CovidVaccinations  vac
   On dea.location = vac.location
   and dea.date = vac.date
 --where dea.continent is not null
 order by 2,3

Select * ,(RollingPeopleVaccinations/Population)*100
From #PercentagePopulationVaccinated


-- Creating View to store data for visualization

Create View PercentagePopulationVaccinated1 as 
Select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,dea.Date)
as RollingPeopleVaccinations
From PortfoliProject..CovidDeaths dea
Join PortfoliProject..CovidVaccinations  vac
   On dea.location = vac.location
   and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3

 Select *
 From PercentagePopulationVaccinated1