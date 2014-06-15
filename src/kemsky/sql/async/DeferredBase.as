package kemsky.sql.async
{
    import com.codecatalyst.promise.Promise;

    public class DeferredBase implements ISQLOperation
    {
        protected var _error:Error;
        protected var _result:*;
        protected var disposed:Boolean;

        public function DeferredBase()
        {
        }

        public function execute():Promise
        {
            return null;
        }

        public function get result():*
        {
            return _result;
        }

        public function get error():*
        {
            return _error;
        }

        public function dispose():void
        {
            disposed = true;
            _error = null;
            _result = null;
        }
    }
}
