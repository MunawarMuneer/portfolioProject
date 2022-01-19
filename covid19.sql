select *
from portfolioproject..['owid-covid-data_death$']
order by 3,4 
select *
from portfolioproject..['owid-covid-data_vaccination$']
order by 3,4

--selection of data

select location, date, total_cases,new_cases,total_deaths,population
from portfolioproject..['owid-covid-data_death$']
order by 1,2

--looking at total cases vs death

select location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as Deathpercentage
from portfolioproject..['owid-covid-data_death$']
where location like '%states%'
order by 1,2

 --looking at total cases vs population

select location, date, total_cases,population,(total_cases/population)*100 as deathpercentage
from portfolioproject..['owid-covid-data_death$']
where location like '%india%'
order by 1,2
--what country has highest infection rate

select location,population, max(total_cases) as Highestinfection_Count,max((total_cases/population))*100 as Highestinfection_rate
from portfolioproject..['owid-covid-data_death$']
Group by location,population
order by Highestinfection_rate desc

--what country has highest death count

select location, max(cast(total_deaths as int)) as totaldeath_count
from portfolioproject..['owid-covid-data_death$']
where continent is not null
Group by location
order by totaldeath_count desc

-- by continents

select continent, max(cast(total_deaths as int)) as totaldeath_count
from portfolioproject..['owid-covid-data_death$']
where continent is not null
Group by continent
order by totaldeath_count desc

-- resolving the continent

select continent, max(cast(total_deaths as int)) as totaldeath_count
from portfolioproject..['owid-covid-data_death$']
where continent is not null
Group by continent
order by totaldeath_count desc

--breaking global numbers

select sum(new_cases)as totalnewCases,sum(cast(new_deaths as int))as total_new_death,sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from portfolioproject..['owid-covid-data_death$']
where continent is not null
group by date

--total population vs total vaccination

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location,dea.date) as rollingPeopleVaccination
from portfolioproject..['owid-covid-data_death$'] dea
join portfolioproject..['owid-covid-data_vaccination$'] vac
 on dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null
 order by 2,3

 --cte
 with popVSvac (continent,Location,Date,population,New_vaccinations,Rolling_people_vaccinated)
 as
 (
 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as Rolling_People_Vaccinated
from portfolioproject..['owid-covid-data_death$'] dea
join portfolioproject..['owid-covid-data_vaccination$'] vac
 on dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null
 --order by 2,3
 )
 select *, (Rolling_people_vaccinated/population)*100
 from popVSvac

 --temp table 
 drop table if exists #percentpopulationVaccinated
 create table #percentpopulationVaccinated
 (
 continent nvarchar(255),
 location nvarchar(255),
 Date datetime,
 population numeric,
 New_vaccination numeric,
 Rolling_People_Vaccinated numeric
 )
 insert into #percentpopulationVaccinated
 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as Rolling_People_Vaccinated
from portfolioproject..['owid-covid-data_death$'] dea
join portfolioproject..['owid-covid-data_vaccination$'] vac
 on dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null
 --order by 2,3
 select *,(Rolling_People_Vaccinated/population)*100
 from #percentpopulationVaccinated

 --creating view to store data for later

 create view PercentPopulationVaccinated1 as
 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as Rolling_People_Vaccination
from portfolioproject..['owid-covid-data_death$'] dea
join portfolioproject..['owid-covid-data_vaccination$'] vac
 on dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null
 --order by 2,3
 select *
 from PercentPopulationVaccinated1
 