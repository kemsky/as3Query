package kemsky.sql
{
    public class RestrictionLike implements IRestriction
    {
        private var attr_name:String;
        private var param_name:String;

        private var params:Array = [];

        public function RestrictionLike(attr_name:String, value:*)
        {
            this.attr_name = attr_name;
            this.param_name = ParameterNameGenerator.create(attr_name);
            this.params.push(new Parameter(param_name, "'%" + value + "%'"));
        }

        public function get sql():String
        {
            return attr_name + " LIKE " + param_name;
        }

        [ArrayElementType("kemsky.sql.Parameter")]
        public function get parameters():Array
        {
            return params;
        }

        public function toString():String
        {
            return "RestrictionLike{attr_name=" + String(attr_name) + ",param_name=" + String(param_name) + ",params=" + String(params) + "}";
        }
    }
}
