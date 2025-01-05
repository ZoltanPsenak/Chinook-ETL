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
