#!/bin/bash
#read -p "Password: " -s PGPASSWORD
#export PGPASSWORD;
#echo #newline

# Let's use current user

dropdb cocacola
createdb cocacola
psql cocacola < cocacola.sql