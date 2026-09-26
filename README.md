# COVID-19 Data Exploration in SQL

This is a guided SQL practice project based on [Alex The Analyst's Data Analyst Portfolio Project tutorial](https://www.youtube.com/watch?v=qfyynHBFOsM). I followed the video to explore COVID-19 cases, deaths, population and vaccination data. The project idea and source data are from the tutorial.

## What the script covers

- Comparing total cases with deaths and population, including a Brazil filter in one query.
- Grouping infection and death figures by location, continent and date.
- Joining the CovidDeaths and CovidVaccinations tables on location and date.
- Practising aggregate functions, TRY_CONVERT, a date-ordered window function, a CTE, a temporary table and a view.

## File and setup

[covid19_exploration.sql](covid19_exploration.sql) contains the queries. They use SQL Server syntax and refer to the `PortfolioProject` database with `CovidDeaths` and `CovidVaccinations` tables. The source datasets are not included in this repository; load the datasets linked in the tutorial into SQL Server before running the script. Run statements in sections, since it contains several separate explorations and a view definition.

The script calculates a running sum of reported new vaccinations by location and date. Its ratio to population represents reported vaccination doses per 100 people, not the percentage of distinct people vaccinated. This repository contains practice queries, not a reproducible report or verified current COVID-19 findings.

## Tools and learning source

Microsoft SQL Server / T-SQL. Guided practice following [Alex The Analyst's SQL data exploration video](https://www.youtube.com/watch?v=qfyynHBFOsM).
