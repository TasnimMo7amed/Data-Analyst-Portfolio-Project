--1-select the data
use [Portfolio Project]
select location , date , total_cases , new_cases ,
total_deaths , population
from [Portfolio Project].dbo.CovidDeaths$
where continent is not null --= countries only
order by 1,2
---------------------------------------------------------------------------------------------
--2-looking at total cases VS total Death
select location , date , total_cases , total_deaths , ((total_deaths/total_cases)*100) as [Death percentage %]
from [Portfolio Project].dbo.CovidDeaths$
where continent is not null
order by 1,2
---------------------------------------------------------------------------------------------
--3-show the likelihood of dying in your country
select location , date , total_cases , total_deaths , ((total_deaths/total_cases)*100) as [Death percentage %]
from [Portfolio Project].dbo.CovidDeaths$
where location like '%yemen%'
and continent is not null
order by 1,2
---------------------------------------------------------------------------------------------
--4-looking at total cases VS population
select location , date , total_cases , population , ((total_cases/population)*100) as [covid percentage %]
from [Portfolio Project].dbo.CovidDeaths$
where continent is not null
order by 1,2
---------------------------------------------------------------------------------------------
--5-show what % of population got infection
select location , date , population , total_cases , ((total_cases/population)*100) as [infection percentage %]
from [Portfolio Project].dbo.CovidDeaths$
where location like '%yemen%'
and continent is not null
order by 1,2
---------------------------------------------------------------------------------------------
--6-looking @ the countries with highest infection rate compared with population
use [Portfolio Project]
select location , population , max (total_cases) as [highest infection countries] , max(total_cases/population)*100 as [highest infection percentage %]
from [Portfolio Project].dbo.CovidDeaths$
where continent is not null
group by location , population 
order by [highest infection percentage %] desc
---------------------------------------------------------------------------------------------
--7-Showing the countries with highes death count per population
use [Portfolio Project]
select location , population , max (cast(total_deaths as int)) as [highest death count countries] ,
--total deaths was casted due to data type issus
max(total_deaths/population)*100 as [highest death percentage %]
from [Portfolio Project].dbo.CovidDeaths$
where continent is not null 
group by location , population 
order by [highest death count countries] desc
---------------------------------------------------------------------------------------------
--8-Showing the continent with highes death count per population
use [Portfolio Project]
select location, max (cast(total_deaths as int)) as [highest death count continent] 
--total deaths was casted due to data type issus
from [Portfolio Project].dbo.CovidDeaths$
where continent is null --= continents only
group by location
order by [highest death count continent] desc
---------------------------------------------------------------------------------------------
--9-Showing the continent with highes death count per population
select location , population , max (cast(total_deaths as int)) as [highest death count continent] ,
--total deaths was casted due to data type issus
max(total_deaths/population)*100 as [highest death percentage %]
from [Portfolio Project].dbo.CovidDeaths$
where continent is null --= continent only
group by location , population 
order by [highest death count continent] desc
---------------------------------------------------------------------------------------------
--10-Gloubal Numbers
use [Portfolio Project]
select date , total_cases , new_cases , total_deaths ,new_deaths , 
(total_deaths/total_cases)*100 as [death percentage % ]
from [Portfolio Project].dbo.CovidDeaths$
where continent is not null --= countries only
order by 1,2
---------------------------------------------------------------------------------------------
--11-Gloubal New cases & New deaths
use [Portfolio Project]
select date , sum(new_cases) as [ Global New Cases ] , sum(cast(new_deaths as int)) as [ Global New Deaths ] 
from [Portfolio Project].dbo.CovidDeaths$
where continent is not null --= countries only
group by date 
order by 1,2
---------------------------------------------------------------------------------------------
--12-Gloubal death percentage %
use [Portfolio Project]
select date , sum(new_cases) as [ Global New Cases ] , sum(cast(new_deaths as int)) as [ Global New Deaths ]
,(sum(cast(new_deaths as int))/sum(new_cases))*100 as [gloubal death percentage %]
from [Portfolio Project].dbo.CovidDeaths$
where continent is not null --= countries only
group by date 
order by 1,2
---------------------------------------------------------------------------------------------
--13-Gloubal total cases
use [Portfolio Project]
select  sum(new_cases) as [ Global New Cases ] , sum(cast(new_deaths as int)) as [ Global New Deaths ]
,(sum(cast(new_deaths as int))/sum(new_cases))*100 as [gloubal death percentage %]
from [Portfolio Project].dbo.CovidDeaths$
where continent is not null --= countries only 
order by 1,2
---------------------------------------------------------------------------------------------
--14-Join Deaths Table VS Vaccs Table
select * from [Portfolio Project].dbo.CovidDeaths$ as Dea
join [Portfolio Project].dbo.CovidVaccinations$ as Vacc
on dea.location = vacc.location
and dea.date = vacc.date
---------------------------------------------------------------------------------------------
--15-looking @ total population VS Vaccsinations
select dea.continent , dea.location, dea.date, dea.population , vacc.new_vaccinations
from [Portfolio Project].dbo.CovidDeaths$ as Dea
join [Portfolio Project].dbo.CovidVaccinations$ as Vacc
on dea.location = vacc.location
and dea.date = vacc.date
order by 2,3
---------------------------------------------------------------------------------------------
--16-looking @ total population VS Vaccsinations in your country
select dea.continent , dea.location, dea.date, dea.population , vacc.new_vaccinations
from [Portfolio Project].dbo.CovidDeaths$ as Dea
join [Portfolio Project].dbo.CovidVaccinations$ as Vacc
on dea.location = vacc.location
and dea.date = vacc.date
where vacc.new_vaccinations is not null
and dea.continent is not null
and dea.location like '%canada%'
order by 3,2
---------------------------------------------------------------------------------------------
--17[Vaccinated people%]
--By Using CTE
with PopVSVac (continent,location,date,population ,new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent , dea.location, dea.date, dea.population , vacc.new_vaccinations ,
SUM(CONVERT(int ,vacc.new_vaccinations)) over (partition by dea.location order by dea.location , 
dea.date) as RollingPeopleVaccinated
from [Portfolio Project].dbo.CovidDeaths$ as Dea
join [Portfolio Project].dbo.CovidVaccinations$ as Vacc
on dea.location = vacc.location
and dea.date = vacc.date
where vacc.new_vaccinations is not null
and dea.continent is not null
)
select *,(RollingPeopleVaccinated/population)*100 as [Vaccinated people%]
 from PopVSVac
 order by 2,3
 -----
 --By USing TEMP TABLE
 Drop Table if exists #Vaccinatedpeople
 Create Table #Vaccinatedpeople
 (
 continent nvarchar(255),
 location nvarchar(255),
 Date datetime,
 population numeric,
 new_vaccinations numeric,
 RollingPeopleVaccinated numeric
 )
 insert into #Vaccinatedpeople
 select dea.continent , dea.location, dea.date, dea.population , vacc.new_vaccinations ,
SUM(CONVERT(int ,vacc.new_vaccinations)) over (partition by dea.location order by dea.location , 
dea.date) as RollingPeopleVaccinated
from [Portfolio Project].dbo.CovidDeaths$ as Dea
join [Portfolio Project].dbo.CovidVaccinations$ as Vacc
on dea.location = vacc.location
and dea.date = vacc.date
where vacc.new_vaccinations is not null
and dea.continent is not null
select *,(RollingPeopleVaccinated/population)*100 as [Vaccinated people%]
 from #Vaccinatedpeople
 order by 2,3
 -------------------------------------------------------------------
 --17-Creating &Calling View 
 create view [VacPop%] as
 select dea.continent , dea.location, dea.date, dea.population , vacc.new_vaccinations ,
SUM(CONVERT(int ,vacc.new_vaccinations)) over (partition by dea.location order by dea.location , 
dea.date) as RollingPeopleVaccinated
from [Portfolio Project].dbo.CovidDeaths$ as Dea
join [Portfolio Project].dbo.CovidVaccinations$ as Vacc
on dea.location = vacc.location
and dea.date = vacc.date
where vacc.new_vaccinations is not null
and dea.continent is not null
select * from [VacPop%]