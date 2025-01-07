# ETL proces na databázu Chinook
Cieľom projektu je analyzovať údaje z hudobnej databázy Chinook a získať hodnotné poznatky pre optimalizáciu obchodných rozhodnutí. Projekt sa zameriava na kľúčové oblasti vrátane predaja, zákazníckej analýzy, efektivity zamestnancov a trendov v používaní playlistov. Na základe tejto analýzy sa navrhnú odporúčania na zlepšenie tržieb, efektivity a zákazníckej spokojnosti.

## 1. Úvod a popis zdrojových dát

### 1.1 Úvod a popis zdrojových dát
Tento projekt analyzuje databázu obsahujúcu informácie o skladbách, zákazníkoch, zamestnancoch, playlistoch a predajoch. 

### 1.2 Tabuľky a ich význam
1. **Artist**: Uchováva údaje o umelcoch (ID, meno).
2. **Album**: Obsahuje informácie o albumoch (ID, názov, umelec).
3. **Track**: Zameriava sa na skladby (ID, názov, album, žáner, cena, dĺžka).
4. **Genre**: Poskytuje kategórie hudobných žánrov.
5. **MediaType**: Uvádza typy médií (napr. MP3, AAC).
6. **Playlist**: Obsahuje zoznam playlistov (ID, názov).
7. **PlaylistTrack**: Prepája skladby s playlistmi.
8. **Customer**: Uchováva údaje o zákazníkoch (ID, meno, kontakty, región, pridelený zamestnanec).
9. **Invoice**: Informácie o faktúrach (ID, zákazník, dátum, fakturačné údaje, celková suma).
10. **InvoiceLine**: Detaily faktúr (ID, skladby, množstvo, cena).
11. **Employee**: Údaje o zamestnancoch (ID, meno, pozícia, dátum prijatia, nadriadený).

### 1.3 ERD diagram
Graf zobrazuje relačnú štruktúru hudobnej databázy, vrátane tabuliek a ich vzťahov:

1. Track, Album, Artist: Informácie o skladbách, albumoch a umelcoch.
2. Playlist, PlaylistTrack: Playlisty a ich skladby.
3. Customer, Invoice, InvoiceLine: Zákazníci, faktúry a predajné položky.
4. Employee: Zamestnanci a ich hierarchia.
5. Genre, MediaType: Žánre a formáty skladieb.

<p align="center">
  <img src="https://github.com/ZoltanPsenak/Chinook-ETL/blob/main/erd_schema.png" alt="ERD Schema">
  <br>
  <em>Obrázok 1 Entitno-relačná schéma Chinook</em>
</p>

---

## 2. Návrh dimenzionálneho modelu

# Dimenzionálny model pre hudobnú databázu

## Faktová tabuľka: Fact_InvoiceLine
Faktová tabuľka predstavuje jadro dimenzionálneho modelu, obsahujúce údaje o predaji jednotlivých skladieb na faktúrach.

### Hlavné metriky:
- **UnitPrice**: Cena za jednotku skladby.
- **Quantity**: Počet zakúpených jednotiek skladby.
- **TotalAmount**: Celková suma za danú skladbu (UnitPrice × Quantity).

### Primárne kľúče:
- **InvoiceLineId**: Jedinečný identifikátor fakturačnej položky.
- **InvoiceId**: Jedinečný identifikátor faktúry.
- **TrackId**: Jedinečný identifikátor skladby.

## Popis dimenzií

### 1. **Dim_Track**
- **Údaje**: Informácie o skladbách, ako názov, album, žáner, typ média, skladateľ, dĺžka trvania a cena.
- **Väzba na faktovú tabuľku**: Prepojenie cez TrackId, poskytuje kontext pre analýzu predaja jednotlivých skladieb.
- **Typ dimenzie**: SCD Typ 1 – údaje o skladbách sa zvyčajne nemenia historicky.

### 2. **Dim_Album**
- **Údaje**: Informácie o albumoch, ako názov albumu a jeho umelec.
- **Väzba na faktovú tabuľku**: Nepriame prepojenie cez TrackId → AlbumId, umožňuje analýzu predaja podľa albumov.
- **Typ dimenzie**: SCD Typ 1 – údaje o albumoch sa nemenia historicky.

