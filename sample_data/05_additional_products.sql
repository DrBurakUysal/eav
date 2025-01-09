-- 50 ek ürün ekle
DECLARE @StartId INT = 3  -- Mevcut 2 üründen sonra başla
DECLARE @Counter INT = @StartId

WHILE @Counter <= (@StartId + 49)  -- 50 yeni ürün
BEGIN
    -- Rastgele ürün bilgileri oluştur
    DECLARE @ProductName NVARCHAR(100) = CASE CAST(RAND() * 5 AS INT)
        WHEN 0 THEN 'Laptop Model ' + CAST(@Counter AS NVARCHAR)
        WHEN 1 THEN 'Smartphone X' + CAST(@Counter AS NVARCHAR)
        WHEN 2 THEN 'Tablet Pro ' + CAST(@Counter AS NVARCHAR)
        WHEN 3 THEN 'Smart Watch ' + CAST(@Counter AS NVARCHAR)
        ELSE 'Wireless Earbuds ' + CAST(@Counter AS NVARCHAR)
    END

    DECLARE @Price DECIMAL(18,2) = CAST((RAND() * 9000) + 1000 AS DECIMAL(18,2))
    DECLARE @Stock INT = CAST(RAND() * 100 AS INT)
    DECLARE @Brand NVARCHAR(50) = CASE CAST(RAND() * 5 AS INT)
        WHEN 0 THEN 'Apple'
        WHEN 1 THEN 'Samsung'
        WHEN 2 THEN 'Sony'
        WHEN 3 THEN 'HP'
        ELSE 'Dell'
    END

    DECLARE @Category NVARCHAR(50) = CASE CAST(RAND() * 5 AS INT)
        WHEN 0 THEN 'Laptop'
        WHEN 1 THEN 'Smartphone'
        WHEN 2 THEN 'Tablet'
        WHEN 3 THEN 'Wearable'
        ELSE 'Audio'
    END

    DECLARE @Color NVARCHAR(50) = CASE CAST(RAND() * 5 AS INT)
        WHEN 0 THEN 'Black'
        WHEN 1 THEN 'Silver'
        WHEN 2 THEN 'Gold'
        WHEN 3 THEN 'Blue'
        ELSE 'White'
    END

    -- Ürün değerlerini ekle
    EXEC sp_AddDynamicValue 'Products', 'ProductName', @Counter, @ProductName
    EXEC sp_AddDynamicValue 'Products', 'Price', @Counter, @Price
    EXEC sp_AddDynamicValue 'Products', 'Stock', @Counter, @Stock
    EXEC sp_AddDynamicValue 'Products', 'Brand', @Counter, @Brand
    EXEC sp_AddDynamicValue 'Products', 'Category', @Counter, @Category
    EXEC sp_AddDynamicValue 'Products', 'Color', @Counter, @Color

    SET @Counter = @Counter + 1
END 