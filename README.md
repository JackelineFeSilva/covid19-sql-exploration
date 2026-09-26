# COVID-19 Data Exploration in SQL

This is a guided SQL practice project based on [Alex The Analyst's Data Analyst Portfolio Project tutorial](https://www.youtube.com/watch?v=qfyynHBFOsM). I followed the video to explore COVID-19 cases, deaths, population and vaccination data. The project idea and source data are from the tutorial.

## What the script covers

- Comparing total cases with deaths and population, including a Brazil filter in one query.
- Grouping infection and death figures by location, continent and date.
- Joining the CovidDeaths and CovidVaccinations tables on location and date.
- Practising aggregate functions, TRY_CONVERT, a date-ordered window function, a CTE, a temporary table and a view.

## Data and setup

The tutorial provides the original Excel files: [CovidDeaths.xlsx](https://github.com/AlexTheAnalyst/PortfolioProjects/blob/main/CovidDeaths.xlsx) and [CovidVaccinations.xlsx](https://github.com/AlexTheAnalyst/PortfolioProjects/blob/main/CovidVaccinations.xlsx). Both are availabe in the Alex The Analyst's repository.

[covid19_exploration.sql](covid19_exploration.sql) contains SQL Server queries for a `PortfolioProject` database with tables named `CovidDeaths` and `CovidVaccinations`. Import the two spreadsheets into those tables before running the queries. Run the script in sections; it includes several separate explorations, a temporary table and a view definition.

The script calculates a running sum of reported new vaccinations by location and date. Its ratio to population represents reported vaccination doses per 100 people, not the percentage of distinct people vaccinated. This repository contains practice queries, not a reproducible report or verified current COVID-19 findings.

## Tools and learning source

Excel and Microsoft SQL Server.
