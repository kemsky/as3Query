package kemsky.sql.async
{
    import avmplus.Types;

    import com.codecatalyst.promise.Deferred;
    import com.codecatalyst.promise.Promise;

    import flash.data.SQLConnection;
    import flash.data.SQLTransactionLockType;
    import flash.events.Event;
    import flash.events.SQLErrorEvent;
    import flash.events.SQLEvent;

    import mx.logging.ILogger;
    import mx.logging.Log;

    public class TransactionOperation extends DeferredBase
    {
        private static const _log:ILogger = Log.getLogger("kemsky.sql.async.TransactionOperation");

        [ArrayElementType("kemsky.sql.async.ISQLOperation")]
        private var operations:Array = [];

        private var sqlConnection:SQLConnection;

        protected var deferred:Deferred;

        protected var log:ILogger;

        public function TransactionOperation()
        {
            this.log = _log;
        }

        public function setConnection(sqlConnection:SQLConnection):void
        {
            this.sqlConnection = sqlConnection;
        }

        public function addOperation(operation:ISQLOperation):void
        {
            operations.push(operation);
        }

        public override function execute():Promise
        {
            deferred = new Deferred();

            if (operations.length == 0)
            {
                var dummyOperation:DummyOperation = new DummyOperation();
                dummyOperation.setConnection(sqlConnection);
                operations.push(dummyOperation);
            }

            begin();
            return deferred.promise;
        }

        //begin transaction

        private function begin():void
        {
            log.info("transaction begin");

            sqlConnection.addEventListener(SQLEvent.BEGIN, onTransactionBeginResult);
            sqlConnection.addEventListener(SQLErrorEvent.ERROR, onTransactionBeginResult);
            sqlConnection.begin(SQLTransactionLockType.DEFERRED);
        }

        private function onTransactionBeginResult(event:Event):void
        {
            if (event.type == SQLEvent.BEGIN)
            {
                log.info("on transaction begin");
                next();
            }
            else
            {
                log.error("on transaction begin error: {0}", SQLErrorEvent(event).error.getStackTrace());
                _error = SQLErrorEvent(event).error;
                deferred.reject(_error);
            }

            sqlConnection.removeEventListener(SQLEvent.BEGIN, onTransactionBeginResult);
            sqlConnection.removeEventListener(SQLErrorEvent.ERROR, onTransactionBeginResult);
        }

        //commit transaction

        private function commit():void
        {
            log.info("transaction commit");

            sqlConnection.addEventListener(SQLEvent.COMMIT, onTransactionCommitResult);
            sqlConnection.addEventListener(SQLErrorEvent.ERROR, onTransactionCommitResult);
            sqlConnection.commit();
        }

        private function onTransactionCommitResult(event:Event):void
        {
            sqlConnection.removeEventListener(SQLEvent.COMMIT, onTransactionCommitResult);
            sqlConnection.removeEventListener(SQLErrorEvent.ERROR, onTransactionCommitResult);

            if (event.type == SQLEvent.COMMIT)
            {
                log.info("on transaction commit");
                deferred.resolve(this);
            }
            else
            {
                log.error("on transaction commit error: {0}", SQLErrorEvent(event).error.getStackTrace());
                _error = SQLErrorEvent(event).error;
                deferred.reject(_error);
            }
        }

        //rollback transaction

        private function rollback():void
        {
            log.info("transaction rollback");

            sqlConnection.addEventListener(SQLEvent.ROLLBACK, onTransactionRollbackResult);
            sqlConnection.addEventListener(SQLErrorEvent.ERROR, onTransactionRollbackResult);
            sqlConnection.rollback();
        }

        private function onTransactionRollbackResult(event:Event):void
        {
            sqlConnection.removeEventListener(SQLEvent.ROLLBACK, onTransactionRollbackResult);
            sqlConnection.removeEventListener(SQLErrorEvent.ERROR, onTransactionRollbackResult);

            if (event.type == SQLEvent.ROLLBACK)
            {
                log.info("on transaction rollback");
                deferred.reject(_error);
            }
            else
            {
                log.error("on transaction rollback error: {0}", SQLErrorEvent(event).error.getStackTrace());
                deferred.reject(_error);
            }
        }

        private function next():void
        {
            if (operations.length > 0)
            {
                var operation:SQLOperation = SQLOperation(operations.splice(0, 1)[0]);

                log.info("execute operation {0}: {1}", operations.length + 1, Types.getQualifiedClassName(operation));
                operation.execute().then(function (operation:SQLOperation):void
                {
                    log.info("on operation execute");
                    operation.dispose();
                    next();
                }, function (e:Error):void
                {
                    log.info("on operation execute error");
                    _error = e;
                    operation.dispose();
                    rollback();
                });
            }
            else
            {
                commit();
            }
        }

        public function toString():String
        {
            return "TransactionOperation{operations=" + String(operations) + "}";
        }

        public override function dispose():void
        {
            super.dispose();
            sqlConnection = null;
        }
    }
}
