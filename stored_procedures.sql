-- Dinamik tablo verilerini getirme prosedürü
CREATE PROCEDURE sp_GetDynamicData
    @TableName NVARCHAR(100),
    @WhereClause NVARCHAR(MAX) = NULL,
    @OrderByClause NVARCHAR(MAX) = NULL
AS
BEGIN
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

    -- Where koşulu ekle
    IF @WhereClause IS NOT NULL
    BEGIN
        SET @SQL = @SQL + ' AND EXISTS (
            SELECT 1 
            FROM DynamicValue dv2 
            JOIN DynamicColumn dc2 ON dv2.ColumnId = dc2.ColumnId 
            WHERE dv2.TableId = dv.TableId 
            AND dv2.RowId = dv.RowId 
            AND ' + @WhereClause + ')'
    END

    -- Group By ekle
    SET @SQL = @SQL + ' GROUP BY dv.RowId'

    -- Order By ekle
    IF @OrderByClause IS NOT NULL
        SET @SQL = @SQL + ' ORDER BY ' + @OrderByClause
    ELSE
        SET @SQL = @SQL + ' ORDER BY dv.RowId'

    -- Debug için SQL'i göster (geliştirme aşamasında kullanışlı)
    -- PRINT @SQL

    -- Sorguyu çalıştır
    EXEC sp_executesql @SQL
END
GO 