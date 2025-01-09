-- Veritabanı kontrolü ve oluşturma
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'EAV')
BEGIN
    CREATE DATABASE EAV;
    PRINT 'EAV veritabanı oluşturuldu.';
END
GO

USE EAV;
GO

-- Tabloları kontrol et ve oluştur
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'DynamicTable')
BEGIN
    CREATE TABLE DynamicTable (
        TableId INT IDENTITY(1,1) PRIMARY KEY,
        TableName NVARCHAR(100) NOT NULL,
        IsActive BIT DEFAULT 1,
        CreatedDate DATETIME DEFAULT GETDATE(),
        ModifiedDate DATETIME
    );
    CREATE UNIQUE INDEX IX_DynamicTable_Name ON DynamicTable(TableName) WHERE IsActive = 1;
    PRINT 'DynamicTable tablosu oluşturuldu.';
END

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'DynamicColumn')
BEGIN
    CREATE TABLE DynamicColumn (
        ColumnId INT IDENTITY(1,1) PRIMARY KEY,
        TableId INT,
        ColumnName NVARCHAR(100) NOT NULL,
        ColumnType NVARCHAR(50) NOT NULL,
        IsRequired BIT DEFAULT 0,
        IsActive BIT DEFAULT 1,
        CreatedDate DATETIME DEFAULT GETDATE(),
        ModifiedDate DATETIME,
        Description NVARCHAR(500),
        FOREIGN KEY (TableId) REFERENCES DynamicTable(TableId)
    );
    CREATE UNIQUE INDEX IX_DynamicColumn_Name ON DynamicColumn(TableId, ColumnName) WHERE IsActive = 1;
    PRINT 'DynamicColumn tablosu oluşturuldu.';
END

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'DynamicValue')
BEGIN
    CREATE TABLE DynamicValue (
        ValueId INT IDENTITY(1,1) PRIMARY KEY,
        TableId INT,
        ColumnId INT,
        RowId INT,
        StringValue NVARCHAR(MAX),
        IntegerValue INT,
        DecimalValue DECIMAL(18,2),
        DateValue DATETIME,
        IsActive BIT DEFAULT 1,
        CreatedDate DATETIME DEFAULT GETDATE(),
        ModifiedDate DATETIME,
        FOREIGN KEY (TableId) REFERENCES DynamicTable(TableId),
        FOREIGN KEY (ColumnId) REFERENCES DynamicColumn(ColumnId)
    );
    CREATE INDEX IX_DynamicValue_TableId ON DynamicValue(TableId) WHERE IsActive = 1;
    CREATE INDEX IX_DynamicValue_ColumnId ON DynamicValue(ColumnId) WHERE IsActive = 1;
    CREATE UNIQUE INDEX IX_DynamicValue_Unique ON DynamicValue(TableId, ColumnId, RowId) WHERE IsActive = 1;
    PRINT 'DynamicValue tablosu oluşturuldu.';
END
GO 