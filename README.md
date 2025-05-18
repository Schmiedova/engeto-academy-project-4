# Projekt 4: Data o mzdách a cenách potravin a jejich zpracování pomocí SQL

## Popis

Tento projekt vznikl s cílem připravit datové podklady, které umožní odpovědět na klíčové výzkumné otázky zaměřené na **dostupnost základních potravin v České republice** v kontextu vývoje mezd a makroekonomických ukazatelů v čase. Vytvořeno jako čtvrtý projekt do Engeto Online Akademie.

---

## Cíle projektu

- Zjistit, jak se v průběhu let mění mzdy v jednotlivých odvětvích.
- Porovnat, kolik základních potravin (mléko, chléb) bylo možné koupit za průměrnou mzdu na začátku a konci sledovaného období.
- Identifikovat potravinu s nejpomalejším meziročním růstem cen.
- Detekovat roky, ve kterých byl růst cen potravin výrazně vyšší než růst mezd (o více než 10 %).
- Prozkoumat vztah mezi vývojem HDP a vývojem mezd a cen potravin.

---

## Použitá data

Projekt využívá následující datové sady:

### Primární tabulky:
- `czechia_payroll` – mzdy podle odvětví
- `czechia_price` – ceny vybraných potravin
- doplňující číselníky: `czechia_payroll_calculation`, `czechia_payroll_industry_branch`, `czechia_payroll_unit`, `czechia_payroll_value_type`, `czechia_price_category`

### Číselníky územních jednotek:
- `czechia_region`
- `czechia_district`

### Dodatečná data pro evropské státy:
- `countries`
- `economies` – HDP, GINI koeficient, populace apod.

---

## Výstupy

Výstupem projektu jsou dvě hlavní tabulky pro získání dat k zodpovězení výzkumných otázek:

1. **`t_michaela_schmiedova_project_SQL_primary_final`**  
   - Obsahuje sjednocená data o mzdách a cenách potravin v ČR za společné roky.

   Postup při vytváření:
   
   1. Připrava view `prumerna_mzda_x_odvetvi` pro uložení dat týkajících se průměrné mzdy napříč odvětvími v průběhu let (sloupce připraveny na kompatibilitu s view `prumerna_cena_potravin`)
   2. Kontrola, zda se data určující cenu potravin v průběhu roku nenachází v rozdílných letech -> ne, můžeme tedy `date_from` použít pro sjednodení ceny potravin na roky
   2. Příprava view `prumerna_cena_potravin` pro uložení dat týkajících se průměrné ceny potravin v průběhu let (sloupce připraveny na kompatibilitu s view `prumerna_mzda_x_odvetvi`)
   3. Příprava tabulky `t_michaela_schmiedova_project_SQL_primary_final` s uloženými daty z obou views - sjednocené na roky
   4. Odstranění obou views `DROP VIEW IF EXISTS prumerna_mzda_x_odvetvi, prumerna_cena_potravin`

2. **`t_michaela_schmiedova_project_SQL_secondary_final`**  
   - Obsahuje doplňující makroekonomická data (HDP, GINI, populace) pro další evropské státy.

   Postup při vytváření:

   1. Příprava tabulky `t_michaela_schmiedova_project_SQL_secondary_final` s údaji o evropských státech sjednocené na stejné srovnatelné odbobí jako tabulka `t_michaela_schmiedova_project_SQL_primary_final`

---

## Výzkumné otázky

Projekt odpovídá na následující otázky:

1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období?
3. Která kategorie potravin zdražuje nejpomaleji (nejnižší meziroční nárůst)?
4. Existuje rok, kdy růst cen potravin výrazně překročil růst mezd (> 10 %)?
5. Ovlivňuje změna HDP vývoj mezd a cen potravin (ve stejném či následujícím roce)?

---

## Výsledky výzkumných otázek

### 1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

- **Pozorování:** V průběhu sledovaného období (2006–2018) mzdy v naprosté většině odvětví rostly. Výjimky tvoří pouze jednotlivé roky s minimální stagnací.
- **Zajímavost:** Největší nárůst mezd je patrný ve státní sféře (např. zdravotnictví, školství) a také ve zpracovatelském průmyslu.
- **Závěr:** Mzdy rostou konzistentně napříč sektory, žádný dlouhodobý pokles nebyl zaznamenán.

---

### 2️. Kolik je možné si koupit litrů mléka a kilogramů chleba za průměrnou mzdu v prvním a posledním srovnatelném období?

- **Roky porovnání:** 2006 vs. 2018
- **Chléb (kg):**
  - 2006: cca **1312,98 kg**
  - 2018: cca **1365,16 kg**
- **Mléko (l):**
  - 2006: cca **1465,73 l**
  - 2018: cca **1669,6 l**
- **Závěr:** Dostupnost základních potravin vzrostla, mzdy rostly rychleji než ceny chleba a mléka.

---

### 3️. Která kategorie potravin zdražuje nejpomaleji (má nejnižší meziroční nárůst)?

