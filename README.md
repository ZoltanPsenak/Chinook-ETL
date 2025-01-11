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

1. **Track, Album, Artist**: Informácie o skladbách, albumoch a umelcoch.
2. **Playlist, PlaylistTrack**: Playlisty a ich skladby.
3. **Customer, Invoice, InvoiceLine**: Zákazníci, faktúry a predajné položky.
4. **Employee**: Zamestnanci a ich hierarchia.
5. **Genre, MediaType**: Žánre a formáty skladieb.

<p align="center">
  <img src="https://github.com/ZoltanPsenak/Chinook-ETL/blob/main/erd_schema.png" alt="ERD Schema">
  <br>
  <em>Obrázok 1 Entitno-relačná schéma Chinook</em>
</p>

---

## 2. Návrh dimenzionálneho modelu

### Dimenzionálny model pre hudobnú databázu

## Faktová tabuľka: Fact_InvoiceLine
Faktová tabuľka predstavuje jadro dimenzionálneho modelu, obsahujúce údaje o predaji jednotlivých skladieb na faktúrach.

### Hlavné metriky:
- **UnitPrice**: Cena za jednotku skladby.
- **Quantity**: Počet zakúpených jednotiek skladby.
- **InvoiceDate**: Dátum faktúry

### Primárne kľúče:
- **InvoiceLineId**: Jedinečný identifikátor fakturačnej položky.

### Cudzie kľúče:
- **InvoiceId**: Jedinečný identifikátor faktúry.
- **TrackId**: Jedinečný identifikátor skladby.
- **CustomerId**: Jedinečný identifikátor zakazníka.
- **EmployeeId**: Jedinečný identifikátor zamestnanca.
- **AlbumId**: Jedinečný identifikátor albumu.
- **MediaTypeId**: Jedinečný identifikátor typu medii.
- **PlaylistId**: Jedinečný identifikátor playlistu.
- **DateId**: Jedinečný identifikátor dátumu.

  
---

### Popis dimenzií

### 1. **Dim_Track**
- **Údaje**: Informácie o skladbách, ako názov, album, žáner, typ média, skladateľ, dĺžka trvania a cena.
- **Väzba na faktovú tabuľku**: Prepojenie cez TrackId, poskytuje kontext pre analýzu predaja jednotlivých skladieb.
- **Typ dimenzie**: SCD Typ 1 – údaje o skladbách sa zvyčajne nemenia historicky.

### 2. **Dim_Album**
- **Údaje**: Informácie o albumoch, ako názov albumu a jeho umelec.
- **Väzba na faktovú tabuľku**: Nepriame prepojenie cez TrackId → AlbumId, umožňuje analýzu predaja podľa albumov.
- **Typ dimenzie**: SCD Typ 1 – údaje o albumoch sa nemenia historicky.

### 3. **Dim_Playlist**
- **Údaje**: Informácie o playlistoch, ako názov playlistu.
- **Väzba na faktovú tabuľku**: Prepojenie cez TrackId → PlaylistTrack → PlaylistId, umožňuje analýzu priemerného počtu skladieb na playlistoch.
- **Typ dimenzie**: SCD Typ 1 – údaje o playlistoch sa nemenia historicky.

### 4. **Dim_Customer**
- **Údaje**: Informácie o zákazníkoch, ako meno, priezvisko, adresa, kontaktné údaje a zástupca podpory.
- **Väzba na faktovú tabuľku**: Prepojenie cez CustomerId, umožňuje analýzu správania zákazníkov a predaja podľa regiónov.
- **Typ dimenzie**: SCD Typ 2 – údaje o zákazníkoch (napr. adresa) sa môžu meniť historicky.

### 5. **Dim_Invoice**
- **Údaje**: Informácie o faktúrach, ako dátum vystavenia, fakturačná adresa, krajina a celková suma faktúry.
- **Väzba na faktovú tabuľku**: Prepojenie cez InvoiceId, poskytuje kontext pre analýzu predaja podľa regiónov a trendov v čase.
- **Typ dimenzie**: SCD Typ 1 – údaje o faktúrach sa nemenia historicky.

### 6. **Dim_Employee**
- **Údaje**: Informácie o zamestnancoch, ako meno, titul, dátum narodenia, dátum prijatia a nadriadený.
- **Väzba na faktovú tabuľku**: Prepojenie cez EmployeeId, umožňuje analýzu výkonnosti zamestnancov a pracovného času.
- **Typ dimenzie**: SCD Typ 1 – údaje o zamestnancoch (napr. dátum prijatia) sa nemenia historicky.

