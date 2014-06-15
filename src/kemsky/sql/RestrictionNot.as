package kemsky.sql
{
    public class RestrictionNot implements IRestriction
    {
        private var restriction:IRestriction;

        public function RestrictionNot(restriction:IRestriction)
        {
            this.restriction = restriction;
        }

        public function get sql():String
        {
            return "not (" + restriction.sql + " )";
        }

        [ArrayElementType("kemsky.sql.Parameter")]
        public function get parameters():Array
        {
            return restriction.parameters;
        }


        public function toString():String
        {
            return "RestrictionNot{restriction=" + String(restriction) + "}";
        }
    }
}
