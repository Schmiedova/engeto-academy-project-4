-- priprava view pro ulozeni vypoctu prumerne rocni ceny potravin
CREATE OR REPLACE VIEW rocni_prumerna_cena_potravin AS
	WITH prumerne_ceny_potravin AS (
		SELECT
			rok
			, skupina
			, ROUND(AVG(hodnota), 2) AS prumerna_cena_rok
		FROM t_michaela_schmiedova_project_SQL_primary_final
		WHERE typ = "potraviny"
		GROUP BY skupina, rok
	)
	SELECT
		rok
		, ROUND(AVG(prumerna_cena_rok), 2) AS prumerna_cena_potraviny_rok 
	FROM prumerne_ceny_potravin
	GROUP BY rok
;

-- priprava view pro ulozeni vypoctu prumerne rocni mzdy
CREATE OR REPLACE VIEW rocni_prumerna_mzda AS
	WITH prumerne_mzdy AS (
		SELECT
			rok
			, rocni_HDP
			, skupina
			, ROUND(AVG(hodnota), 2) AS prumerna_mzda_rok
		FROM t_michaela_schmiedova_project_SQL_primary_final
		WHERE typ = "mzdy"
			AND hruba_mzda_x_pocet_zamestnanych = 'Průměrná hrubá mzda na zaměstnance'
			AND typ_kalkulace = "přepočtený"
		GROUP BY skupina, rok
	)
	SELECT
		rok
		, rocni_HDP
		, ROUND(AVG(prumerna_mzda_rok), 2) AS prumerna_mzda_rok
	FROM prumerne_mzdy
	GROUP BY rok
;

SELECT
	rpm.rok
	, rpm.rocni_HDP
	, LAG(rpm.rocni_HDP) OVER (ORDER BY rpm.rok) AS "HDP_predchozi_rok"
	, rpm.prumerna_mzda_rok
	, rpcp.prumerna_cena_potraviny_rok
FROM rocni_prumerna_mzda AS rpm
LEFT JOIN rocni_prumerna_cena_potravin AS rpcp ON rpm.rok = rpcp.rok
;

-- odstraneni obou views
DROP VIEW IF EXISTS rocni_prumerna_cena_potravin, rocni_prumerna_mzda
;