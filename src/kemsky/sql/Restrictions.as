package kemsky.sql
{
    public class Restrictions
    {
        public static function Eq(attr_name:String, value:*):IRestriction
        {
            return new RestrictionEquals(attr_name, value);
        }

        public static function Or(restrictions:Array):IRestriction
        {
            return new RestrictionOr(restrictions);
        }

        public static function Sql(sql:String, params:Object = null):IRestriction
        {
            return new RestrictionSql(sql, params);
        }

        public static function Ge(attr_name:String, value:*):IRestriction
        {
            return new RestrictionGe(attr_name, value);
        }

        public static function In(attr_name:String, value:Array):IRestriction
        {
            return new RestrictionIn(attr_name, value);
        }

        public static function Not(restriction:IRestriction):IRestriction
        {
            return new RestrictionNot(restriction);
        }

        public static function Le(attr_name:String, value:*):IRestriction
        {
            return new RestrictionLe(attr_name, value);
        }

        public static function Like(attr_name:String, value:*):IRestriction
        {
            return new RestrictionLike(attr_name, value);
        }
    }
}
