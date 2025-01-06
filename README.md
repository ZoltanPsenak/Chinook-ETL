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

### Faktová tabuľka: `Fact_InvoiceLine`
Faktová tabuľka predstavuje jadro dimenzionálneho modelu, obsahujúce údaje o predaji jednotlivých skladieb na faktúrach.

### Hlavné metriky:

**UnitPrice**: Cena za jednotku skladby.
**Quantity**: Počet zakúpených jednotiek skladby.
**TotalAmount**: Celková suma za danú skladbu (UnitPrice × Quantity).
**TrackCount**: Počet skladieb na faktúre.

### Primárne kľúče:

- **InvoiceLineId**: Jedinečný identifikátor fakturačnej položky.
- **InvoiceId**: Jedinečný identifikátor faktúry.
- **TrackId**: Jedinečný identifikátor skladby.

### Popis dimenzií
### 1. **Dim_Track**
- **Údaje** : Informácie o skladbách, ako názov, album, žáner, typ média, skladateľ, dĺžka trvania a cena.
- **Väzba na faktovú tabuľku** : Prepojenie cez TrackId, poskytuje kontext pre analýzu predaja jednotlivých skladieb.
- **Typ dimenzie** : SCD Typ 1 – údaje o skladbách sa zvyčajne nemenia historicky.
  
### 2. **Dim_Album**
- **Údaje** : Informácie o albumoch, ako názov albumu a jeho umelec.
- **Väzba na faktovú tabuľku** : Nepriame prepojenie cez TrackId → AlbumId, umožňuje analýzu predaja podľa albumov.
- **Typ dimenzie** : SCD Typ 1 – údaje o albumoch sa nemenia historicky.

### 3. **Dim_Artist**
- **Údaje** : Informácie o umelcoch, ako ich meno.
- **Väzba na faktovú tabuľku** : Nepriame prepojenie cez TrackId → AlbumId → ArtistId, umožňuje analýzu predaja podľa umelcov.
- **Typ dimenzie** : SCD Typ 1 – údaje o umelcoch sa nemenia historicky.

### 4. **Dim_Playlist**
- **Údaje** : Informácie o playlistoch, ako názov playlistu.
- **Väzba na faktovú tabuľku** : Prepojenie cez TrackId → PlaylistTrack → PlaylistId, umožňuje analýzu priemerného počtu skladieb na playlistoch.
- **Typ dimenzie** : SCD Typ 1 – údaje o playlistoch sa nemenia historicky.

### 5. **Dim_Customer**
- **Údaje** : Informácie o zákazníkoch, ako meno, priezvisko, adresa, kontaktné údaje a zástupca podpory.
- **Väzba na faktovú tabuľku** : Prepojenie cez CustomerId, umožňuje analýzu správania zákazníkov a predaja podľa regiónov.
- **Typ dimenzie** : SCD Typ 2 – údaje o zákazníkoch (napr. adresa) sa môžu meniť historicky.

### 6. **Dim_Invoice**
- **Údaje** : Informácie o faktúrach, ako dátum vystavenia, fakturačná adresa, krajina a celková suma faktúry.
- **Väzba na faktovú tabuľku** : Prepojenie cez InvoiceId, poskytuje kontext pre analýzu predaja podľa regiónov a trendov v čase.
- **Typ dimenzie** : SCD Typ 1 – údaje o faktúrach sa nemenia historicky.

### 7. **Dim_Employee**
- **Údaje** : Informácie o zamestnancoch, ako meno, titul, dátum narodenia, dátum prijatia a nadriadený.
- **Väzba na faktovú tabuľku** : Prepojenie cez EmployeeId, umožňuje analýzu výkonnosti zamestnancov a pracovného času.
- **Typ dimenzie** : SCD Typ 1 – údaje o zamestnancoch (napr. dátum prijatia) sa nemenia historicky.

### 8. **Dim_Genre**
- **Údaje** : Informácie o žánroch, ako názov žánru.
- **Väzba na faktovú tabuľku** : Prepojenie cez GenreId → TrackId, umožňuje analýzu predaja podľa žánrov.
- **Typ dimenzie** : SCD Typ 1 – údaje o žánroch sa nemenia historicky.

### 9. **Dim_MediaType**
- **Údaje** : Informácie o typoch médií, ako názov média.
- **Väzba na faktovú tabuľku** : Prepojenie cez MediaTypeId → TrackId, umožňuje analýzu predaja podľa typu média.
- **Typ dimenzie** : SCD Typ 1 – údaje o médiách sa nemenia historicky.

  <p align="center">
  <img src="https://github.com/ZoltanPsenak/Chinook-ETL/blob/main/star_schema.png" alt="Star Schema">
  <br>
  <em>Obrázok 2 Schéma hviezdy pre ChinookDB</em>
</p>
