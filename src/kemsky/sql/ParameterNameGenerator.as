package kemsky.sql
{
    public class ParameterNameGenerator
    {
        private static var counter:Number = 0;

        public static function create(base:String):String
        {
            counter++;
            return ":" + base + counter;
        }
    }
}
