package kemsky.sql
{
    public class Parameter
    {
        public var name:String;
        public var value:*;

        public function Parameter(name:String, value:*)
        {
            this.name = name;
            this.value = value;
        }

        public function toString():String
        {
            return "Parameter{name=" + String(name) + ",value=" + String(value) + "}";
        }
    }
}
