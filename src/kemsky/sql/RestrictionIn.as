package kemsky.sql
{
    public class RestrictionIn implements IRestriction
    {
        private var attr_name:String;

        [ArrayElementType("kemsky.sql.Parameter")]
        private var params:Array = [];

        [ArrayElementType("String")]
        private var parameterNames:Array = [];

        public function RestrictionIn(attr_name:String, values:Array)
        {
            this.attr_name = attr_name;

            for each (var value:Object in values)
            {
                var name:String = ParameterNameGenerator.create(attr_name);
                this.parameterNames.push(name);
                this.params.push(new Parameter(name, value));
            }
        }

        public function get sql():String
        {
            return parameterNames.length > 0 ? attr_name + " in (" + parameterNames.join(",") + ")" : "(1=1)";
        }

        [ArrayElementType("kemsky.sql.Parameter")]
        public function get parameters():Array
        {
            return params;
        }

        public function toString():String
        {
            return "RestrictionIn{attr_name=" + String(attr_name) + ",params=" + String(params) + ",parameterNames=" + String(parameterNames) + "}";
        }
    }
}