### 7. **Dim_MediaType**
- **Údaje**: Informácie o typoch médií, ako názov média.
- **Väzba na faktovú tabuľku**: Prepojenie cez MediaTypeId → TrackId, umožňuje analýzu predaja podľa typu média.
- **Typ dimenzie**: SCD Typ 1 – údaje o médiách sa nemenia historicky.
  <p align="center">
  <img src="https://github.com/ZoltanPsenak/Chinook-ETL/blob/main/star_schema.png" alt="Star Schema">
  <br>
  <em>Obrázok 2 Schéma hviezdy pre ChinookDB</em>
</p>

## 3. ETL proces 
ETL (Extract, Transform, Load) proces je kľúčový pre načítanie, transformáciu a nahrávanie dát do cieľovej databázy. V tomto prípade použijeme Snowflake na implementáciu ETL procesu.

### Hlavné kroky ETL procesu

### 3.1 Extrahovanie (Extract)

Tento proces sa zameriava na načítanie dát z CSV súborov do Snowflake. Používame Snowflake "staging" pre dočasné ukladanie súborov a následné kopírovanie dát do cieľovej tabuľky. Tento postup zabezpečuje efektívne spracovanie veľkých datasetov a umožňuje jednoduché prepojenie s dátovými zdrojmi vo formáte CSV.

### Kroky

1. **Vytvorenie stage pre načítanie CSV súborov**
   
   Stage slúži ako dočasné úložisko pre súbory, ktoré chceme importovať. V nasledujúcom príklade vytvárame stage `my_stage`:

   ```sql
   CREATE OR REPLACE STAGE my_stage;
   ```

2. **Načítanie dát z CSV do tabuľky**

   Dátové súbory sa kopírujú do cieľovej staging tabuľky pomocou príkazu `COPY INTO`. Tento príkaz umožňuje priamo definovať formát súborov a ďalšie potrebné parametre, ako je preskakovanie hlavičky alebo špecifikácia obalovacích znakov.

   ```sql
   COPY INTO genre_staging
   FROM @my_stage/genre.csv
   FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);
   ```


### 3.2 Transform (Transformácia)

V procese ETL (Extract, Transform, Load) transformácia predstavuje stredný krok, kde sa dáta transformujú z formátu a štruktúry zdrojových systémov na cieľový formát, ktorý lepšie podporuje analýzu a reportovanie. Tento proces zahŕňa čistenie, agregáciu, obohacovanie a normalizáciu dát.

Nižšie je rozpis jednotlivých dimenzií a faktov v rámci transformácie, vrátane ich účelu a uchovávaných atribútov.

### Dimenzie

### Dim_Track
Táto dimenzia obsahuje informácie o skladbách.

- **Účel**: Umožňuje analyzovať skladby podľa žánrov, skladateľov alebo ceny.
- **Atribúty**:
  - `TrackId`: Jedinečný identifikátor skladby.
  - `Name`: Názov skladby.
  - `Genre`: Názov žánru skladby (napr. Rock, Pop).
  - `Composer`: Skladateľ skladby.
  - `Milliseconds`: Trvanie skladby v milisekundách.
  - `Bytes`: Veľkosť skladby v bajtoch.
  - `UnitPrice`: Cena skladby.

```sql
CREATE TABLE Dim_Track AS
SELECT
    tr.TrackId,
    tr.Name,
    gr.Name AS Genre,
    tr.Composer,
    tr.Milliseconds,
    tr.Bytes,
    tr.UnitPrice
FROM Track_staging tr
JOIN Genre_staging gr ON tr.GenreId = gr.GenreId;
```

### Dim_Album
Táto dimenzia obsahuje informácie o albumoch.

- **Účel**: Poskytuje údaje o albumoch a ich interpretoch.
- **Atribúty**:
  - `AlbumId`: Jedinečný identifikátor albumu.
  - `Artist`: Meno interpreta.
  - `Title`: Názov albumu.

```sql
CREATE TABLE Dim_Album AS
SELECT
    al.AlbumId,
    ar.Name AS Artist,
    al.Title
FROM Album_staging al
JOIN Artist_staging ar ON al.ArtistId = ar.ArtistId;
```

