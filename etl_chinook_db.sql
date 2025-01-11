-- 1. 
CREATE DATABASE RABBIT_CHINOOK_DB;
USE DATABASE RABBIT_CHINOOK_DB;
CREATE SCHEMA RABBIT_CHINOOK_DB.STAGING;
USE SCHEMA RABBIT_CHINOOK_DB.STAGING;
CREATE OR REPLACE STAGE my_stage;

-- 2. 
CREATE TABLE Employee_staging (
    EmployeeId INT PRIMARY KEY,
    FirstName VARCHAR(20),
    LastName VARCHAR(20),
    Title VARCHAR(30),
    ReportsTo INT,
    BirthDate DATETIME,
    HireDate DATETIME,
    Address VARCHAR(70),
    City VARCHAR(40),
    State VARCHAR(40),
    Country VARCHAR(40),
    PostalCode VARCHAR(10),
    Phone VARCHAR(24),
    Fax VARCHAR(24),
    Email VARCHAR(60),
    FOREIGN KEY (ReportsTo) REFERENCES Employee_staging(EmployeeId)
);

CREATE TABLE Customer_staging (
    CustomerId INT PRIMARY KEY,
    FirstName VARCHAR(40),
    LastName VARCHAR(40),
    Company VARCHAR(80),
    Address VARCHAR(70),
    City VARCHAR(40),
    State VARCHAR(40),
    Country VARCHAR(40),
    PostalCode VARCHAR(10),
    Phone VARCHAR(24),
    Fax VARCHAR(24),
    Email VARCHAR(60),
    SupportRepId INT,
    FOREIGN KEY (SupportRepId) REFERENCES Employee_staging(EmployeeId)
);

CREATE TABLE Invoice_staging (
    InvoiceId INT PRIMARY KEY,
    CustomerId INT,
    InvoiceDate DATETIME,
    BillingAddress VARCHAR(70),
    BillingCity VARCHAR(40),
    BillingState VARCHAR(40),
    BillingCountry VARCHAR(40),
    BillingPostalCode VARCHAR(10),
    Total DECIMAL(10, 2),
    FOREIGN KEY (CustomerId) REFERENCES Customer_staging(CustomerId)
);

CREATE TABLE InvoiceLine_staging (
    InvoiceLineId INT PRIMARY KEY,
    InvoiceId INT,
    TrackId INT,
    UnitPrice DECIMAL(10, 2),
    Quantity INT,
    FOREIGN KEY (InvoiceId) REFERENCES Invoice_staging(InvoiceId),
    FOREIGN KEY (TrackId) REFERENCES Track_staging(TrackId)
);

CREATE TABLE Artist_staging (
    ArtistId INT PRIMARY KEY,
    Name VARCHAR(120) 
);

CREATE TABLE Album_staging (
    AlbumId INT PRIMARY KEY,
    Title VARCHAR(160),
    ArtistId INT,
    FOREIGN KEY (ArtistId) REFERENCES Artist_staging(ArtistId)
);

CREATE TABLE MediaType_staging (
    MediaTypeId INT PRIMARY KEY,
    Name VARCHAR(120)
);

CREATE TABLE Genre_staging (
    GenreId INT PRIMARY KEY,
    Name VARCHAR(120)
);

CREATE TABLE Track_staging (
    TrackId INT PRIMARY KEY,
    Name VARCHAR(200),
    AlbumId INT,
    MediaTypeId INT,
    GenreId INT,
    Composer VARCHAR(220),
    Milliseconds INT,
    Bytes INT,
    UnitPrice DECIMAL(10, 2),
    FOREIGN KEY (AlbumId) REFERENCES Album_staging(AlbumId),
    FOREIGN KEY (MediaTypeId) REFERENCES MediaType_staging(MediaTypeId),
    FOREIGN KEY (GenreId) REFERENCES Genre_staging(GenreId)
);

CREATE TABLE Playlist_staging (
    PlaylistId INT PRIMARY KEY,
    Name VARCHAR(120)
);

CREATE TABLE PlaylistTrack_staging (
    PlaylistId INT,
    TrackId INT,
    PRIMARY KEY (PlaylistId, TrackId),
    FOREIGN KEY (PlaylistId) REFERENCES Playlist_staging(PlaylistId),
    FOREIGN KEY (TrackId) REFERENCES Track_staging(TrackId)
);

-- 3.
LIST @my_stage;

COPY INTO Customer_staging
FROM @my_stage/customer.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);

COPY INTO Employee_staging
FROM @my_stage/employee.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1)
ON_ERROR = 'CONTINUE';

COPY INTO Invoice_staging
FROM @my_stage/invoice.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);

COPY INTO InvoiceLine_staging
FROM @my_stage/invoiceline.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);

COPY INTO Artist_staging
FROM @my_stage/artist.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);

COPY INTO Album_staging
FROM @my_stage/album.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);

COPY INTO MediaType_staging
FROM @my_stage/mediatype.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);

COPY INTO Genre_staging
FROM @my_stage/genre.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);

COPY INTO Track_staging
FROM @my_stage/track.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);

COPY INTO Playlist_staging
FROM @my_stage/playlist.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);

COPY INTO PlaylistTrack_staging
FROM @my_stage/playlisttrack.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);

---4.

-- Dim_Track
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
JOIN Genre_staging gr ON tr.GenreId = gr.GenreId


-- Dim_Album
CREATE TABLE Dim_Album AS
SELECT
    al.AlbumId,
    ar.Name AS Artist,
    al.Title
FROM Album_staging al
JOIN Artist_staging ar ON al.ArtistId = ar.ArtistId;

-- Dim_MediaType
CREATE TABLE Dim_MediaType AS
SELECT
    mt.MediaTypeId,
    mt.Name
FROM MediaType_staging mt;

-- Dim_Playlist
CREATE TABLE Dim_Playlist AS
SELECT
    pl.PlaylistId,
    pl.Name
FROM Playlist_staging pl;

-- Dim_Customer
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

-- Dim_Employee
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

-- Dim_Invoice
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

-- Dim_Date
CREATE TABLE Dim_Date AS
SELECT DISTINCT
    ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS DateId,
    EXTRACT(YEAR FROM inv.InvoiceDate) AS Year,
    EXTRACT(MONTH FROM inv.InvoiceDate) AS Month,
    EXTRACT(DAY FROM inv.InvoiceDate) AS Day,
    CAST(inv.InvoiceDate AS DATE) AS Date
FROM Invoice_staging inv;

--5.

-- Fact_InvoiceLine
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

-- 6.
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