### 3. **Dim_Artist**
- **Údaje**: Informácie o umelcoch, ako ich meno.
- **Väzba na faktovú tabuľku**: Nepriame prepojenie cez TrackId → AlbumId → ArtistId, umožňuje analýzu predaja podľa umelcov.
- **Typ dimenzie**: SCD Typ 1 – údaje o umelcoch sa nemenia historicky.

### 4. **Dim_Playlist**
- **Údaje**: Informácie o playlistoch, ako názov playlistu.
- **Väzba na faktovú tabuľku**: Prepojenie cez TrackId → PlaylistTrack → PlaylistId, umožňuje analýzu priemerného počtu skladieb na playlistoch.
- **Typ dimenzie**: SCD Typ 1 – údaje o playlistoch sa nemenia historicky.

### 5. **Dim_Customer**
- **Údaje**: Informácie o zákazníkoch, ako meno, priezvisko, adresa, kontaktné údaje a zástupca podpory.
- **Väzba na faktovú tabuľku**: Prepojenie cez CustomerId, umožňuje analýzu správania zákazníkov a predaja podľa regiónov.
- **Typ dimenzie**: SCD Typ 2 – údaje o zákazníkoch (napr. adresa) sa môžu meniť historicky.

### 6. **Dim_Invoice**
- **Údaje**: Informácie o faktúrach, ako dátum vystavenia, fakturačná adresa, krajina a celková suma faktúry.
- **Väzba na faktovú tabuľku**: Prepojenie cez InvoiceId, poskytuje kontext pre analýzu predaja podľa regiónov a trendov v čase.
- **Typ dimenzie**: SCD Typ 1 – údaje o faktúrach sa nemenia historicky.

### 7. **Dim_Employee**
- **Údaje**: Informácie o zamestnancoch, ako meno, titul, dátum narodenia, dátum prijatia a nadriadený.
- **Väzba na faktovú tabuľku**: Prepojenie cez EmployeeId, umožňuje analýzu výkonnosti zamestnancov a pracovného času.
- **Typ dimenzie**: SCD Typ 1 – údaje o zamestnancoch (napr. dátum prijatia) sa nemenia historicky.

### 8. **Dim_Genre**
- **Údaje**: Informácie o žánroch, ako názov žánru.
- **Väzba na faktovú tabuľku**: Prepojenie cez GenreId → TrackId, umožňuje analýzu predaja podľa žánrov.
- **Typ dimenzie**: SCD Typ 1 – údaje o žánroch sa nemenia historicky.

### 9. **Dim_MediaType**
- **Údaje**: Informácie o typoch médií, ako názov média.
- **Väzba na faktovú tabuľku**: Prepojenie cez MediaTypeId → TrackId, umožňuje analýzu predaja podľa typu média.
- **Typ dimenzie**: SCD Typ 1 – údaje o médiách sa nemenia historicky.
  <p align="center">
  <img src="https://github.com/ZoltanPsenak/Chinook-ETL/blob/main/star_schema.png" alt="Star Schema">
  <br>
  <em>Obrázok 2 Schéma hviezdy pre ChinookDB</em>
</p>

# 3. ETL proces 
ETL (Extract, Transform, Load) proces je kľúčový pre načítanie, transformáciu a nahrávanie dát do cieľovej databázy. V tomto prípade použijeme Snowflake na implementáciu ETL procesu.

## Hlavné kroky ETL procesu

1. **Extract (Extrahovanie)**
   - Načítanie dát z rôznych zdrojov (napr. CSV súbory, databázy).
2. **Transform (Transformácia)**
   - Čistenie a transformácia dát do požadovaného formátu.
3. **Load (Nahrávanie)**
   - Nahrávanie transformovaných dát do cieľovej databázy (Snowflake).

## Podrobný postup ETL procesu

### 1. Extract (Extrahovanie)

Načítanie dát z CSV súborov do Snowflake.

