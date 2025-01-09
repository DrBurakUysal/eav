/*
* =============================================
* Author:      Burak Uysal
* Create date: 10.01.2025
* Description: Dinamik tablo verilerini getirme prosedürü
* =============================================
*
* Bu prosedür, dinamik tablodaki verileri pivot edilmiş şekilde getirir.
* Where ve Order By koşulları dinamik olarak uygulanabilir.
*
* Parameters:
*    @TableName - Verilerin getirileceği tablo adı
*    @Where     - Filtreleme koşulu (opsiyonel)
*    @OrderBy   - Sıralama koşulu (opsiyonel)
*
* Returns:
*    Pivot edilmiş veri tablosu
*
* Example:
*    -- Tüm verileri getir
*    EXEC sp_GetDynamicData 'Products'
*    
*    -- Fiyatı 50000'den büyük ürünleri getir
*    EXEC sp_GetDynamicData 
*        @TableName = 'Products',
*        @Where = 'dc2.ColumnName = ''Price'' AND dv2.DecimalValue > 50000'
*    
*    -- Ürün adına göre sıralı getir
*    EXEC sp_GetDynamicData 
*        @TableName = 'Products',
*        @OrderBy = 'MAX(CASE WHEN dc.ColumnName = ''ProductName'' THEN dv.StringValue END)'
*
* Revision History:
* 1.0 - 10.01.2025 - İlk versiyon
*/
CREATE OR ALTER PROCEDURE sp_GetDynamicData
    @TableName NVARCHAR(100),
    @Where NVARCHAR(MAX) = NULL,
    @OrderBy NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Tablo kontrolü
    IF NOT EXISTS (SELECT 1 FROM DynamicTable WHERE TableName = @TableName AND IsActive = 1)
    BEGIN
        RAISERROR ('Tablo bulunamadı: %s', 16, 1, @TableName);
        RETURN;
    END

    DECLARE @TableId INT
    SELECT @TableId = TableId FROM DynamicTable WHERE TableName = @TableName AND IsActive = 1

    -- Kolonları al
    DECLARE @Columns TABLE (
        ColumnName NVARCHAR(100),
        ColumnType NVARCHAR(50)
    )
    
    INSERT INTO @Columns
    SELECT ColumnName, ColumnType
    FROM DynamicColumn
    WHERE TableId = @TableId
    AND IsActive = 1
    ORDER BY ColumnId

    -- Dinamik SQL oluştur
    DECLARE @SQL NVARCHAR(MAX) = 'SELECT '
    
    SELECT @SQL = @SQL + 
        CASE 
            WHEN ColumnType = 'STRING' THEN 'MAX(CASE WHEN dc.ColumnName = ''' + ColumnName + ''' THEN dv.StringValue END) AS [' + ColumnName + '],'
            WHEN ColumnType = 'INTEGER' THEN 'MAX(CASE WHEN dc.ColumnName = ''' + ColumnName + ''' THEN CAST(dv.IntegerValue AS NVARCHAR) END) AS [' + ColumnName + '],'
            WHEN ColumnType = 'DECIMAL' THEN 'MAX(CASE WHEN dc.ColumnName = ''' + ColumnName + ''' THEN CAST(dv.DecimalValue AS NVARCHAR) END) AS [' + ColumnName + '],'
            WHEN ColumnType = 'DATE' THEN 'MAX(CASE WHEN dc.ColumnName = ''' + ColumnName + ''' THEN CONVERT(NVARCHAR, dv.DateValue, 120) END) AS [' + ColumnName + '],'
        END
    FROM @Columns

    SET @SQL = LEFT(@SQL, LEN(@SQL) - 1) + 
    ' FROM DynamicValue dv
    JOIN DynamicColumn dc ON dv.ColumnId = dc.ColumnId
    WHERE dv.TableId = ' + CAST(@TableId AS NVARCHAR) + '
    AND dv.IsActive = 1'

    IF @Where IS NOT NULL
    BEGIN
        SET @SQL = @SQL + ' AND EXISTS (
            SELECT 1 
            FROM DynamicValue dv2 
            JOIN DynamicColumn dc2 ON dv2.ColumnId = dc2.ColumnId 
            WHERE dv2.TableId = dv.TableId 
            AND dv2.RowId = dv.RowId 
            AND ' + @Where + ')'
    END

    SET @SQL = @SQL + ' GROUP BY dv.RowId'

    IF @OrderBy IS NOT NULL
        SET @SQL = @SQL + ' ORDER BY ' + @OrderBy
    ELSE
        SET @SQL = @SQL + ' ORDER BY dv.RowId'

    EXEC sp_executesql @SQL
END
GO 