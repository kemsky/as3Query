package kemsky.sql
{
    public class RestrictionSql implements IRestriction
    {
        private var params:Array = [];
        private var sqlString:String = "";

        public function RestrictionSql(sql:String, params:Object = null)
        {
            params = params ? params : {};
            for (var param:String in params)
            {
                this.params.push(new Parameter(param, params[param]));
            }
            sqlString = sql;
        }

        public function get sql():String
        {
            return sqlString;
        }

        [ArrayElementType("kemsky.sql.Parameter")]
        public function get parameters():Array
        {
            return params;
        }

        public function toString():String
        {
            return "RestrictionSql{params=" + String(params) + ",sqlString=" + String(sqlString) + "}";
        }
    }
}
