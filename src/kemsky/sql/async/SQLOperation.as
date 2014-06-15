package kemsky.sql.async
{
    import com.codecatalyst.promise.Deferred;
    import com.codecatalyst.promise.Promise;

    import flash.data.SQLConnection;
    import flash.data.SQLResult;
    import flash.data.SQLStatement;
    import flash.errors.SQLError;
    import flash.net.Responder;
    import flash.utils.getTimer;

    import mx.logging.ILogger;

    public class SQLOperation extends DeferredBase
    {
        public static const PRINT_EXPLAIN_PLAN:Boolean = false;

        protected var log:ILogger;

        protected var sqlConnection:SQLConnection;

        protected var deferred:Deferred;

        protected var start:Number;

        protected var statement:SQLStatement;

        private var _text:String;

        private var _itemClass:Class;

        public function SQLOperation()
        {
            statement = new SQLStatement();
        }

        public override function get result():*
        {
            return _result;
        }

        public override function get error():*
        {
            return _error;
        }


        public function get itemClass():Class
        {
            return _itemClass;
        }

        public function set itemClass(value:Class):void
        {
            _itemClass = value;
        }

        public function get text():String
        {
            return _text;
        }

        public function set text(value:String):void
        {
            _text = value;
        }

        public function setConnection(sqlConnection:SQLConnection):void
        {
            this.sqlConnection = sqlConnection;
            this.statement.sqlConnection = sqlConnection;
        }

        public function prepare():void
        {

        }

        public override function execute():Promise
        {
            deferred = new Deferred();
            start = getTimer();

            prepare();

            log.info("[SQL] {0}", text);

            if(PRINT_EXPLAIN_PLAN)
            {
                statement.text = "EXPLAIN " + text;
                statement.itemClass = ExplainPlanRow;

                statement.execute(-1, new Responder(function (result:SQLResult):void
                {
                    new PrintExplainPlan(result.data).call();
                    start = getTimer();
                    statement.itemClass = itemClass;
                    statement.text = text;
                    statement.execute(-1, new Responder(onResult, onError));
                }, onError));
            }
            else
            {
                statement.itemClass = itemClass;
                statement.text = text;
                statement.execute(-1, new Responder(onResult, onError));
            }

            return deferred.promise;
        }

        protected function onError(error:SQLError):void
        {
            _error = error;
            log.error("error: {0}", _error.getStackTrace());
            deferred.reject(_error);
        }

        protected function onResult(result:SQLResult):void
        {
            log.info("[SQL] {0}ms", (getTimer() - start));
            _result = result;
            deferred.resolve(this);
        }

        public override function dispose():void
        {
            super.dispose();

            statement.clearParameters();

            statement = null;

            sqlConnection = null;

            _result = null;
            _error = null;
        }
    }
}