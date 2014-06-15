package kemsky.sql.async
{
    import com.codecatalyst.promise.Promise;

    public interface ITransaction
    {
        function insert(entity:*):void;

        function update(entity:*, columns:Array = null, values:Array = null, conditions:Array = null):void;

        function remove(entity:*, conditions:Array = null):void;

        function save(entity:*):void;

        function get query():IQuery;

        function get run():Promise;
    }
}
