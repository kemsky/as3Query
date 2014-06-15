package sql
{
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
}
