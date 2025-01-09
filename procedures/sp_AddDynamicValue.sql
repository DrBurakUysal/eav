/*
* =============================================
* Author:      Burak Uysal
* Create date: 10.01.2025
* Description: Dinamik tabloya veri ekleme prosedürü
* =============================================
*
* Bu prosedür, dinamik tabloya yeni bir değer ekler.
* Veri tipi kontrolü yapılır ve değer uygun alana kaydedilir.
*
* Parameters:
*    @TableName  - Verinin ekleneceği tablo adı
*    @ColumnName - Verinin ekleneceği kolon adı
*    @RowId      - Satır ID
*    @Value      - Eklenecek değer (SQL_VARIANT tipinde)
*
* Returns:
*    Başarı/hata mesajı
*
* Example:
*    -- String değer ekleme
*    EXEC sp_AddDynamicValue 'Products', 'ProductName', 1, 'iPhone 15'
*    
*    -- Decimal değer ekleme
*    EXEC sp_AddDynamicValue 'Products', 'Price', 1, 64999.99
*    
*    -- Integer değer ekleme
*    EXEC sp_AddDynamicValue 'Products', 'Stock', 1, 100
*    
*    -- Tarih değeri ekleme
*    EXEC sp_AddDynamicValue 'Products', 'CreateDate', 1, '2024-03-15'
*
* Revision History:
* 1.0 - 10.01.2025 - İlk versiyon
*/
CREATE OR ALTER PROCEDURE sp_AddDynamicValue
    @TableName NVARCHAR(100),
    @ColumnName NVARCHAR(100),
    @RowId INT,
    @Value SQL_VARIANT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Tablo ve kolon kontrolü
        DECLARE @TableId INT, @ColumnId INT, @ColumnType NVARCHAR(50)
        
        SELECT @TableId = t.TableId,
               @ColumnId = c.ColumnId,
               @ColumnType = c.ColumnType
        FROM DynamicTable t
        JOIN DynamicColumn c ON t.TableId = c.TableId
        WHERE t.TableName = @TableName 
        AND c.ColumnName = @ColumnName
        AND t.IsActive = 1 
        AND c.IsActive = 1

        IF @TableId IS NULL OR @ColumnId IS NULL
        BEGIN
            RAISERROR ('Tablo veya kolon bulunamadı: %s.%s', 16, 1, @TableName, @ColumnName);
            RETURN;
        END

        -- Veri ekleme
        INSERT INTO DynamicValue (
            TableId, 
            ColumnId, 
            RowId, 
            StringValue, 
            IntegerValue, 
            DecimalValue, 
            DateValue
        )
        VALUES (
            @TableId,
            @ColumnId,
            @RowId,
            CASE WHEN @ColumnType = 'STRING' THEN CAST(@Value AS NVARCHAR(MAX)) ELSE NULL END,
            CASE WHEN @ColumnType = 'INTEGER' THEN CAST(@Value AS INT) ELSE NULL END,
            CASE WHEN @ColumnType = 'DECIMAL' THEN CAST(@Value AS DECIMAL(18,2)) ELSE NULL END,
            CASE WHEN @ColumnType = 'DATE' THEN CAST(@Value AS DATETIME) ELSE NULL END
        )
        
        PRINT 'Veri başarıyla eklendi'
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO 