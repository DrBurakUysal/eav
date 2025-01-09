-- Kategoriler tablosu
IF NOT EXISTS (SELECT 1 FROM DynamicTable WHERE TableName = 'Categories' AND IsActive = 1)
BEGIN
    EXEC sp_CreateDynamicTable 'Categories'
    
    -- Kolonları ekle
    EXEC sp_AddDynamicColumn 'Categories', 'CategoryName', 'STRING', 1, 'Kategori adı'
    EXEC sp_AddDynamicColumn 'Categories', 'ParentCategory', 'STRING', 0, 'Üst kategori'
    EXEC sp_AddDynamicColumn 'Categories', 'Description', 'STRING', 0, 'Açıklama'

    -- Örnek kategoriler
    DECLARE @Categories TABLE (Id INT, Name NVARCHAR(100), Parent NVARCHAR(100), Description NVARCHAR(500))
    INSERT INTO @Categories VALUES
    (1, 'Elektronik', NULL, 'Elektronik ürünler'),
    (2, 'Bilgisayarlar', 'Elektronik', 'Dizüstü ve masaüstü bilgisayarlar'),
    (3, 'Telefonlar', 'Elektronik', 'Akıllı telefonlar ve aksesuarları'),
    (4, 'Tablet', 'Elektronik', 'Tabletler ve e-okuyucular'),
    (5, 'Ev Elektroniği', 'Elektronik', 'TV, ses sistemleri ve ev sinema sistemleri'),
    (6, 'Oyun & Eğlence', 'Elektronik', 'Oyun konsolları ve aksesuarları'),
    (7, 'Kamera', 'Elektronik', 'Fotoğraf makineleri ve video kameralar'),
    (8, 'Aksesuar', 'Elektronik', 'Elektronik aksesuarlar'),
    (9, 'Yazıcılar', 'Bilgisayarlar', 'Yazıcılar ve tarayıcılar'),
    (10, 'Ağ Ürünleri', 'Bilgisayarlar', 'Router, modem ve ağ ekipmanları')

    -- Kategorileri ekle
    DECLARE @Counter INT = 1
    WHILE @Counter <= 10
    BEGIN
        DECLARE @Name NVARCHAR(100), @Parent NVARCHAR(100), @Desc NVARCHAR(500)
        SELECT @Name = Name, @Parent = Parent, @Desc = Description 
        FROM @Categories WHERE Id = @Counter

        EXEC sp_AddDynamicValue 'Categories', 'CategoryName', @Counter, @Name
        EXEC sp_AddDynamicValue 'Categories', 'ParentCategory', @Counter, @Parent
        EXEC sp_AddDynamicValue 'Categories', 'Description', @Counter, @Desc

        SET @Counter = @Counter + 1
    END
END 