### Dim_MediaType
Táto dimenzia obsahuje typy médií, na ktorých sú skladby dostupné.

- **Účel**: Umožňuje kategorizáciu skladieb podľa typu média (napr. MPEG audio, Protected AAC audio).
- **Atribúty**:
  - `MediaTypeId`: Jedinečný identifikátor typu média.
  - `Name`: Názov typu média.

```sql
CREATE TABLE Dim_MediaType AS
SELECT
    mt.MediaTypeId,
    mt.Name
FROM MediaType_staging mt;
```

### Dim_Playlist
Táto dimenzia obsahuje informácie o playlistoch.

- **Účel**: Poskytuje údaje o playlistoch, ktoré môžu obsahovať viacero skladieb.
- **Atribúty**:
  - `PlaylistId`: Jedinečný identifikátor playlistu.
  - `Name`: Názov playlistu.

```sql
CREATE TABLE Dim_Playlist AS
SELECT
    pl.PlaylistId,
    pl.Name
FROM Playlist_staging pl;
```

### Dim_Customer
Táto dimenzia obsahuje informácie o zákazníkoch.

- **Účel**: Umožňuje analýzu zákazníkov na základe demografických údajov alebo kontaktov.
- **Atribúty**:
  - `CustomerId`: Jedinečný identifikátor zákazníka.
  - `FirstName`, `LastName`: Meno a priezvisko zákazníka.
  - `Company`: Spoločnosť, ktorú zákazník reprezentuje.
  - `Address`, `City`, `State`, `Country`, `PostalCode`: Adresa zákazníka.
  - `Phone`, `Fax`, `Email`: Kontaktné údaje zákazníka.
  - `SupportRepId`: Identifikátor zamestnanca podpory.

```sql
CREATE TABLE Dim_Customer AS
SELECT
    cu.CustomerId,
    cu.FirstName,
    cu.LastName,
    cu.Company,
    cu.Address,
    cu.City,
    cu.State,
    cu.Country,
    cu.PostalCode,
    cu.Phone,
    cu.Fax,
    cu.Email,
    cu.SupportRepId
FROM Customer_staging cu;
```

### Dim_Employee
Táto dimenzia obsahuje informácie o zamestnancoch.

- **Účel**: Umožňuje analýzu zamestnancov podľa ich pozícií, dátumov narodenia a zamestnania.
- **Atribúty**:
  - `EmployeeId`: Jedinečný identifikátor zamestnanca.
  - `FirstName`, `LastName`: Meno a priezvisko zamestnanca.
  - `Title`: Pozícia zamestnanca.
  - `BirthDate`, `HireDate`: Dátumy narodenia a zamestnania.
  - `Address`, `City`, `State`, `Country`, `PostalCode`: Adresa zamestnanca.
  - `Phone`, `Fax`, `Email`: Kontaktné údaje zamestnanca.
  - `ReportsTo`: Nadriadený zamestnanec.

```sql
CREATE TABLE Dim_Employee AS
SELECT
    em.EmployeeId,
    em.FirstName,
    em.LastName,
    em.Title,
    em.BirthDate,
    em.HireDate,
    em.Address,
    em.City,
    em.State,
    em.Country,
    em.PostalCode,
    em.Phone,
    em.Fax,
    em.Email,
    em.ReportsTo
FROM Employee_staging em;
```

### Dim_Invoice
Táto dimenzia obsahuje informácie o faktúrach.

- **Účel**: Umožňuje analýzu fakturácie a výdavkov zákazníkov.
- **Atribúty**:
  - `InvoiceId`: Jedinečný identifikátor faktúry.
  - `CustomerId`: Identifikátor zákazníka.
  - `InvoiceDate`: Dátum vystavenia faktúry.
  - `BillingAddress`, `BillingCity`, `BillingState`, `BillingCountry`, `BillingPostalCode`: Fakturačné údaje.
  - `Total`: Celková suma faktúry.

```sql
CREATE TABLE Dim_Invoice AS
SELECT
    inv.InvoiceId,
    inv.CustomerId,
    inv.InvoiceDate,
    inv.BillingAddress,
    inv.BillingCity,
    inv.BillingState,
    inv.BillingCountry,
    inv.BillingPostalCode,
    inv.Total
FROM Invoice_staging inv;
```

