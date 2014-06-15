package kemsky.sql.async
{
    import flash.data.SQLResult;

    import kemsky.sql.EntityDescriptor;
    import kemsky.sql.EntityMapper;
    import kemsky.sql.ParameterNameGenerator;

    import mx.logging.ILogger;
    import mx.logging.Log;

    public class InsertOperation extends SQLOperation
    {
        private static const _log:ILogger = Log.getLogger("kemsky.sql.async.InsertOperation");

        private var entity:Object;
        private var descriptor:EntityDescriptor;

        public function InsertOperation(entity:Object, mapper:EntityMapper)
        {
            this.entity = entity;
            this.descriptor = mapper.getDescriptor(entity.constructor);
            this.log = _log;
        }

        public override function prepare():void
        {
            var parameters:Array = [];
            var columns:Array = [];

            var pkValue:* =  entity[descriptor.primaryKey];
            var allowPk:Boolean = pkValue != null && pkValue != 0 && (!(pkValue is Number) || !isNaN(pkValue));

            for each (var column:String in descriptor.columns)
            {
                if (allowPk || column != descriptor.primaryKey)
                {
                    columns.push(column);
                    var param_name:String = ParameterNameGenerator.create(column);
                    parameters.push(param_name);
                    statement.parameters[param_name] = entity[column];
                }
            }

            this.text = "INSERT INTO " + descriptor.tableName + " (" + columns.join(",") + ") VALUES (" + parameters.join(",") + ")";
        }

        override public function get result():*
        {
            return entity;
        }

        override protected function onResult(result:SQLResult):void
        {
            entity[descriptor.primaryKey] = result.lastInsertRowID;
            super.onResult(result);
        }

        override public function dispose():void
        {
            super.dispose();
            entity = null;
        }

        public function toString():String
        {
            return "InsertOperation{entity=" + String(entity) + "}";
        }
    }
}
