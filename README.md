As3Query
========

Another ORM and query DSL for ActionScript

Uses [Promises/A+](https://github.com/CodeCatalyst/promise-as3) library

Usage:

1. Annotations list:
* Specify table name `[Table(name="test")]`
* Specify table index (or multiple indices) `[Index(name="test_index_1", columns="unsigned,bool", unique="true")]`
* Specify table column `[Column(primaryKey, nullable="false", unique="true", foreignKey="table(id)", options="deferred", default="1")]`

2. Put annotations:
    ```ActionScript
        [Table(name="test")]
        [Index(name="test_index_1", columns="unsigned,bool")]
        [Index(name="test_index_2", columns="str", unique="true")]
        public dynamic class TestEntity
        {
            [Column(primaryKey, nullable="false")]
            public var id:int;
    
            [Column(default="1")]
            public var unsigned:uint;
    
            [Column(unique="true")]
            public var date:Date;
    
            [Column]
            public var xml:XML;
    
            [Column]
            public var xmlList:XMLList;
    
            [Column]
            public var object:Object;
    
            [Column]
            public var bool:Boolean;
    
            [Column]
            public var num:Number;
    
            [Column]
            public var str:String;
    
            [Column(foreignKey="table(id)", options="deferred")]
            public var fk_table:String;
        }
    ```
3. Map entity:
    ```ActionScript
        var entityManager:EntityMapper = new EntityMapper();
        entityManager.registerEntity(TestEntity);
    ```
4.     
Acceptable performance on Samsung Galaxy Tab 10.1

You can add metadata validation to Intellij Idea using KnownMetaData.dtd file.
Open Preferences > Schemas and DTDs > Add KnownMetaData.dtd with URI urn:Flex:Meta
