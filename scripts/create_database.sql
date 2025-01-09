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
        IsActive BIT NOT NULL DEFAULT 1,
        CreateDate DATETIME NOT NULL DEFAULT GETDATE(),
        UpdateDate DATETIME NULL,
        CONSTRAINT UQ_TableName UNIQUE (TableName) WHERE IsActive = 1
    );
    PRINT 'DynamicTable tablosu oluşturuldu.';
END

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'DynamicColumn')
BEGIN
    CREATE TABLE DynamicColumn (
        ColumnId INT IDENTITY(1,1) PRIMARY KEY,
        TableId INT NOT NULL,
        ColumnName NVARCHAR(100) NOT NULL,
        ColumnType NVARCHAR(50) NOT NULL,
        IsRequired BIT NOT NULL DEFAULT 0,
        IsActive BIT NOT NULL DEFAULT 1,
        Description NVARCHAR(500) NULL,
        CreateDate DATETIME NOT NULL DEFAULT GETDATE(),
        UpdateDate DATETIME NULL,
        CONSTRAINT FK_DynamicColumn_DynamicTable FOREIGN KEY (TableId) REFERENCES DynamicTable(TableId),
        CONSTRAINT UQ_TableColumn UNIQUE (TableId, ColumnName) WHERE IsActive = 1
    );
    PRINT 'DynamicColumn tablosu oluşturuldu.';
END

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'DynamicValue')
BEGIN
    CREATE TABLE DynamicValue (
        ValueId INT IDENTITY(1,1) PRIMARY KEY,
        TableId INT NOT NULL,
        ColumnId INT NOT NULL,
        RowId INT NOT NULL,
        StringValue NVARCHAR(MAX) NULL,
        IntegerValue INT NULL,
        DecimalValue DECIMAL(18,2) NULL,
        DateValue DATETIME NULL,
        IsActive BIT NOT NULL DEFAULT 1,
        CreateDate DATETIME NOT NULL DEFAULT GETDATE(),
        UpdateDate DATETIME NULL,
        CONSTRAINT FK_DynamicValue_DynamicTable FOREIGN KEY (TableId) REFERENCES DynamicTable(TableId),
        CONSTRAINT FK_DynamicValue_DynamicColumn FOREIGN KEY (ColumnId) REFERENCES DynamicColumn(ColumnId)
    );
    
    -- İndeksler
    CREATE INDEX IX_DynamicValue_TableId ON DynamicValue(TableId, RowId) INCLUDE (ColumnId, IsActive);
    CREATE INDEX IX_DynamicValue_ColumnId ON DynamicValue(ColumnId) INCLUDE (StringValue, DecimalValue, IntegerValue, DateValue, IsActive);
    CREATE UNIQUE INDEX IX_DynamicValue_Unique ON DynamicValue(TableId, ColumnId, RowId) WHERE IsActive = 1;
    
    PRINT 'DynamicValue tablosu oluşturuldu.';
END

-- UpdateDate alanını güncelleyecek triggerları oluştur
CREATE OR ALTER TRIGGER tr_DynamicTable_Update
ON DynamicTable
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dt
    SET UpdateDate = GETDATE()
    FROM DynamicTable dt
    INNER JOIN inserted i ON dt.TableId = i.TableId;
END
GO

CREATE OR ALTER TRIGGER tr_DynamicColumn_Update
ON DynamicColumn
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dc
    SET UpdateDate = GETDATE()
    FROM DynamicColumn dc
    INNER JOIN inserted i ON dc.ColumnId = i.ColumnId;
END
GO

CREATE OR ALTER TRIGGER tr_DynamicValue_Update
ON DynamicValue
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dv
    SET UpdateDate = GETDATE()
    FROM DynamicValue dv
    INNER JOIN inserted i ON dv.ValueId = i.ValueId;
END
GO