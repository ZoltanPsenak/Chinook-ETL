--1. Priemerný počet skladieb na jednom playliste
SELECT 
    AVG(TrackCount) AS AverageTracksPerPlaylist
FROM (
    SELECT 
        PlaylistId, 
        COUNT(TrackId) AS TrackCount
    FROM Fact_InvoiceLine
    GROUP BY PlaylistId
);
--2. Zákazníci, ktorí minuli najviac peňazí
SELECT 
    dc.CustomerId, 
    dc.FirstName, 
    dc.LastName, 
    SUM(il.UnitPrice * il.Quantity) AS TotalSpent
FROM Fact_InvoiceLine il
JOIN Dim_Customer dc ON il.CustomerId = dc.CustomerId
GROUP BY dc.CustomerId, dc.FirstName, dc.LastName
ORDER BY TotalSpent DESC;

--3. Trend nakupovania podľa regionu(štátu, krajiny)
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

--4. Zamestnanci, ktorí spracovali najviac objadnávok
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

--5. Priemerný čas práce zamestnancov podľa dátumu prijatia.
SELECT 
    EXTRACT(YEAR FROM HireDate) AS HireYear, 
    AVG(DATEDIFF('day', HireDate, CURRENT_DATE)) AS AverageWorkDays
FROM Dim_Employee
GROUP BY HireYear
ORDER BY HireYear;