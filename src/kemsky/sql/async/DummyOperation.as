package kemsky.sql.async
{
    import mx.logging.ILogger;
    import mx.logging.Log;

    public class DummyOperation extends SQLOperation
    {
        private static const _log:ILogger = Log.getLogger("kemsky.sql.async.DummyOperation");

        public function DummyOperation()
        {
            this.log = _log;
        }

        override public function prepare():void
        {
            this.text = "SELECT 0";
        }

        public function toString():String
        {
            return "DummyOperation";
        }
    }
}
