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

-- priprava view pro ulozeni vypoctu prumerneho mezirocniho narustu cen potravin
CREATE OR REPLACE VIEW mezirocni_narust_pokles_cen_potravin AS
	WITH prumerne_ceny_potravin AS (
		SELECT
			rok
			, skupina
			, ROUND(AVG(hodnota), 2) AS prumerna_cena_rok
			, LAG(ROUND(AVG(hodnota), 2)) OVER (PARTITION BY skupina ORDER BY rok) AS prumerna_cena_predchozi_rok
		FROM t_michaela_schmiedova_project_SQL_primary_final
		WHERE typ = "potraviny"
		GROUP BY skupina, rok
	)
	SELECT
		rok
		, ROUND(AVG((prumerna_cena_rok - prumerna_cena_predchozi_rok) / prumerna_cena_predchozi_rok * 100), 2) AS mezirocni_narust_pokles_potraviny -- vypocet mezirocniho narustu/poklesu v procentech
		, "%" AS "jednotka_narustu_poklesu"
	FROM prumerne_ceny_potravin
	WHERE prumerna_cena_predchozi_rok IS NOT NULL -- zajisti nevypocitavani prvniho roku
	GROUP BY rok
;

-- kontrola view
SELECT *
FROM mezirocni_narust_pokles_cen_potravin
;

-- priprava view pro ulozeni vypoctu prumerneho mezirocniho narustu mezd
CREATE OR REPLACE VIEW mezirocni_narust_pokles_mezd AS
	WITH prumerne_mzdy AS (
		SELECT
			rok
			, skupina
			, ROUND(AVG(hodnota), 2) AS prumerna_mzda_rok
			, LAG(ROUND(AVG(hodnota), 2)) OVER (PARTITION BY skupina ORDER BY rok) AS prumerna_mzda_predchozi_rok
		FROM t_michaela_schmiedova_project_SQL_primary_final
		WHERE typ = "mzdy"
			AND hruba_mzda_x_pocet_zamestnanych = 'Průměrná hrubá mzda na zaměstnance'
			AND typ_kalkulace = "přepočtený"
		GROUP BY skupina, rok
	)
	SELECT
		rok
		, ROUND(AVG((prumerna_mzda_rok - prumerna_mzda_predchozi_rok) / prumerna_mzda_predchozi_rok * 100), 2) AS mezirocni_narust_pokles_mzdy -- vypocet mezirocniho narustu/poklesu v procentech
		, "%" AS "jednotka_narustu_poklesu"
	FROM prumerne_mzdy
	WHERE prumerna_mzda_predchozi_rok IS NOT NULL -- zajisti nevypocitavani prvniho roku
	GROUP BY rok
;

-- kontrola view
SELECT *
FROM mezirocni_narust_pokles_mezd
;

-- vyber mezirocniho narustu/poklesu cen potravin a mezirocniho narustu/podklesu mezd
SELECT
	npm.rok
	, mezirocni_narust_pokles_potraviny
	, mezirocni_narust_pokles_mzdy
	, npm.jednotka_narustu_poklesu
	, mezirocni_narust_pokles_potraviny - mezirocni_narust_pokles_mzdy AS "rozdil_narustu_cen_a_mezd"
FROM mezirocni_narust_pokles_cen_potravin AS npp
JOIN mezirocni_narust_pokles_mezd AS npm ON npm.rok = npp.rok
-- WHERE (mezirocni_narust_pokles_potraviny - mezirocni_narust_pokles_mzdy) > 10 -- kontrola, zda byl mezirocni narust cen potravin vetsi nez 10 % oproti rustu mezd
;

-- odstraneni obou views
DROP VIEW IF EXISTS mezirocni_narust_pokles_cen_potravin, mezirocni_narust_pokles_mezd
;
