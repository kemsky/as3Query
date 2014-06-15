package kemsky.sql
{
    public class Order implements IOrder
    {
        public static const ASC:String = "asc";
        public static const DESC:String = "desc";

        private var sqlString:String = "";

        public function Order(order:String, columns:Array)
        {
            sqlString = " order by " + columns.join(",") + " " + order;
        }

        public function get sql():String
        {
            return sqlString;
        }

        public static function asc(...rest):IOrder
        {
            return new Order(Order.ASC, rest);
        }

        public static function desc(...rest):IOrder
        {
            return new Order(Order.DESC, rest);
        }
    }
}
