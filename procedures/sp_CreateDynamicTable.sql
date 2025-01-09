/*
* =============================================
* Author:      Burak Uysal
* Create date: 10.01.2025
* Description: Dinamik tablo oluşturma prosedürü
* =============================================
*
* Bu prosedür, EAV (Entity-Attribute-Value) yapısında yeni bir tablo oluşturur.
* Tablo adı validasyonları yapılır ve eğer daha önce silinmiş aynı isimde bir tablo
* varsa, o tablo aktif hale getirilir.
*
* Parameters:
*    @TableName - Oluşturulacak tablonun adı (sadece harf, rakam ve alt çizgi içerebilir)
*
* Returns:
*    Başarı/hata mesajı
*
* Example:
*    EXEC sp_CreateDynamicTable 'Products'
*    EXEC sp_CreateDynamicTable 'Customers'
*
* Revision History:
* 1.0 - 10.01.2025 - İlk versiyon
*/
CREATE OR ALTER PROCEDURE sp_CreateDynamicTable
    @TableName NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Tablo adı kontrolü
        IF @TableName IS NULL OR LEN(TRIM(@TableName)) = 0
        BEGIN
            RAISERROR ('Tablo adı boş olamaz', 16, 1);
            RETURN;
        END

        -- Tablo adı formatı kontrolü (özel karakterler ve boşluk olmamalı)
        IF @TableName LIKE '%[^a-zA-Z0-9_]%'
        BEGIN
            RAISERROR ('Tablo adı sadece harf, rakam ve alt çizgi içerebilir', 16, 1);
            RETURN;
        END

        -- Mevcut tablo kontrolü
        IF EXISTS (SELECT 1 FROM DynamicTable WHERE TableName = @TableName AND IsActive = 1)
        BEGIN
            RAISERROR ('Bu isimde bir tablo zaten mevcut: %s', 16, 1, @TableName);
            RETURN;
        END

        -- Silinmiş tablo varsa aktif et
        IF EXISTS (SELECT 1 FROM DynamicTable WHERE TableName = @TableName AND IsActive = 0)
        BEGIN
            UPDATE DynamicTable 
            SET IsActive = 1,
                ModifiedDate = GETDATE()
            WHERE TableName = @TableName
            
            PRINT 'Tablo yeniden aktifleştirildi: ' + @TableName
            RETURN;
        END

        -- Yeni tablo oluştur
        INSERT INTO DynamicTable (TableName)
        VALUES (@TableName)
        
        PRINT 'Tablo başarıyla oluşturuldu: ' + @TableName
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY()
        DECLARE @ErrorState INT = ERROR_STATE()

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO 