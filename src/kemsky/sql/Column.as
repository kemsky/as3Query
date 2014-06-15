package kemsky.sql
{
    public class Column
    {
        public var name:String;
        public var type:String;
        public var primaryKey:Boolean;
        public var nullable:Boolean;
        public var defValue:String;
        public var foreignKey:String;
        public var options:String;
        public var unique:Boolean;

        public function Column(name:String, type:String, primaryKey:Boolean, nullable:Boolean, defValue:String, foreignKey:String, options:String, unique:Boolean)
        {
            this.name = name;
            this.type = type;
            this.primaryKey = primaryKey;
            this.nullable = nullable;
            this.defValue = defValue;
            this.foreignKey = foreignKey;
            this.options = options;
            this.unique = unique;
        }

        public function toString():String
        {
            return "Column{name=" + String(name) + ",type=" + String(type) + ",primaryKey=" + String(primaryKey) + ",nullable=" + String(nullable) + ",defValue=" + String(defValue) + ",foreignKey=" + String(foreignKey) + ",options=" + String(options) + "}";
        }
    }
}
