/*steps-
remove duplicates
standardize the data
nul values or blank values
remove any column
*/

SELECT * FROM world_layoff.layoffs;

CREATE table layoff_staging like layoffs;

INSERT layoff_staging 
select * from layoffs;

select * from layoff_staging;

-- remove duplicates
#no identifier so add rownum partion -- temporary table
#hence write cte
WITH CTE_duplicate as (
select *, row_number() over(
partition by company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,
funds_raised_millions
) as row_num
from layoff_staging
)
select * from CTE_duplicate where
row_num>1;

#we can see duplicate
select * from layoff_staging where
company='Casper';

#create a new table
CREATE TABLE `layoff_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT into layoff_staging2
select *, row_number() over(
partition by company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,
funds_raised_millions
) as row_num
from layoff_staging;

select * from layoff_staging2 where row_num>1;

delete from layoff_staging2 where row_num>1;

-- standardizing data

select company,trim(company) from layoff_staging2;

update layoff_staging2
set company = trim(company);

select distinct industry from layoff_staging2;
-- crypto, cryptocurrencey must be same- update

update layoff_staging2
set industry = 'Crypto'
where industry like '%Crypto%';

select distinct location from layoff_staging2;
select distinct country from layoff_staging2;
-- united states and unites states.

update layoff_staging2
set country = TRIM(TRAILING '.' from country)
where country like 'United States%';

select `date`, str_to_date(`date`,'%m/%d/%Y');

update layoff_staging2
set `date` = str_to_date(`date`,'%m/%d/%Y');

alter table layoff_staging2
modify column `date` date;

-- working on null and blanks
select * from layoff_staging2
where industry is null or industry='';
/*
Airbnb
Bally's Interactive -- check
Carvana
Juul
*/

select * from layoff_staging2 where company='Airbnb';
-- self join can help to find missing values

update layoff_staging2
set industry=null
where industry='';

select t1.company,t1.location,t2.company,t2.location,t1.industry, t2.industry
from layoff_staging2 t1 join layoff_staging2 t2
on t1.company=t2.company
and t1.location=t2.location
where (t1.industry is null or t1.industry='')
and t2.industry is not null;


update layoff_staging2 t1 join layoff_staging2 t2
on t1.company=t2.company
set t1.industry=t2.industry
where (t1.industry is null or t1.industry='')
and t2.industry is not null;

select * from layoff_staging2 where company like '%Bally%';

select * from layoff_staging2
where total_laid_off is null
and percentage_laid_off is null;

delete from layoff_staging2
where total_laid_off is null
and percentage_laid_off is null;

select * from layoff_staging2;

alter table layoff_staging2
drop column row_num;