-- Müşteriler tablosu
IF NOT EXISTS (SELECT 1 FROM DynamicTable WHERE TableName = 'Customers' AND IsActive = 1)
BEGIN
    EXEC sp_CreateDynamicTable 'Customers'
    
    -- Kolonları ekle
    EXEC sp_AddDynamicColumn 'Customers', 'FirstName', 'STRING', 1, 'Ad'
    EXEC sp_AddDynamicColumn 'Customers', 'LastName', 'STRING', 1, 'Soyad'
    EXEC sp_AddDynamicColumn 'Customers', 'Email', 'STRING', 1, 'E-posta'
    EXEC sp_AddDynamicColumn 'Customers', 'Phone', 'STRING', 0, 'Telefon'
    EXEC sp_AddDynamicColumn 'Customers', 'Address', 'STRING', 0, 'Adres'
    EXEC sp_AddDynamicColumn 'Customers', 'City', 'STRING', 1, 'Şehir'
    EXEC sp_AddDynamicColumn 'Customers', 'RegisterDate', 'DATE', 1, 'Kayıt tarihi'

    -- Örnek müşteriler
    DECLARE @Customers TABLE (
        Id INT, FirstName NVARCHAR(50), LastName NVARCHAR(50), 
        Email NVARCHAR(100), Phone NVARCHAR(20), Address NVARCHAR(500),
        City NVARCHAR(50), RegisterDate DATE
    )
    
    INSERT INTO @Customers VALUES
    (1, 'Ahmet', 'Yılmaz', 'ahmet.yilmaz@email.com', '5551112233', 'Atatürk Cad. No:1', 'İstanbul', '2024-01-01'),
    (2, 'Mehmet', 'Kaya', 'mehmet.kaya@email.com', '5551112234', 'İstiklal Cad. No:2', 'Ankara', '2024-01-02'),
    (3, 'Ayşe', 'Demir', 'ayse.demir@email.com', '5551112235', 'Cumhuriyet Cad. No:3', 'İzmir', '2024-01-03'),
    -- ... (diğer müşteriler)
    (10, 'Zeynep', 'Şahin', 'zeynep.sahin@email.com', '5551112242', 'Bahçelievler Cad. No:10', 'Bursa', '2024-01-10')

    -- Müşterileri ekle
    DECLARE @Counter INT = 1
    WHILE @Counter <= 10
    BEGIN
        DECLARE @CurrCustomer TABLE (
            FirstName NVARCHAR(50), LastName NVARCHAR(50), 
            Email NVARCHAR(100), Phone NVARCHAR(20), Address NVARCHAR(500),
            City NVARCHAR(50), RegisterDate DATE
        )
        
        INSERT INTO @CurrCustomer
        SELECT FirstName, LastName, Email, Phone, Address, City, RegisterDate
        FROM @Customers WHERE Id = @Counter

        DECLARE @FirstName NVARCHAR(50), @LastName NVARCHAR(50),
                @Email NVARCHAR(100), @Phone NVARCHAR(20), @Address NVARCHAR(500),
                @City NVARCHAR(50), @RegisterDate DATE

        SELECT @FirstName = FirstName, @LastName = LastName,
               @Email = Email, @Phone = Phone, @Address = Address,
               @City = City, @RegisterDate = RegisterDate
        FROM @CurrCustomer

        EXEC sp_AddDynamicValue 'Customers', 'FirstName', @Counter, @FirstName
        EXEC sp_AddDynamicValue 'Customers', 'LastName', @Counter, @LastName
        EXEC sp_AddDynamicValue 'Customers', 'Email', @Counter, @Email
        EXEC sp_AddDynamicValue 'Customers', 'Phone', @Counter, @Phone
        EXEC sp_AddDynamicValue 'Customers', 'Address', @Counter, @Address
        EXEC sp_AddDynamicValue 'Customers', 'City', @Counter, @City
        EXEC sp_AddDynamicValue 'Customers', 'RegisterDate', @Counter, @RegisterDate

        SET @Counter = @Counter + 1
    END
END 