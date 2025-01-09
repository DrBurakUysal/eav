/*
* =============================================
* Author:      Burak Uysal
* Create date: 10.01.2025
* Description: Dinamik tablo yapısını getirme prosedürü
* =============================================
*
* Bu prosedür, belirtilen dinamik tablonun kolon yapısını ve özelliklerini getirir.
* Her kolonun adı, tipi, zorunluluk durumu ve açıklaması listelenir.
*
* Parameters:
*    @TableName - Yapısı incelenecek tablo adı
*
* Returns:
*    Tablo tasarım bilgileri
*
* Example:
*    EXEC sp_GetTableDesign 'Products'
*    EXEC sp_GetTableDesign 'Customers'
*
* Revision History:
* 1.0 - 10.01.2025 - İlk versiyon
*/
CREATE OR ALTER PROCEDURE sp_GetTableDesign
    @TableName NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Tablo kontrolü
        DECLARE @TableId INT
        SELECT @TableId = TableId 
        FROM DynamicTable 
        WHERE TableName = @TableName 
        AND IsActive = 1

        IF @TableId IS NULL
        BEGIN
            RAISERROR ('Tablo bulunamadı: %s', 16, 1, @TableName);
            RETURN;
        END

        -- Tablo bilgilerini getir
        SELECT 
            ROW_NUMBER() OVER (ORDER BY dc.ColumnId) AS [Sıra No],
            dc.ColumnName AS [Kolon Adı],
            dc.ColumnType AS [Veri Tipi],
            CASE 
                WHEN dc.IsRequired = 1 THEN 'Evet'
                ELSE 'Hayır'
            END AS [Zorunlu],
            CASE dc.ColumnType
                WHEN 'STRING' THEN 'NVARCHAR(MAX)'
                WHEN 'INTEGER' THEN 'INT'
                WHEN 'DECIMAL' THEN 'DECIMAL(18,2)'
                WHEN 'DATE' THEN 'DATETIME'
                ELSE dc.ColumnType
            END AS [SQL Veri Tipi],
            dc.Description AS [Açıklama],
            dc.CreateDate AS [Oluşturma Tarihi],
            dc.UpdateDate AS [Güncelleme Tarihi]
        FROM DynamicColumn dc
        WHERE dc.TableId = @TableId
        AND dc.IsActive = 1
        ORDER BY dc.ColumnId;

        -- Tablo özet bilgilerini getir
        SELECT 
            dt.TableName AS [Tablo Adı],
            dt.CreateDate AS [Tablo Oluşturma Tarihi],
            dt.UpdateDate AS [Tablo Güncelleme Tarihi],
            COUNT(dc.ColumnId) AS [Toplam Kolon Sayısı],
            SUM(CASE WHEN dc.IsRequired = 1 THEN 1 ELSE 0 END) AS [Zorunlu Kolon Sayısı],
            (SELECT COUNT(DISTINCT RowId) 
             FROM DynamicValue 
             WHERE TableId = dt.TableId 
             AND IsActive = 1) AS [Kayıt Sayısı]
        FROM DynamicTable dt
        LEFT JOIN DynamicColumn dc ON dt.TableId = dc.TableId AND dc.IsActive = 1
        WHERE dt.TableId = @TableId
        AND dt.IsActive = 1
        GROUP BY dt.TableId, dt.TableName, dt.CreateDate, dt.UpdateDate;

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY()
        DECLARE @ErrorState INT = ERROR_STATE()

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO 