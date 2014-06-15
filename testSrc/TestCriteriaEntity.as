package {
    [Table(name="test")]
    public dynamic class TestCriteriaEntity
    {
        public static const ATTR_ID:String = "id";

        [Column(primaryKey, nullable="false")]
        public var id:int = 0;
        
        [Column]
        public var str:String;
    }
}
