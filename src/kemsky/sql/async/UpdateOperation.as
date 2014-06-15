package kemsky.sql.async
{
    import flash.data.SQLResult;
    import flash.utils.getTimer;

    import kemsky.sql.EntityDescriptor;
    import kemsky.sql.EntityMapper;
    import kemsky.sql.IRestriction;
    import kemsky.sql.Parameter;
    import kemsky.sql.ParameterNameGenerator;
    import kemsky.sql.Restrictions;

    import mx.logging.ILogger;
    import mx.logging.Log;

    public class UpdateOperation extends SQLOperation
    {
        private static const _log:ILogger = Log.getLogger("kemsky.sql.async.UpdateOperation");

        private var entity:*;

        [ArrayElementType("String")]
        private var columns:Array;

        [ArrayElementType("kemsky.sql.IRestriction")]
        private var conditions:Array;

        private var descriptor:EntityDescriptor;

        [ArrayElementType("String")]
        private var parameters:Array = [];

        public function UpdateOperation(entity:*, mapper:EntityMapper, columns:Array = null, values:Array = null, conditions:Array = null)
        {
            var isEntity:Boolean = !(entity is Class);
            this.entity = entity;
            this.conditions = conditions ? conditions : [];
            this.descriptor = mapper.getDescriptor(isEntity ? entity.constructor : entity);
            this.columns = columns != null ? columns : descriptor.columns;
            this.log = _log;

            var param_name:String;
            if(isEntity)
            {
                this.conditions.push(Restrictions.Eq(descriptor.primaryKey, entity[descriptor.primaryKey]));
                for each (var column:String in this.columns)
                {
                    if (column != descriptor.primaryKey)
                    {
                        param_name = ParameterNameGenerator.create(column);
                        parameters.push(column + "=" + param_name);
                        statement.parameters[param_name] = entity[column];
                    }
                }
            }
            else
            {
                if(this.columns.length != values.length)
                {
                    throw new Error("Columns length must be equal to values length");
                }
                for(var i:int = 0; i < this.columns.length; i++)
                {
                    param_name = ParameterNameGenerator.create(this.columns[i]);
                    parameters.push(this.columns[i] + "=" + param_name);
                    statement.parameters[param_name] = values[i];
                }
            }
        }

        public override function prepare():void
        {

            var sql:String = "UPDATE " + descriptor.tableName + " SET ";

            sql += parameters.join(",");


            if(conditions.length > 0)
            {
                sql += " WHERE ";
            }


            for (var k:int = 0; k < conditions.length; k++)
            {
                var restriction:IRestriction = IRestriction(conditions[k]);
                sql += restriction.sql + (k != conditions.length - 1 ? " AND " : "");
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
            log.info("[SQL] rows updated: {0}", _result);
            log.info("[SQL] {0}ms", (getTimer() - start));
            if(_result != 1)
            {
                this._error = new Error("Zero rows were updated, id=" + entity[descriptor.primaryKey]);
                deferred.reject(this._error);
            }
            else
            {
                deferred.resolve(this);
            }
        }

        override public function get result():*
        {
            return entity;
        }

        override public function dispose():void
        {
            super.dispose();
            entity = null;
            columns = null;
            conditions = null;
        }

        public function toString():String
        {
            return "UpdateOperation{entity=" + String(entity) + ",columns=" + String(columns) + ",conditions=" + String(conditions) + "}";
        }
    }
}