```sql
-- Vytvorenie stage pre načítanie CSV súborov
CREATE OR REPLACE STAGE my_stage
COPY INTO genre_staging
FROM @my_stage/genre.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);
```

### 2. Transform (Transformácia)
Čistenie a transformácia dát.
```sql
-- Vytvorenie dočasnej tabuľky pre načítané dáta
CREATE OR REPLACE TEMPORARY TABLE temp_table AS
SELECT
  $1 AS customer_id,
  $2 AS first_name,
  $3 AS last_name,
  $4 AS email,
  $5 AS phone,
  $6 AS invoice_id,
  $7 AS track_id,
  $8 AS unit_price,
  $9 AS quantity,
  $10 AS invoice_date,
  $11 AS employee_id,
  $12 AS album_id,
  $13 AS artist_id,
  $14 AS genre_id,
  $15 AS media_type_id,
  $16 AS playlist_id
FROM @my_stage (FILE_FORMAT => 'CSV');

-- Vytvorenie dimenzionálnych tabuliek
CREATE OR REPLACE TABLE dim_customer AS
SELECT DISTINCT
  customer_id,
  first_name,
  last_name,
  email,
  phone
FROM temp_table;

CREATE OR REPLACE TABLE dim_track AS
SELECT DISTINCT
  track_id,
  unit_price
FROM temp_table;

CREATE OR REPLACE TABLE dim_employee AS
SELECT DISTINCT
  employee_id,
  first_name,
  last_name,
  title,
  birth_date,
  hire_date,
  address,
  city,
  state,
  country,
  postal_code,
  phone,
  fax,
  email,
  reports_to
FROM temp_table;

CREATE OR REPLACE TABLE dim_album AS
SELECT DISTINCT
  album_id,
  title,
  artist_id
FROM temp_table;

CREATE OR REPLACE TABLE dim_artist AS
SELECT DISTINCT
  artist_id,
  name
FROM temp_table;

CREATE OR REPLACE TABLE dim_genre AS
SELECT DISTINCT
  genre_id,
  name
FROM temp_table;

CREATE OR REPLACE TABLE dim_media_type AS
SELECT DISTINCT
  media_type_id,
  name
FROM temp_table;

CREATE OR REPLACE TABLE dim_playlist AS
SELECT DISTINCT
  playlist_id,
  name
FROM temp_table;

-- Vytvorenie faktovej tabuľky
CREATE OR REPLACE TABLE fact_invoice_line AS
SELECT
  invoice_id,
  track_id,
  customer_id,
  employee_id,
  album_id,
  artist_id,
  genre_id,
  media_type_id,
  playlist_id,
  unit_price,
  quantity,
  invoice_date
FROM temp_table;
```

### 3. Load (Nahrávanie)
Nahrávanie transformovaných dát do cieľovej tabuľky v Snowflake.
```sql

-- Odstránenie dočasnej tabuľky
DROP TABLE temp_table;
DROP TABLE dim_customer;
DROP TABLE dim_track;
DROP TABLE dim_employee;
DROP TABLE dim_album;
DROP TABLE dim_artist;
DROP TABLE dim_genre;
DROP TABLE dim_media_type;
DROP TABLE dim_playlist;
DROP TABLE fact_invoice_line;
```
### Hlavné SQL príkazy použité v každom kroku ETL procesu
1. **Extract (Extrahovanie)**
CREATE OR REPLACE STAGE: Vytvorenie stage pre načítanie CSV súborov.
PUT: Načítanie CSV súborov do stage.
2. **Transform (Transformácia)**
CREATE OR REPLACE TEMPORARY TABLE: Vytvorenie dočasnej tabuľky pre načítané dáta.
SELECT: Výber a transformácia dát z dočasnej tabuľky.
3. **Load (Nahrávanie)**
CREATE OR REPLACE TABLE: Vytvorenie cieľovej tabuľky.
INSERT INTO: Nahrávanie dát do cieľovej tabuľky.
Tento postup zabezpečuje, že dáta sú načítané, transformované a nahraté do cieľovej databázy v Snowflake efektívne a správne
