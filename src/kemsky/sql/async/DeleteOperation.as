package kemsky.sql.async
{
    import flash.data.SQLResult;
    import flash.utils.getTimer;

    import kemsky.sql.EntityDescriptor;
    import kemsky.sql.EntityMapper;
    import kemsky.sql.IRestriction;
    import kemsky.sql.Parameter;
    import kemsky.sql.Restrictions;

    import mx.logging.ILogger;
    import mx.logging.Log;

    public class DeleteOperation extends SQLOperation
    {
        private static const _log:ILogger = Log.getLogger("kemsky.sql.async.DeleteOperation");

        private var descriptor:EntityDescriptor;
        private var entity:*;

        [ArrayElementType("kemsky.sql.IRestriction")]
        private var conditions:Array;

        public function DeleteOperation(entity:*, mapper:EntityMapper, conditions:Array = null)
        {
            var isEntity:Boolean = !(entity is Class);
            this.descriptor = mapper.getDescriptor(isEntity ? entity.constructor : entity);
            this.conditions = conditions ? conditions : [];
            this.entity = entity;
            this.log = _log;

            if(isEntity)
            {
                this.conditions.push(Restrictions.Eq(descriptor.primaryKey, entity[descriptor.primaryKey]));
            }
        }

        public override function prepare():void
        {
            var sql:String = "DELETE FROM " + descriptor.tableName;

            if(conditions.length > 0)
            {
                sql += " WHERE ";
            }

            for (var k:int = 0; k < conditions.length; k++)
            {
                var restriction:IRestriction = IRestriction(conditions[k]);
                sql += restriction.sql + (k != conditions.length - 1 ? " and " : "");
                for each (var parameter:Parameter in restriction.parameters)
                {
                    statement.parameters[parameter.name] = parameter.value;
                }
            }

            this.text = sql;
        }


        override protected function onResult(result:SQLResult):void
        {
            _result = result.rowsAffected;
            log.info("[SQL] rows deleted: {0}", _result);
            log.info("[SQL] {0}ms", (getTimer() - start));
            deferred.resolve(this);
        }

        override public function get result():*
        {
            return _result.rowsAffected;
        }

        override public function dispose():void
        {
            super.dispose();
            descriptor = null;
            conditions = null;
        }

        public function toString():String
        {
            return "DeleteOperation{entity=" + String(descriptor) + ",conditions=" + String(conditions) + "}";
        }
    }
}
