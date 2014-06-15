package kemsky.sql
{
    public class Index
    {
        private var _name:String;

        [ArrayElementType("String")]
        private var _columns:Array;

        private var _unique:Boolean;

        public function Index(name:String, columns:Array, unique:Boolean)
        {
            this._name = name;
            this._columns = columns;
            this._unique = unique;
        }

        public function get name():String
        {
            return _name;
        }

        public function get unique():Boolean
        {
            return _unique;
        }

        [ArrayElementType("String")]
        public function get columns():Array
        {
            return _columns;
        }

        public function toString():String
        {
            return "Index{name=" + String(_name) + ",columns=" + String(_columns) + "}";
        }
    }
}
