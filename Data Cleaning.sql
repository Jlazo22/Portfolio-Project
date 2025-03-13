-- Data Cleaning
-- Data set from kaggle - https://www.kaggle.com/datasets/swaptr/layoffs-2022

SELECT *
FROM world_layoffs.layoffs;

-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null values or blank values
-- 4. Remove any columns - conditional

-- First creating a staging table

CREATE TABLE world_layoffs.layoffs_staging
LIKE world_layoffs.layoffs;

INSERT layoffs_staging
SELECT *
FROM world_layoffs.layoffs;

-- Removing duplicate

SELECT*
FROM world_layoffs.layoffs_staging;

-- This to check for no. of row for duplicates
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num 
FROM layoffs_staging;

-- To view rows with > 2 which means duplicate
SELECT*
FROM(
	SELECT *,
		ROW_NUMBER() OVER(
		PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num 
	FROM layoffs_staging) AS duplicates
WHERE 
	row_num > 1;

-- Making another table to delete 
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`,
	stage, country, funds_raised_millions) AS row_num 
FROM layoffs_staging;

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

-- Standardizing data

SELECT company, trim(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company); -- Updating company name and removing spaces

SELECT DISTINCT (industry)
FROM layoffs_staging2
ORDER BY 1; -- Checking all unique names, Crypto Currency has three the same type that needs to be standardized

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%'; -- Checking all industry that has crypto to check standard naming

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%'; -- Updating the Crypto industry into standardized Crypto name

-- Try to check each column for any errors

SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY 1;

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1; -- One of United States country has a '.' in the end

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country) -- Removing period
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%'; -- Updating USA

-- Transported raw data, date data is as text, fomatting it to date data
SELECT `date`,
str_to_date(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = str_to_date(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE; -- Altering date format


-- Null values or blank values

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = ''; -- If one of the industry doesn't have value or NULL, can check other data from that industry and can update using that information

SELECT t1.company, t2.company, t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL or t1.industry = '')
AND t2.industry IS NOT NULL; -- Joining makes it easier to see for each industry

-- Update the blanks into NULL then update industry
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num; -- Deleting column


