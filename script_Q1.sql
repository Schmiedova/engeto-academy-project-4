-- kontrola datasetu zda neobsahuje prazdne hodnoty
SELECT COUNT(*) AS pocet_null
FROM t_michaela_schmiedova_project_SQL_primary_final
WHERE hruba_mzda_x_pocet_zamestnanych = 'Průměrná hrubá mzda na zaměstnance'
  AND hodnota IS NULL
;

-- priprava datasetu pro zobrazeni rustu/poklesu mezd v odvetvich (rozdeleno dle prumerny fyzicky pocet zamestnancu a prumerny prepocteny pocet zamestnancu)
WITH rocni_mzdy_zprumerovany AS (
	SELECT
	  rok
	  , skupina
	  , AVG(CASE WHEN typ_kalkulace = 'fyzický' THEN hodnota ELSE NULL END) AS prumerna_rocni_mzda_fyzicky
	  , AVG(CASE WHEN typ_kalkulace = 'přepočtený' THEN hodnota ELSE NULL END) AS prumerna_rocni_mzda_prepocteny
	FROM t_michaela_schmiedova_project_SQL_primary_final
	WHERE hruba_mzda_x_pocet_zamestnanych = 'Průměrná hrubá mzda na zaměstnance'
		AND typ = "mzdy"
	GROUP BY rok, skupina
	ORDER BY skupina, rok
)
-- vyber prumerne rocni mzdy v odvetvich za soucasny a predchozi rok vcetne stavu
SELECT
    rok
    , skupina AS "Odvětví"
    , prumerna_rocni_mzda_fyzicky
    , LAG(prumerna_rocni_mzda_fyzicky) OVER (PARTITION BY skupina ORDER BY rok) AS mzda_predchozi_rok_fyzicky
    , CASE
        WHEN prumerna_rocni_mzda_fyzicky > LAG(prumerna_rocni_mzda_fyzicky) OVER (PARTITION BY skupina ORDER BY rok) THEN 'zvýšení'
        WHEN prumerna_rocni_mzda_fyzicky < LAG(prumerna_rocni_mzda_fyzicky) OVER (PARTITION BY skupina ORDER BY rok) THEN 'snížení'
        ELSE 'žádná změna'
    END AS stav_proti_predchozimu_roku_fyzicky
    , prumerna_rocni_mzda_prepocteny
    , LAG(prumerna_rocni_mzda_prepocteny) OVER (PARTITION BY skupina ORDER BY rok) AS mzda_predchozi_rok_prepocteny
    , CASE
        WHEN prumerna_rocni_mzda_prepocteny > LAG(prumerna_rocni_mzda_prepocteny) OVER (PARTITION BY skupina ORDER BY rok) THEN 'zvýšení'
        WHEN prumerna_rocni_mzda_prepocteny < LAG(prumerna_rocni_mzda_prepocteny) OVER (PARTITION BY skupina ORDER BY rok) THEN 'snížení'
        ELSE 'žádná změna'
    END AS stav_proti_predchozimu_roku_prepocteny
FROM rocni_mzdy_zprumerovany
ORDER BY skupina, rok
;