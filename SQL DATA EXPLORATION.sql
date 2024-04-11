select location,date,total_cases,new_cases,total_deaths,population
from CovidDeaths
order by 1,2

-- total cases vs total deaths 


select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage 
from CovidDeaths
where location = 'india' 
order by 1,2

-- looking at total cases vs population, how many got covid 

select location,date,population,total_cases,(total_cases/population)*100 as CovidPercentage 
from CovidDeaths
where location = 'india' 
order by 1,2

-- looking at countries with highest infecton rate

select location,population,max(total_cases) as maxinfection,Max(total_cases/population)*100 as infectionPercentage 
from CovidDeaths
group by population,location
order by infectionPercentage desc 

-- showing countries with highest death counts 

select location, MAX(cast(total_deaths as int)) as deaths
from CovidDeaths
where continent is not null
group by location
order by deaths desc

-- Looking by continents 

select continent, MAX(cast(total_deaths as int)) as deaths
from CovidDeaths
where continent is not null
group by continent
order by deaths desc

-- showing continents with the highest death count as per population

select continent, MAX(cast(total_deaths as int)) as deaths
from CovidDeaths
where continent is not null
group by continent
order by deaths desc 

-- Global Numbers 

select date, sum(new_cases)as Total_Cases,sum(cast(new_deaths as int)) AS Total_Deaths, sum(new_cases)/sum(cast(new_deaths as int)) as DeathPercentage 
from CovidDeaths
where continent is not null
group by date
order by 1

-- total popualtion vs vaccination

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as newvac
from CovidDeaths dea
join CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null 
 order by 2,3
 
 -- USE CTE 

 With POPvsVAC ( cntinent,location,date ,population,new_vaccinations, newvac)
 as
 (
 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as newvac
from CovidDeaths dea
join CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null 
-- order by 2,3
 )
 select * , (newvac/population)*100 as percentage
 from POPvsVAC

 -- Temp table
 drop table if exists #perentpop
 create table #percentpop
 ( continent nvarchar(255),
   location nvarchar(255),
   date datetime,
   population numeric,
   New_vaccinations numeric, 
   newvac numeric)
 Insert into #percentpop
 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as newvac
from CovidDeaths dea
join CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
-- where dea.continent is not null 
-- order by 2,3

select * , (newvac/population)*100
from #percentpop

-- Creating View to Store data

create view percentpop as
 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as newvac
from CovidDeaths dea
join CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
where dea.continent is not null 

-- Executing view


select * 
from percentpop



 



