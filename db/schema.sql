CREATE DATABASE kampala_stores;

CREATE TABLE months (id serial primary key, month integer, total_profit integer, total_sold integer);

CREATE TABLE categories (id serial primary key, name varchar(20), total_profit integer, total_sold integer );

CREATE TABLE products (id serial primary key, name varchar(40), total_profit integer, total_sold integer );

CREATE TABLE sales_reports (id serial primary key, file_name varchar(100));