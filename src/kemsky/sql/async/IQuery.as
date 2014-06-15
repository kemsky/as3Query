package kemsky.sql.async
{
    import com.codecatalyst.promise.Promise;

    public interface IQuery
    {
        function set text(value:String):void;
        function get parameters():Object;
        function set itemClass(clazz:Class):void;
        function set transform(callback:Function):void;
        function get run():Promise;
    }
}
