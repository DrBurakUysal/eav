/*
* =============================================
* Author:      Burak Uysal
* Create date: 10.01.2025
* Description: Dinamik tabloya kolon ekleme prosedürü
* =============================================
*
* Bu prosedür, mevcut bir dinamik tabloya yeni bir kolon ekler.
* Kolon tipi ve adı validasyonları yapılır.
*
* Parameters:
*    @TableName   - Kolonun ekleneceği tablo adı
*    @ColumnName  - Eklenecek kolonun adı
*    @ColumnType  - Kolon tipi (STRING, INTEGER, DECIMAL, DATE)
*    @IsRequired  - Zorunlu alan mı? (0: Hayır, 1: Evet)
*    @Description - Kolon açıklaması
*
* Returns:
*    Başarı/hata mesajı
*
* Example:
*    EXEC sp_AddDynamicColumn 
*        @TableName = 'Products',
*        @ColumnName = 'Price',
*        @ColumnType = 'DECIMAL',
*        @IsRequired = 1,
*        @Description = 'Ürün fiyatı'
*
* Revision History:
* 1.0 - 10.01.2025 - İlk versiyon
*/
CREATE OR ALTER PROCEDURE sp_AddDynamicColumn
    @TableName NVARCHAR(100),
    @ColumnName NVARCHAR(100),
    @ColumnType NVARCHAR(50),
    @IsRequired BIT = 0,
    @Description NVARCHAR(500) = NULL
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

        -- Kolon tipi kontrolü
        IF @ColumnType NOT IN ('STRING', 'INTEGER', 'DECIMAL', 'DATE')
        BEGIN
            RAISERROR ('Geçersiz kolon tipi. Kullanılabilir tipler: STRING, INTEGER, DECIMAL, DATE', 16, 1);
            RETURN;
        END

        -- Kolon adı kontrolü
        IF EXISTS (SELECT 1 FROM DynamicColumn 
                  WHERE TableId = @TableId 
                  AND ColumnName = @ColumnName 
                  AND IsActive = 1)
        BEGIN
            RAISERROR ('Bu isimde bir kolon zaten mevcut: %s', 16, 1, @ColumnName);
            RETURN;
        END

        INSERT INTO DynamicColumn (TableId, ColumnName, ColumnType, IsRequired, Description)
        VALUES (@TableId, @ColumnName, @ColumnType, @IsRequired, @Description)
        
        PRINT 'Kolon başarıyla eklendi: ' + @ColumnName
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO 