-- Siparişler tablosu
IF NOT EXISTS (SELECT 1 FROM DynamicTable WHERE TableName = 'Orders' AND IsActive = 1)
BEGIN
    EXEC sp_CreateDynamicTable 'Orders'
    
    -- Kolonları ekle
    EXEC sp_AddDynamicColumn 'Orders', 'OrderDate', 'DATE', 1, 'Sipariş tarihi'
    EXEC sp_AddDynamicColumn 'Orders', 'CustomerId', 'INTEGER', 1, 'Müşteri ID'
    EXEC sp_AddDynamicColumn 'Orders', 'ProductId', 'INTEGER', 1, 'Ürün ID'
    EXEC sp_AddDynamicColumn 'Orders', 'Quantity', 'INTEGER', 1, 'Miktar'
    EXEC sp_AddDynamicColumn 'Orders', 'UnitPrice', 'DECIMAL', 1, 'Birim fiyat'
    EXEC sp_AddDynamicColumn 'Orders', 'TotalAmount', 'DECIMAL', 1, 'Toplam tutar'
    EXEC sp_AddDynamicColumn 'Orders', 'Status', 'STRING', 1, 'Sipariş durumu'

    -- Örnek siparişler
    DECLARE @Counter INT = 1
    WHILE @Counter <= 10
    BEGIN
        DECLARE @OrderDate DATE = DATEADD(DAY, -CAST(RAND() * 30 AS INT), GETDATE())
        DECLARE @CustomerId INT = CAST(RAND() * 10 + 1 AS INT)
        DECLARE @ProductId INT = CAST(RAND() * 50 + 1 AS INT)
        DECLARE @Quantity INT = CAST(RAND() * 5 + 1 AS INT)
        DECLARE @UnitPrice DECIMAL(18,2) = CAST(RAND() * 10000 AS DECIMAL(18,2))
        DECLARE @TotalAmount DECIMAL(18,2) = @Quantity * @UnitPrice
        DECLARE @Status NVARCHAR(20) = CASE CAST(RAND() * 3 AS INT)
                                        WHEN 0 THEN 'Beklemede'
                                        WHEN 1 THEN 'Onaylandı'
                                        ELSE 'Tamamlandı'
                                      END

        EXEC sp_AddDynamicValue 'Orders', 'OrderDate', @Counter, @OrderDate
        EXEC sp_AddDynamicValue 'Orders', 'CustomerId', @Counter, @CustomerId
        EXEC sp_AddDynamicValue 'Orders', 'ProductId', @Counter, @ProductId
        EXEC sp_AddDynamicValue 'Orders', 'Quantity', @Counter, @Quantity
        EXEC sp_AddDynamicValue 'Orders', 'UnitPrice', @Counter, @UnitPrice
        EXEC sp_AddDynamicValue 'Orders', 'TotalAmount', @Counter, @TotalAmount
        EXEC sp_AddDynamicValue 'Orders', 'Status', @Counter, @Status

        SET @Counter = @Counter + 1
    END
END 