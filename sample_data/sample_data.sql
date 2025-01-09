-- Ürünler tablosu kontrolü ve oluşturma
IF NOT EXISTS (SELECT 1 FROM DynamicTable WHERE TableName = 'Products' AND IsActive = 1)
BEGIN
    INSERT INTO DynamicTable (TableName) VALUES ('Products')
    DECLARE @ProductTableId INT = SCOPE_IDENTITY()

    -- Ürün kolonları ekle
    INSERT INTO DynamicColumn (TableId, ColumnName, ColumnType, IsRequired, Description) 
    SELECT @ProductTableId, ColumnName, ColumnType, IsRequired, Description
    FROM (
        VALUES 
            ('ProductName', 'STRING', 1, 'Ürün adı'),
            ('Price', 'DECIMAL', 1, 'Fiyat'),
            ('Stock', 'INTEGER', 1, 'Stok'),
            ('Brand', 'STRING', 1, 'Marka'),
            ('Category', 'STRING', 1, 'Kategori'),
            ('Color', 'STRING', 0, 'Renk')
    ) AS Columns(ColumnName, ColumnType, IsRequired, Description)
    WHERE NOT EXISTS (
        SELECT 1 
        FROM DynamicColumn 
        WHERE TableId = @ProductTableId 
        AND ColumnName = Columns.ColumnName 
        AND IsActive = 1
    )

    -- Kolon ID'lerini al
    DECLARE @NameColumnId INT = (SELECT ColumnId FROM DynamicColumn WHERE TableId = @ProductTableId AND ColumnName = 'ProductName' AND IsActive = 1)
    DECLARE @PriceColumnId INT = (SELECT ColumnId FROM DynamicColumn WHERE TableId = @ProductTableId AND ColumnName = 'Price' AND IsActive = 1)
    DECLARE @StockColumnId INT = (SELECT ColumnId FROM DynamicColumn WHERE TableId = @ProductTableId AND ColumnName = 'Stock' AND IsActive = 1)
    DECLARE @BrandColumnId INT = (SELECT ColumnId FROM DynamicColumn WHERE TableId = @ProductTableId AND ColumnName = 'Brand' AND IsActive = 1)
    DECLARE @CategoryColumnId INT = (SELECT ColumnId FROM DynamicColumn WHERE TableId = @ProductTableId AND ColumnName = 'Category' AND IsActive = 1)
    DECLARE @ColorColumnId INT = (SELECT ColumnId FROM DynamicColumn WHERE TableId = @ProductTableId AND ColumnName = 'Color' AND IsActive = 1)

    -- Örnek ürün 1 değerleri
    IF NOT EXISTS (SELECT 1 FROM DynamicValue WHERE TableId = @ProductTableId AND RowId = 1 AND IsActive = 1)
    BEGIN
        INSERT INTO DynamicValue (TableId, ColumnId, RowId, StringValue, DecimalValue, IntegerValue) VALUES
        (@ProductTableId, @NameColumnId, 1, 'MacBook Pro 16', NULL, NULL),
        (@ProductTableId, @PriceColumnId, 1, NULL, 45999.99, NULL),
        (@ProductTableId, @StockColumnId, 1, NULL, NULL, 50),
        (@ProductTableId, @BrandColumnId, 1, 'Apple', NULL, NULL),
        (@ProductTableId, @CategoryColumnId, 1, 'Laptop', NULL, NULL),
        (@ProductTableId, @ColorColumnId, 1, 'Space Gray', NULL, NULL)
    END

    -- Örnek ürün 2 değerleri
    IF NOT EXISTS (SELECT 1 FROM DynamicValue WHERE TableId = @ProductTableId AND RowId = 2 AND IsActive = 1)
    BEGIN
        INSERT INTO DynamicValue (TableId, ColumnId, RowId, StringValue, DecimalValue, IntegerValue) VALUES
        (@ProductTableId, @NameColumnId, 2, 'iPhone 15 Pro', NULL, NULL),
        (@ProductTableId, @PriceColumnId, 2, NULL, 64999.99, NULL),
        (@ProductTableId, @StockColumnId, 2, NULL, NULL, 100),
        (@ProductTableId, @BrandColumnId, 2, 'Apple', NULL, NULL),
        (@ProductTableId, @CategoryColumnId, 2, 'Smartphone', NULL, NULL),
        (@ProductTableId, @ColorColumnId, 2, 'Natural Titanium', NULL, NULL)
    END

    PRINT 'Örnek veriler başarıyla eklendi.'
END
ELSE
BEGIN
    PRINT 'Products tablosu ve örnek veriler zaten mevcut.'
END

-- Test sorgusu
EXEC sp_ViewDynamicTable 'Products'

-- Products tablosunun yapısını getir
EXEC sp_GetTableDesign 'Products'

-- Customers tablosunun yapısını getir
EXEC sp_GetTableDesign 'Customers' 