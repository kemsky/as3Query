As3Query
========

Another ORM and query DSL for ActionScript

Uses [Promises/A+](https://github.com/CodeCatalyst/promise-as3) library.

Annotations list:
* Specify table name `[Table(name="test")]`
* Specify table index (or multiple indices) `[Index(name="test_index_1", columns="unsigned,bool", unique="true")]`
* Specify table column `[Column(primaryKey, nullable="false", unique="true", foreignKey="table(id)", options="deferred", default="1")]`

Usage:

1. Put annotations:
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
2. Map entity:

    ```ActionScript
        var entityManager:EntityMapper = new EntityMapper();
        entityManager.registerEntity(TestEntity);
    ```
3. Create tables:

    ```ActionScript
         var connection:SQLConnection = new SQLConnection();
         connection.open(file, SQLMode.CREATE);
         try
         {
            new CreateTables(connection, [TestEntity], mapper).call();
         }
         finally
         {
             if(connection.connected)
             {
                 connection.close();
             }
         }
    ```
4. Create session:

    ```ActionScript
        var session:Session = new Session(mapper);
        session.open(file.nativePath, SQLMode.UPDATE).then(function ():void{ trace('ok') });
    ```
5. Perform different operations:
    
    <b>Transactions</b>
    ```ActionScript
        var transaction:ITransaction = session.transaction;

        transaction.insert(testCriteriaEntity1);
        transaction.insert(testCriteriaEntity2);
        transaction.remove(TestCriteriaEntity);
        transaction.insert(testCriteriaEntity1);
        transaction.insert(testCriteriaEntity2);
        
        transaction.run.then(function ():void{ trace('ok') });
    ```
    
    <b>Criteria</b>
    ```ActionScript
        session.criteria(TestEntity).by(Order.asc(TestCriteriaEntity.ATTR_ID)).list.then(function ():void{ trace('ok') });
        session.criteria(TestEntity).unique.then(function ():void{ trace('ok') });
    ```
    
Acceptable performance on Samsung Galaxy Tab 10.1

You can add metadata validation to Intellij Idea using KnownMetaData.dtd file.
Open Preferences > Schemas and DTDs > Add KnownMetaData.dtd with URI urn:Flex:Meta