- **Pozorování:**
   - Data pro Jakostní víno bílé jsou dostupná až od roku 2015.
   - Data pro ostatní potraviny jsou dostupná v rámci období 2006-2018.
- **Nejpomaleji zdražující potraviny z hlediska ceny:**
  - Cukr krystalový
  - Rajská jablka červená kulatá
  - Banány žluté
- **Zajímavost:** Cukr a rajská jablka vykazují negativní meziroční změny, v některých letech dokonce zlevnili.
- **Závěr:** Tyto položky jsou cenově nejstabilnější a rostou pomaleji než jiné potraviny (např. máslo, těstoviny, papriky).

---

### 4️. Existuje rok, kdy byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (více než 10 %)?

- **Ne**, žádný takový rok nebyl zaznamenán.
- Nejvíce nepříznivý rok z pohledu nárůstu cen potravin byl rok **2013**, kdy rozdíl nárůstu cen a mezd dosáhl **6,79**

---

### 5️. Má výška HDP vliv na změny ve mzdách a cenách potravin?

- **Pozorování:**
  - Ve většině případů růst HDP koreluje s růstem mezd ve stejném nebo následujícím roce.
  - Vztah mezi HDP a cenami potravin je méně přímý – růst HDP nevede nutně k růstu cen.
  - Data k roční průměrné mzdě i k HDP jsou dostupná v rámci období 2000-2020.
  - Data k průměrné ceně potravin jsou dostupná v rámci období 2006-2018.
- **Zajímavost:** V roce 2009 došlo k poklesu HDP a zároveň stagnaci mezd – potvrzuje to závislost v krizových letech.
- **Závěr:** Růst HDP se projevuje primárně ve mzdách, méně pak v cenách potravin.

---

## Struktura repozitáře

```
engeto-academy-project-4/
│
├── README.md                      # Popis projektu a dokumentace
├── graphs.xlsx                    # Vizuální grafy pro prezentaci výsledků
│
├── script_Q1.sql                  # Dotaz k výzkumné otázce č. 1
├── script_Q2.sql                  # Dotaz k výzkumné otázce č. 2
├── script_Q3.sql                  # Dotaz k výzkumné otázce č. 3
├── script_Q4.sql                  # Dotaz k výzkumné otázce č. 4
├── script_Q5.sql                  # Dotaz k výzkumné otázce č. 5
│
├── script_table_primary.sql       # Skript pro vytvoření primární tabulky (ČR: mzdy + ceny potravin)
└── script_table_secondary.sql     # Skript pro vytvoření sekundární tabulky (evropské státy, HDP, GINI, populace)
```

---

## Instalace

1. Naklonujte si repozitář:
   ```bash
   git clone https://github.com/Schmiedova/engeto-academy-project-4.git
   cd engeto-academy-project-4
   ```

2. Ověřte, že ve složce máte následující soubory:
- `README.md`
- `graphs.xlsx`
- `script_Q1.sql`
- `script_Q2.sql`
- `script_Q3.sql`
- `script_Q4.sql`
- `script_Q5.sql`
- `script_table_primary.sql`
- `script_table_secondary.sql`

> Všechny SQL skripty je možné spouštět v prostředí kompatibilním se SQL (např. DBeaver, BigQuery, PostgreSQL podle datových zdrojů). Excel soubor `graphs.xlsx` slouží pro vizuální prezentaci výstupních dat.

---

## Poznámky ke skriptům
- `script_Q1.sql`
   - před samotným výpočtem kontroluje, zda dataset neobsahuje žádné hodnoty
   - ve výsledku zohledňuje fyzický i přepočtený počet zaměstnanců

- `script_Q2.sql`
   - pro výpočet používá pouze průměrnou mzdu na přepočtený počet zaměstnanců, protoře bývá přesnějším ukazatelem skutečných nákladů/mzdy za plný úvazek
   - pro korektní výpočet průměrné mzdy je vhodné použít vážený průměr - kontroluje, zda je možné využít vážený průměr
   - výsledek ukazuje, že chybí údaje o počtu zaměstnanců v odvětvích, vážený průměr tedy nelze použít, pro výpočet tedy používá aritmetický průměr

- `script_Q4.sql`
   - pro korektní výpočet průměrné mzdy napříč odvětvími je vhodné použít vážený průměr - kontroluje, zda je možné využít vážený průměr
   - výsledek ukazuje, že chybí údaje o počtu zaměstnanců v odvětvích, vážený průměr tedy nelze použít, pro výpočet tedy používá aritmetický průměr
   - obsahuje dotazy pro přípravu dvou views, kontrolu dat ve views a odstranění views + finální dotaz pro získání dat

- `script_Q5.sql`
   - obsahuje dotazy pro přípravu dvou views, kontrolu dat ve views a odstranění views + finální dotaz pro získání dat

---

## Použité nástroje

- SQL (MariaDB)
- datové zdroje: Portál otevřených dat ČR, mezinárodní makroekonomické databáze

---

## Autor

Michaela Schmiedová
- Engeto Online Akademie
- email: michaela.schmiedova@email.cz
- discord: misa_47996