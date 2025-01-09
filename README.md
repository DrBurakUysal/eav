# 🎯 Dynamic Table Structure (DTS)

## 📚 İçindekiler
- [Genel Bakış](#genel-bakış)
- [Mimari Yapı](#mimari-yapı)
- [Kurulum](#kurulum)
- [Kullanım Örnekleri](#kullanım-örnekleri)
- [Performans İpuçları](#performans-ipuçları)

## 🎯 Genel Bakış

DynamicTable yapısı, geleneksel veritabanı tasarımının esnek olmayan yapısını aşmak için geliştirilmiş bir modeldir. Bu yapı, dinamik olarak yeni özellikler ekleyebilmenize ve farklı veri tiplerini yönetebilmenize olanak sağlar.

### 📊 Geleneksel vs DynamicTable Karşılaştırması

![Karşılaştırma](images/comparison.png)

### Geleneksel vs DynamicTable Karşılaştırması

#### Geleneksel Yaklaşım
- ✅ Basit ve anlaşılır yapı
- ✅ Doğrudan SQL sorguları
- ❌ Schema değişiklikleri zor
- ❌ Yeni özellikler için ALTER TABLE gerekir

#### DynamicTable Yaklaşım
- ✅ Esnek ve genişletilebilir yapı
- ✅ Yeni özellikler dinamik olarak eklenebilir
- ✅ Schema değişikliği gerektirmez
- ❌ Daha karmaşık sorgular
- ❌ Performans optimizasyonu gerektirir

## 🏗 Mimari Yapı

### Tablolar ve İlişkiler:

![Mimari](images/architecture.png)

#### 1. DynamicTable
- TableId (PK)
- TableName
- IsActive
- CreatedDate
- ModifiedDate

#### 2. DynamicColumn
- ColumnId (PK)
- ColumnName
- ColumnType
- IsRequired
- Description

#### 3. DynamicValue
- ValueId (PK)
- TableId (FK)
- ColumnId (FK)
- StringValue
- IntegerValue
- DecimalValue
- DateValue

## 🚀 Kurulum

1. Veritabanı scriptlerini çalıştırın: -- create_database.sql dosyasını çalıştırın

2. Sırasıyla aşağıdaki script'leri çalıştırın:
- `scripts/create_database.sql`
- `scripts/01_alter_tables.sql`

3. (Opsiyonel) Örnek verileri yükleyin:
- `sample_data/sample_data.sql`
- `sample_data/02_categories.sql`
- `sample_data/03_customers.sql`
- `sample_data/04_orders.sql`
- `sample_data/05_additional_products.sql`

## 📝 Kullanım Örnekleri

### 1. Yeni Bir Tablo Oluşturma
EXEC sp_CreateDynamicTable 'Products'

### 2. Kolon Ekleme
```sql
EXEC sp_AddDynamicColumn 
    @TableName = 'Products',
    @ColumnName = 'ProductName',
    @ColumnType = 'STRING',
    @IsRequired = 1,
    @Description = 'Ürün adı'
```

### 3. Veri Ekleme
```sql
EXEC sp_AddDynamicValue 
    @TableName = 'Products',
    @ColumnName = 'ProductName',
    @RowId = 1,
    @Value = 'MacBook Pro'
```

### 4. Veri Sorgulama
```sql
EXEC sp_GetDynamicData 'Products'
```

## Örnek Senaryolar

### Ürün Kataloğu
```sql
-- Ürünler tablosunu oluştur
EXEC sp_CreateDynamicTable 'Products'

-- Kolonları ekle
EXEC sp_AddDynamicColumn 'Products', 'ProductName', 'STRING', 1, 'Ürün adı'
EXEC sp_AddDynamicColumn 'Products', 'Price', 'DECIMAL', 1, 'Fiyat'
EXEC sp_AddDynamicColumn 'Products', 'Stock', 'INTEGER', 1, 'Stok'

-- Veri ekle
EXEC sp_AddDynamicValue 'Products', 'ProductName', 1, 'iPhone 15 Pro'
EXEC sp_AddDynamicValue 'Products', 'Price', 1, 64999.99
EXEC sp_AddDynamicValue 'Products', 'Stock', 1, 100
```

### Müşteri Yönetimi
```sql
-- Müşteriler tablosunu oluştur
EXEC sp_CreateDynamicTable 'Customers'

-- Kolonları ekle
EXEC sp_AddDynamicColumn 'Customers', 'FirstName', 'STRING', 1, 'Ad'
EXEC sp_AddDynamicColumn 'Customers', 'LastName', 'STRING', 1, 'Soyad'
EXEC sp_AddDynamicColumn 'Customers', 'Email', 'STRING', 1, 'E-posta'
```

## API Referansı

### Stored Procedures

| Prosedür | Açıklama | Örnek Kullanım |
|----------|----------|----------------|
| sp_CreateDynamicTable | Yeni tablo oluşturur | `EXEC sp_CreateDynamicTable 'Products'` |
| sp_AddDynamicColumn | Kolonu ekler | `EXEC sp_AddDynamicColumn 'Products', 'Price', 'DECIMAL', 1` |
| sp_AddDynamicValue | Veri ekler | `EXEC sp_AddDynamicValue 'Products', 'Price', 1, 999.99` |
| sp_GetDynamicData | Verileri sorgular | `EXEC sp_GetDynamicData 'Products'` |
| sp_GetTableDesign | Tablo yapısını gösterir | `EXEC sp_GetTableDesign 'Products'` |

## Performans Optimizasyonları

1. **İndeksler**
- Her tabloda filtered index'ler kullanılmıştır
- IsActive = 1 koşulu için optimize edilmiştir
- Sık kullanılan sorgular için covering index'ler eklenmiştir

2. **Trigger'lar**
- UpdateDate alanları otomatik güncellenir
- SET NOCOUNT ON ile performans iyileştirilmiştir

3. **Constraints**
- Veri bütünlüğü için foreign key'ler eklenmiştir
- UNIQUE constraint'ler ile tekrar eden kayıtlar engellenmiştir

## Lisans
MIT License - Detaylar için [LICENSE](LICENSE) dosyasına bakın.