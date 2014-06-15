package kemsky.sql.async
{
    import com.codecatalyst.promise.Promise;

    import flash.data.SQLResult;
    import flash.utils.getTimer;

    import mx.logging.ILogger;
    import mx.logging.Log;

    public class Query extends SQLOperation implements IQuery
    {
        private static const _log:ILogger = Log.getLogger("kemsky.sql.async.Query");

        private var _transform:Function;

        public function Query()
        {
            this.log = _log;
        }

        public function get parameters():Object
        {
            return statement.parameters;
        }

        public function set transform(callback:Function):void
        {
            _transform = callback;
        }

        public function get run():Promise
        {
            return this.execute();
        }

        override protected function onResult(result:SQLResult):void
        {
            log.info("[SQL] {0}ms", (getTimer() - start));
            _result = _transform != null ? _transform(result) : result;
            deferred.resolve(this);
        }

        override public function dispose():void
        {
            super.dispose();
            _transform = null;
        }
    }
}
