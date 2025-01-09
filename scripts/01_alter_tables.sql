-- DynamicTable tablosuna tarih alanları ekle
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('DynamicTable') AND name = 'CreateDate')
BEGIN
    ALTER TABLE DynamicTable
    ADD CreateDate DATETIME NOT NULL DEFAULT GETDATE()
END

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('DynamicTable') AND name = 'UpdateDate')
BEGIN
    ALTER TABLE DynamicTable
    ADD UpdateDate DATETIME NULL
END

-- Mevcut kayıtları güncelle
UPDATE DynamicTable
SET CreateDate = GETDATE(),
    UpdateDate = GETDATE()
WHERE CreateDate IS NULL

-- Trigger ekle
CREATE OR ALTER TRIGGER tr_DynamicTable_Update
ON DynamicTable
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE dt
    SET UpdateDate = GETDATE()
    FROM DynamicTable dt
    INNER JOIN inserted i ON dt.TableId = i.TableId
END
GO 