-- Exploratory Data Analysis
-- Exploring data to find trends and/or patterns and outliers

Select *
FROM layoffs_staging2;

-- Looking at highest of total layoffs
Select MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

-- Looking at the companies who had 100% laid off
Select *
FROM layoffs_staging2
WHERE percentage_laid_off = 1;

-- Looking at the company highest total laid off where 100% were laid off
Select *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

--  Companies with the most Total Layoffs
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Locations with the most total layoffs
SELECT location, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY location
ORDER BY 2 DESC
LIMIT 10;

-- Date Ranges
Select MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

-- Industries with the most total layoffs
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- Countries with the most total layoffs
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- Year with the most total layoffs
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC; -- Total Sum of layoffs by year

-- Progression of layoffs - Rolling Sum

SELECT SUBSTRING(`date`,1,7) AS `MONTH`, -- getting the 1st number from date and getting seven values
	   SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;

-- Rolling Total
WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`,1,7) AS `MONTH`,
	   SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, total_off, SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;

-- Ranking company with highest lay off per year

SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS
(
SELECT *, 
	DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5;