### Dim_Date
Táto dimenzia obsahuje informácie o dátumoch.

- **Účel**: Poskytuje kalendárne informácie na časovú analýzu dát.
- **Atribúty**:
  - `DateId`: Jedinečný identifikátor dátumu.
  - `Year`, `Month`, `Day`: Rok, mesiac a deň.
  - `Date`: Dátum v štandardnom formáte.

```sql
CREATE TABLE Dim_Date AS
SELECT DISTINCT
    ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS DateId,
    EXTRACT(YEAR FROM inv.InvoiceDate) AS Year,
    EXTRACT(MONTH FROM inv.InvoiceDate) AS Month,
    EXTRACT(DAY FROM inv.InvoiceDate) AS Day,
    CAST(inv.InvoiceDate AS DATE) AS Date
FROM Invoice_staging inv;
```

### Fakty

### Fact_InvoiceLine
Táto faktová tabuľka obsahuje podrobné informácie o položkách faktúr.

- **Účel**: Poskytuje podrobnosti o jednotlivých položkách faktúr pre detailné finančné analýzy.
- **Atribúty**:
  - `Fact_InvoiceLineId`: Jedinečný identifikátor riadku faktúry.
  - `UnitPrice`: Cena položky.
  - `Quantity`: Počet položiek.
  - `InvoiceId`: Identifikátor faktúry.
  - `TrackId`: Identifikátor skladby.
  - `DateId`: Identifikátor dátumu.
  - `EmployeeId`: Identifikátor zamestnanca.
  - `PlaylistId`: Identifikátor playlistu.
  - `AlbumId`: Identifikátor albumu.
  - `MediaTypeId`: Identifikátor typu média.
  - `CustomerId`: Identifikátor zákazníka.
  - `InvoiceDate`: Dátum faktúry.

```sql
CREATE TABLE Fact_InvoiceLine AS
SELECT
    il.InvoiceLineId AS Fact_InvoiceLineId,
    il.UnitPrice AS UnitPrice,
    il.Quantity AS Quantity,
    di.InvoiceId AS InvoiceId,
    dt.TrackId AS TrackId,
    dd.DateId AS DateId,
    de.EmployeeId AS EmployeeId,
    dp.PlaylistId AS PlaylistId,
    dal.AlbumId AS AlbumId,
    dmt.MediaTypeId AS MediaTypeId,
    dc.CustomerId AS CustomerId,
    inv.InvoiceDate AS InvoiceDate
FROM InvoiceLine_staging il
JOIN Invoice_staging inv ON il.InvoiceId = inv.InvoiceId
JOIN Dim_Customer dc ON inv.CustomerId = dc.CustomerId
JOIN Dim_Track dt ON il.TrackId = dt.TrackId
JOIN Dim_Invoice di ON il.InvoiceId = di.InvoiceId
JOIN Dim_Date dd ON CAST(di.InvoiceDate AS DATE) = dd.Date
JOIN Dim_Employee de ON dc.SupportRepId = de.EmployeeId
LEFT JOIN Track_staging tr ON il.TrackId = tr.TrackId
LEFT JOIN PlaylistTrack_staging pt ON il.TrackId = pt.TrackId
LEFT JOIN Dim_Playlist dp ON pt.PlaylistId = dp.PlaylistId
LEFT JOIN Album_staging al ON tr.AlbumId = al.AlbumId
LEFT JOIN Dim_Album dal ON al.AlbumId = dal.AlbumId
LEFT JOIN Dim_MediaType dmt ON tr.MediaTypeId = dmt.MediaTypeId;
```


### 3.3 Load (Nahrávanie)
Nahrávanie transformovaných dát do cieľovej tabuľky v Snowflake.
```sql

-- Odstránenie dočasnej tabuľky
DROP TABLE Artist_staging;
DROP TABLE Album_staging;
DROP TABLE MediaType_staging;
DROP TABLE Genre_staging;
DROP TABLE Track_staging;
DROP TABLE Playlist_staging;
DROP TABLE PlaylistTrack_staging;
DROP TABLE Employee_staging;
DROP TABLE Customer_staging;
DROP TABLE Invoice_staging;
DROP TABLE InvoiceLine_staging;
```
## 4. Vizualizácia dát

