package kemsky.sql
{
    public class RestrictionOr implements IRestriction
    {
        private var params:Array = [];
        private var sqlString:String = "";

        public function RestrictionOr(restrictions:Array)
        {
            if(restrictions.length > 0)
            {
                sqlString += "(";
                for(var k:int = 0; k < restrictions.length; k++)
                {
                    var restriction:IRestriction = IRestriction(restrictions[k]);
                    sqlString += restriction.sql + (k != restrictions.length - 1 ? " or " : "");
                    for each (var parameter:Parameter in restriction.parameters)
                    {
                        params.push(parameter);
                    }
                }
                sqlString += ")";
            }
            else
            {
                sqlString = "(1=1)";
            }
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
            return "RestrictionOr{params=" + String(params) + ",sqlString=" + String(sqlString) + "}";
        }
    }
}
