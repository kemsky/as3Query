package kemsky.sql
{
    public interface IRestriction
    {
        function get sql():String;

        [ArrayElementType("kemsky.sql.Parameter")] function get parameters():Array;
    }
}
