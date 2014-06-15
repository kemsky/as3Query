package kemsky.sql
{
    public class EntityDescriptor
    {
        private var _entity:Class;
        private var _tableName:String;
        private var _primaryKey:String;

        [ArrayElementType("String")]
        private var _columns:Array;

        [ArrayElementType("kemsky.sql.Column")]
        private var _columnDescriptors:Array;
        private var _foreignKeys:Array;

        [ArrayElementType("kemsky.sql.Index")]
        private var _indices:Array;

        public function EntityDescriptor(entity:Class, tableName:String, columns:Array, foreignKeys:Array, indices:Array)
        {
            this._entity = entity;
            this._tableName = tableName;
            this._foreignKeys = foreignKeys;
            this._indices = indices;

            var primary:Array = columns.filter(function (item:Column, index:uint, array:Array):Boolean
            {
                return item.primaryKey;
            });

            if(primary.length == 0)
            {
                throw new Error("Primary key is not defined: " + tableName);
            }

            this._primaryKey = Column(primary[0]).name;
            this._columns = columns.map(function (column:Column, index:uint, array:Array):String
            {
                return column.name;
            });
            this._columnDescriptors = columns;
        }

        public function get entity():Class
        {
            return _entity;
        }

        public function get tableName():String
        {
            return _tableName;
        }

        public function get primaryKey():String
        {
            return _primaryKey;
        }

        [ArrayElementType("String")]
        public function get columns():Array
        {
            return _columns;
        }

        [ArrayElementType("kemsky.sql.Column")]
        public function get columnDescriptors():Array
        {
            return _columnDescriptors;
        }

        [ArrayElementType("kemsky.sql.Column")]
        public function get foreignKeys():Array
        {
            return _foreignKeys;
        }

        [ArrayElementType("kemsky.sql.Index")]
        public function get indices():Array
        {
            return _indices;
        }

        public function getTableScript():String
        {
            var ddl:String = "CREATE TABLE " + _tableName + " (\n";

            var cols:Array = [];
            for each (var column:Column in _columnDescriptors)
            {
                var columnString:String = column.name + " " + column.type + (column.primaryKey ? " PRIMARY KEY" : "") +
                        (column.nullable ? "" : " NOT NULL") + (column.unique ? " UNIQUE" : "") +
                        (column.defValue == null ? "" : " DEFAULT(" + column.defValue + ")");
                cols.push(columnString);
            }


            if(_foreignKeys.length > 0)
            {
                for each (var foreignKey:Column in _foreignKeys)
                {
                    cols.push("FOREIGN KEY ( " + foreignKey.name + " ) REFERENCES " + foreignKey.foreignKey + (foreignKey.options ? " " + foreignKey.options : ""));
                }
            }

            ddl += cols.join(",\n");

            ddl += "\n);";
            return ddl;
        }

        public function getIndexScripts():Array
        {
            var result:Array = [];

            for each (var index:Index in _indices)
            {
                var ddl:String = "CREATE " + (index.unique ? "UNIQUE " : "") + "INDEX " + index.name + " ON " + _tableName + " (\n";

                ddl += index.columns.join(",\n");

                ddl += "\n);";

                result.push(ddl);
            }

            return result;
        }

        public function toString():String
        {
            return "EntityDescriptor{_entity=" + String(_entity) + ",_tableName=" + String(_tableName) + ",_primaryKey=" + String(_primaryKey) + ",_columns=" + String(_columns) + ",_columnDescriptors=" + String(_columnDescriptors) + ",_foreignKeys=" + String(_foreignKeys) + ",_indices=" + String(_indices) + "}";
        }
    }
}
