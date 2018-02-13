# Airline Company

## Task description
You are an architect of a database system for an airline company. Your task is to create database architecture and then to prove your solution is right by few sql queries as given later. When there are some concerns about how to implement some features, please put a comment in SQL, and we would discuss it later on. Your solution at the end should be 1 SQL file of PostgreSQL compatible code which contains both database structure, testing data and sample queries.

## Situation
In our database we want to be able to store data about Crew members and Aircrafts, each entity should have proper details which are derived from later description and needs. We also need to be able to assign crew members to aircraft, because we need to be able to determine which crew member has the experience with which aircraft to be later able to plan shifts and trainings. This means that every crew member could have experience with more than one aircraft and so on.

## Queries
*	Find name of the oldest crew member
*	Find name of the n-th crew member (second oldest, fifth oldest and so on)
*	Find name of the most experienced crew member - that one who knows most aircrafts
*	Find name of the least experienced crew member - that one who knows least aircrafts (counting from zero)

