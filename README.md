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


## 📝 Kullanım Örnekleri

### 1. Yeni Bir Tablo Oluşturma