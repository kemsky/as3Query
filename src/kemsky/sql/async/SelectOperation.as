package kemsky.sql.async
{
    import flash.data.SQLResult;
    import flash.utils.getTimer;

    import kemsky.sql.EntityDescriptor;
    import kemsky.sql.EntityMapper;
    import kemsky.sql.IOrder;
    import kemsky.sql.IRestriction;
    import kemsky.sql.Parameter;

    import mx.logging.ILogger;
    import mx.logging.Log;

    public class SelectOperation extends SQLOperation
    {
        private static const _log:ILogger = Log.getLogger("kemsky.sql.async.SelectOperation");

        private var descriptor:EntityDescriptor;

        [ArrayElementType("String")]
        private var fields:Array;

        [ArrayElementType("kemsky.sql.IRestriction")]
        private var conditions:Array;
        private var order:IOrder;
        private var uniqueResult:Boolean;
        private var distinct:Boolean;
        private var count:Boolean;

        public function SelectOperation(manager:EntityMapper, entity:Class, fields:Array, conditions:Array, order:IOrder, uniqueResult:Boolean, distinct:Boolean, count:Boolean = false)
        {
            this.distinct = distinct;
            this.count = count;
            this.descriptor = manager.getDescriptor(entity);
            this.fields = fields;
            this.conditions = conditions;
            this.order = order;
            this.uniqueResult = uniqueResult;
            this.log = _log;
        }

        public override function prepare():void
        {
            conditions = conditions != null ? conditions : [];

            var sql:String = "SELECT " + (distinct ? " DISTINCT " : "") + (count ? "count(1)": fields.join(",")) + " FROM " + descriptor.tableName;

            if (conditions.length > 0)
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

            if (order != null)
            {
                sql += order.sql;
            }

            this.text = sql;

            if(!count)
            {
                this.itemClass = descriptor.entity;
            }
        }

        override protected function onResult(result:SQLResult):void
        {
            log.info("[SQL] rows selected: {0}", (result.data != null ? result.data.length : 0));
            log.info("[SQL] {0}ms", (getTimer() - start));
            var hasData:Boolean = (result.data != null && result.data.length > 0);
            if (uniqueResult)
            {
                _result = hasData ? result.data[0] : null;
                if (!hasData || result.data.length == 1)
                {
                    deferred.resolve(this);
                }
                else
                {
                    deferred.reject(new Error("Exactly one or none rows expected, got: " + result.data.length));
                }
            }
            else
            {
                _result = hasData ? result.data : [];
                deferred.resolve(this);
            }
        }

        override public function dispose():void
        {
            super.dispose();
            descriptor = null;
            fields = null;
            conditions = null;
            order = null;
        }

        public function toString():String
        {
            return "SelectOperation{entity=" + String(descriptor) + ",fields=" + String(fields) + ",conditions=" + String(conditions) + ",order=" + String(order) + ",uniqueResult=" + String(uniqueResult) + "}";
        }
    }
}
