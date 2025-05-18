/*
čtvrtý projekt do Engeto Online Akademie

author: Michaela Schmiedová
email: michaela.schmiedova@email.cz
discord: misa_47996
*/

-- vyber prumerne ceny potravin za soucasny a predchozi rok vcetne mezirocniho narustu/poklesu cen
WITH prumerne_ceny_potravin AS (
	SELECT
		rok
		, skupina
		, ROUND(AVG(hodnota), 2) AS prumerna_cena_rok
		, LAG(ROUND(AVG(hodnota), 2)) OVER (PARTITION BY skupina ORDER BY rok) AS prumerna_cena_predchozi_rok
		, FIRST_VALUE(ROUND(AVG(hodnota), 2)) OVER (PARTITION BY skupina ORDER BY rok ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS prumerna_cena_prvni_rok
	FROM t_michaela_schmiedova_project_SQL_primary_final
	WHERE typ = 'potraviny'
	GROUP BY rok, skupina
)
SELECT
	rok
	, skupina AS "potravina"
	, prumerna_cena_rok
	, prumerna_cena_predchozi_rok
	, ROUND((prumerna_cena_rok - prumerna_cena_predchozi_rok) / prumerna_cena_predchozi_rok * 100, 1) AS mezirocni_narust_pokles -- meziroční změna
	, ROUND((prumerna_cena_rok - prumerna_cena_prvni_rok) / prumerna_cena_prvni_rok * 100, 1) AS narust_od_prvniho_roku -- změna oproti prvnímu roku
	, '%' AS jednotka_narustu_poklesu
FROM prumerne_ceny_potravin
ORDER BY skupina, rok
;