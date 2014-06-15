package kemsky
{
    import com.codecatalyst.promise.Deferred;
    import com.codecatalyst.promise.Promise;

    import flash.data.SQLConnection;
    import flash.errors.SQLError;
    import flash.events.SQLEvent;
    import flash.filesystem.File;
    import flash.net.Responder;
    import flash.utils.ByteArray;

    import kemsky.sql.Criteria;
    import kemsky.sql.EntityDescriptor;

    import kemsky.sql.EntityMapper;
    import kemsky.sql.async.DeleteOperation;
    import kemsky.sql.async.IQuery;
    import kemsky.sql.async.ISQLOperation;
    import kemsky.sql.async.ITransaction;
    import kemsky.sql.async.InsertOperation;
    import kemsky.sql.async.Query;
    import kemsky.sql.async.Transaction;
    import kemsky.sql.async.TransactionOperation;
    import kemsky.sql.async.UpdateOperation;

    import mx.logging.ILogger;
    import mx.logging.Log;

    /**
     * @see http://help.adobe.com/en_US/as3/dev/WSd47bd22bdd97276f1365b8c112629d7c47c-8000.html
     */
    public class Session
    {
        private static const log:ILogger = Log.getLogger("kemsky.Session");

        private var connection:SQLConnection;
        private var file:File;

        [Inject]
        public var mapper:EntityMapper;

        public function Session(mapper:EntityMapper = null)
        {
            this.mapper = mapper;
        }

        public function open(dbFilename:String, openMode:String = "create", autoCompact:Boolean = false, pageSize:int = 1024, encryptionKey:ByteArray = null):Promise
        {
            file = new File(dbFilename);
            connection = new SQLConnection();

            var deferred:Deferred = new Deferred();
            connection.openAsync(file, openMode, new Responder(
                    function (event:SQLEvent):void
                    {
                        connection.cacheSize = 8192;

                        log.info("sql connection opened '{0}'", file.nativePath);
                        log.info("  > sqlite page size {0}", pageSize);
                        log.info("  > sqlite auto compact {0}", autoCompact);
                        deferred.resolve(null);
                    },
                    function (error:SQLError):void
                    {
                        log.error("failed to open database [{0}]: {1}", file.nativePath, error);
                        deferred.reject(error);
                    }), autoCompact, pageSize, encryptionKey);

            return deferred.promise;
        }

        public function close():void
        {
            if(connection && connection.connected)
            {
                connection.close();
                log.info("sql connection closed '{0}'", file.nativePath);
            }
        }

        public function criteria(clazz:Class):Criteria
        {
            return new Criteria(clazz, mapper, connection);
        }

        public function get query():IQuery
        {
            return createQuery();
        }

        public function get transaction():ITransaction
        {
            var transaction:Transaction = new Transaction();
            transaction.setConnection(connection);
            transaction.setSession(this);
            return transaction;
        }

        public function save(entities:*):Promise
        {
            var result:Promise;

            if(entities is Array)
            {
                var transactionOperation:TransactionOperation = new TransactionOperation();
                transactionOperation.setConnection(connection);

                for each (var entity:* in entities)
                {
                    transactionOperation.addOperation(createSave(entity));
                }

                result = transactionOperation.execute();
            }
            else
            {
                result = createSave(entities).execute();
            }

            return result;
        }

        public function remove(entities:*):Promise
        {
            var result:Promise;

            if(entities is Array)
            {
                var transactionOperation:TransactionOperation = new TransactionOperation();
                transactionOperation.setConnection(connection);

                for each (var entity:* in entities)
                {
                    transactionOperation.addOperation(createRemove(entity));
                }
                result = transactionOperation.execute();
            }
            else
            {
                result = createRemove(entities).execute();
            }
            return  result;
        }

        public function createInsert(entity:Object):ISQLOperation
        {
            var insertOperation:InsertOperation = new InsertOperation(entity, mapper);
            insertOperation.setConnection(connection);
            return  insertOperation;
        }

        public function createUpdate(entity:*, columns:Array = null, values:Array = null, conditions:Array = null):ISQLOperation
        {
            var updateOperation:UpdateOperation = new UpdateOperation(entity, mapper, columns, values, conditions);
            updateOperation.setConnection(connection);
            return  updateOperation;
        }

        public function createRemove(entity:*, conditions:Array = null):ISQLOperation
        {
            var deleteOperation:DeleteOperation = new DeleteOperation(entity, mapper, conditions);
            deleteOperation.setConnection(connection);
            return deleteOperation;
        }

        public function createSave(entity:Object):ISQLOperation
        {
            var result:ISQLOperation;
            var descriptor:EntityDescriptor = mapper.getDescriptor(entity.constructor);
            if(entity[descriptor.primaryKey] == 0 || isNaN(entity[descriptor.primaryKey]))
            {
                result = createInsert(entity);
            }
            else
            {
                result = createUpdate(entity);
            }
            return result;
        }

        public function createQuery():Query
        {
            var query:Query = new Query();
            query.setConnection(connection);
            return query;
        }
    }
}
