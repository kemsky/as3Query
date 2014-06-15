package kemsky.sql.async
{
    import com.codecatalyst.promise.Promise;

    public interface ISQLOperation
    {
        function execute():Promise;

        function get result():*;

        function get error():*;

        function dispose():void;
    }
}