Tento dokument obsahuje prehľad SQL dotazov na analýzu a vizualizáciu dát v dátovom sklade. Každý dotaz odpovedá na konkrétnu obchodnú otázku a pomáha pri získavaní prehľadov.

<p align="center">
  <img src=https://github.com/ZoltanPsenak/Chinook-ETL/blob/main/dashboard_chinook.png alt="Dashboard">
  <br>
  <em>Obrázok 3 Dashboard pre ChinookDB</em>
</p>

### 4.1 Priemerný počet skladieb na jednom playliste

Tento dotaz vypočíta priemerný počet skladieb, ktoré sú priradené k playlistom.

```sql
SELECT 
    AVG(TrackCount) AS AverageTracksPerPlaylist
FROM (
    SELECT 
        PlaylistId, 
        COUNT(TrackId) AS TrackCount
    FROM Fact_InvoiceLine
    GROUP BY PlaylistId
);
```

- **Účel**: Zistiť, aký je priemerný počet skladieb na jednom playliste.
- **Výstup**: Priemerný počet skladieb vo forme jednej číselnej hodnoty.

### 4.2 Zákazníci, ktorí minuli najviac peňazí

Tento dotaz identifikuje zákazníkov, ktorí minuli najviac peňazí na produkty.

```sql
SELECT 
    dc.CustomerId, 
    dc.FirstName, 
    dc.LastName, 
    SUM(il.UnitPrice * il.Quantity) AS TotalSpent
FROM Fact_InvoiceLine il
JOIN Dim_Customer dc ON il.CustomerId = dc.CustomerId
GROUP BY dc.CustomerId, dc.FirstName, dc.LastName
ORDER BY TotalSpent DESC;
```

- **Účel**: Identifikovať zákazníkov s najväčšími výdavkami.
- **Výstup**: Zoznam zákazníkov zoradený podľa celkových výdavkov v zostupnom poradí.

### 4.3 Trend nakupovania podľa regiónu (štátu, krajiny)

Tento dotaz analyzuje trendy predaja podľa regiónu a času (rok a mesiac).

```sql
SELECT 
    dc.Country, 
    dc.State, 
    EXTRACT(YEAR FROM inv.InvoiceDate) AS Year, 
    EXTRACT(MONTH FROM inv.InvoiceDate) AS Month, 
    SUM(inv.Total) AS TotalSales
FROM Dim_Invoice inv
JOIN Dim_Customer dc ON inv.CustomerId = dc.CustomerId
GROUP BY dc.Country, dc.State, Year, Month
ORDER BY dc.Country, dc.State, Year, Month;
```

- **Účel**: Sledovať trendy predaja na základe regiónov a časových období.
- **Výstup**: Tabuľka s údajmi o predaji podľa krajiny, štátu, roka a mesiaca.

### 4.4 Zamestnanci, ktorí spracovali najviac objednávok (Invoices)

Tento dotaz identifikuje zamestnancov podľa počtu spracovaných objednávok.

```sql
SELECT 
    de.EmployeeId, 
    de.FirstName, 
    de.LastName, 
    COUNT(inv.InvoiceId) AS TotalInvoices
FROM Dim_Invoice inv
JOIN Dim_Customer dc ON inv.CustomerId = dc.CustomerId
JOIN Dim_Employee de ON dc.SupportRepId = de.EmployeeId
GROUP BY de.EmployeeId, de.FirstName, de.LastName
ORDER BY TotalInvoices DESC;
```

- **Účel**: Určiť, ktorí zamestnanci spracovali najviac objednávok.
- **Výstup**: Zoznam zamestnancov zoradený podľa počtu spracovaných objednávok v zostupnom poradí.

### 4.5 Priemerný čas práce zamestnancov podľa dátumu prijatia (HireDate)

Tento dotaz vypočíta priemerný čas práce zamestnancov v závislosti od roku ich prijatia.

```sql
SELECT 
    EXTRACT(YEAR FROM HireDate) AS HireYear, 
    AVG(DATEDIFF('day', HireDate, CURRENT_DATE)) AS AverageWorkDays
FROM Dim_Employee
GROUP BY HireYear
ORDER BY HireYear;
```

- **Účel**: Získať prehľad o priemernom čase zamestnania zamestnancov podľa roku prijatia.
- **Výstup**: Tabuľka so stĺpcami pre rok prijatia a priemerný počet dní v zamestnaní.

---
Autor: Zoltán Pšenák
