/*
čtvrtý projekt do Engeto Online Akademie

author: Michaela Schmiedová
email: michaela.schmiedova@email.cz
discord: misa_47996
*/

-- priprava tabulky s detaily o evropskych statech
CREATE TABLE t_michaela_schmiedova_project_SQL_secondary_final AS (
	SELECT
		e.YEAR AS "rok"
		, c.country AS "země"
		, e.GDP AS "rocni_HDP"
		, e.gini AS "GINI koeficient"
		, e.population AS "populace"
	FROM countries AS c
	LEFT JOIN economies AS e ON e.country = c.country
	WHERE c.continent = "Europe"
		AND e.YEAR IN (
			SELECT distinct(rok)
			FROM t_michaela_schmiedova_project_SQL_primary_final
		)
)
;

-- kontrola zaznamu ve vytvorene tabulce
SELECT *
FROM t_michaela_schmiedova_project_SQL_secondary_final
;

-- odstraneni tabulky
DROP TABLE t_michaela_schmiedova_project_SQL_secondary_final
;