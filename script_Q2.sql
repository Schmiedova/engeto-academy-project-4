/*
čtvrtý projekt do Engeto Online Akademie

author: Michaela Schmiedová
email: michaela.schmiedova@email.cz
discord: misa_47996
*/

-- kontrola dat pro moznost vyuziti vazeneho prumeru
WITH prumerna_mzda_rok AS (
	-- vypocet prumerne mzdy napric obory a lety (zprumerovani napric rocnimi kvartaly)
	SELECT
		rok
		, skupina
		, ROUND(AVG(hodnota),2) AS prumerna_mzda_v_odvetvi
	FROM t_michaela_schmiedova_project_SQL_primary_final
	WHERE typ = "mzdy"
		AND typ_kalkulace = "přepočtený"
		AND jednotka = "Kč"
	GROUP BY rok, skupina
),
pocet_zamestnancu_rok AS (
	-- vypocet prumerneho poctu zamestnancu v oboru napric lety (zprumerovani napric rocnimi kvartaly)
	-- vysledek muze byt zavadejici kvuli chybejicim hodnotam v datasetu
	SELECT
		rok
		, skupina
		, ROUND(AVG(hodnota), 2) * 1000 AS "pocet_zamestnancu"
	FROM t_michaela_schmiedova_project_SQL_primary_final
	WHERE typ = "mzdy"
		AND typ_kalkulace = "přepočtený"
		AND jednotka = "tis. osob (tis. os.)"
	GROUP BY rok, skupina
)
SELECT
	pmr.rok
	, pmr.skupina
	, pmr.prumerna_mzda_v_odvetvi
	, pzr.pocet_zamestnancu
FROM prumerna_mzda_rok AS pmr
JOIN pocet_zamestnancu_rok AS pzr ON pzr.skupina = pmr.skupina
GROUP BY pmr.rok, pmr.skupina
;

-- vyber prumerne mzdy v jednotlivych letech u prepocteneho poctu zamestnancu u prvniho a posledniho srovnatelneho obdobi
WITH mzdy AS (
	SELECT 
	    rok
	    , ROUND(AVG(hodnota), 2) AS prumerna_mzda
	FROM t_michaela_schmiedova_project_SQL_primary_final
	WHERE typ = 'mzdy'
		AND hruba_mzda_x_pocet_zamestnanych = 'Průměrná hrubá mzda na zaměstnance'
		AND typ_kalkulace = "přepočtený"
		AND rok IN (
			(SELECT MIN(rok) FROM t_michaela_schmiedova_project_SQL_primary_final WHERE typ = "potraviny") -- vyber prvniho srovnatelneho obdobi
			, (SELECT MAX(rok) FROM t_michaela_schmiedova_project_SQL_primary_final WHERE typ = "potraviny") -- vyber posledniho srovnatelneho obdobi
		)
	GROUP BY rok
),
-- vyber prumerne ceny chleba a mleka v jednotlivych letech u prvniho a posledniho srovnatelneho obdobi
potraviny AS (
	SELECT
		rok
	    , skupina
	    , ROUND(AVG(CASE WHEN skupina = 'Chléb konzumní kmínový' THEN hodnota END), 2) AS prumerna_cena_chleba_v_kc
	    , ROUND(AVG(CASE WHEN skupina = 'Mléko polotučné pasterované' THEN hodnota END), 2) AS prumerna_cena_mleko_v_kc
	FROM t_michaela_schmiedova_project_SQL_primary_final
	WHERE typ = 'potraviny'
		AND skupina IN ('Chléb konzumní kmínový','Mléko polotučné pasterované')
		AND rok IN (
			(SELECT MIN(rok) FROM t_michaela_schmiedova_project_SQL_primary_final WHERE typ = "potraviny") -- vyber prvniho srovnatelneho obdobi
			, (SELECT MAX(rok) FROM t_michaela_schmiedova_project_SQL_primary_final WHERE typ = "potraviny") -- vyber posledniho srovnatelneho obdobi
		)
	GROUP BY rok, skupina
)
SELECT 
    m.rok
    , m.prumerna_mzda
    -- sjednoceni hodnot na jeden radek
    , ROUND(m.prumerna_mzda / MAX(CASE WHEN p.skupina = 'Chléb konzumní kmínový' THEN p.prumerna_cena_chleba_v_kc END), 2) AS pocet_kg_chleba
    , ROUND(m.prumerna_mzda / MAX(CASE WHEN p.skupina = 'Mléko polotučné pasterované' THEN p.prumerna_cena_mleko_v_kc END), 2) AS pocet_litru_mleka
FROM mzdy AS m
JOIN potraviny AS p ON m.rok = p.rok
GROUP BY m.rok
ORDER BY m.rok
;