-- priprava view pro prumerne mzdy v odvetvich dle let a kvartalu
CREATE OR REPLACE VIEW prumerna_mzda_x_odvetvi AS (
	SELECT
		"mzdy" AS "typ"
		, cp.payroll_year AS "rok"
		, e.GDP AS "rocni_HDP"
		, cp.payroll_quarter AS "kvartal_v_roce"
		, cpib.name AS "skupina"
		, cpvt.name AS "hruba_mzda_x_pocet_zamestnanych"
		, cp.value AS "hodnota"
		, cpu.name AS "jednotka"
		, NULL AS "merna_jednotka"
		, cpc.name AS "typ_kalkulace"
	FROM czechia_payroll AS cp
	JOIN czechia_payroll_industry_branch AS cpib ON cp.industry_branch_code = cpib.code
	JOIN czechia_payroll_unit AS cpu ON cp.unit_code = cpu.code
	JOIN czechia_payroll_value_type AS cpvt ON cp.value_type_code = cpvt.code
	JOIN czechia_payroll_calculation AS cpc ON cp.calculation_code = cpc.code
	JOIN economies AS e ON e.year = cp.payroll_year
	WHERE e.country LIKE "Czech%"
	ORDER BY cp.payroll_year, cp.payroll_quarter
)
;

-- kontrola, zda "date_from" a "date_to" nejsou v jiných letech
SELECT
	YEAR(cp.date_from) AS "rok_od"
	, YEAR(cp.date_to) AS "rok_do"
FROM czechia_price AS cp
WHERE YEAR(cp.date_from) != YEAR(cp.date_to)
;

-- priprava view pro prumernou cenu potravin dle let
CREATE OR REPLACE VIEW prumerna_cena_potravin AS (
	SELECT
		"potraviny" AS "typ"
		, YEAR(cp.date_from) AS "rok"
		, e.GDP AS "rocni_HDP"
		, NULL AS "kvartal_v_roce"
		, cpc.name AS "skupina"
		, NULL AS "hruba_mzda_x_pocet_zamestnanych"
		, cp.value AS "hodnota"
		, "Kč" AS "jednotka"
		, CONCAT(CAST(cpc.price_value AS CHAR), ' ', cpc.price_unit) AS "merna_jednotka"
		, NULL AS typ_kalkulace
	FROM czechia_price AS cp
	JOIN czechia_price_category AS cpc ON cp.category_code = cpc.code
	JOIN economies AS e ON e.year = YEAR(cp.date_from)
	WHERE e.country LIKE "Czech%"
	ORDER BY YEAR(cp.date_from)
)
;

-- priprava tabulky pro prumernou mzdu v odvetvych a prumernou cenu potravin dle let
CREATE TABLE t_michaela_schmiedova_project_SQL_primary_final AS (
	SELECT *
	FROM prumerna_mzda_x_odvetvi
	UNION ALL
	SELECT *
	FROM prumerna_cena_potravin
)
;

-- odstraneni obou views
DROP VIEW IF EXISTS prumerna_mzda_x_odvetvi, prumerna_cena_potravin
;

-- kontrola zaznamu ve vytvorene tabulce
SELECT *
FROM t_michaela_schmiedova_project_SQL_primary_final
;

-- odstraneni tabulky
DROP TABLE t_michaela_schmiedova_project_SQL_primary_final
;
