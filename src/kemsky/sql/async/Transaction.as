package kemsky.sql.async
{
    import com.codecatalyst.promise.Promise;

    import kemsky.Session;

    import mx.logging.ILogger;
    import mx.logging.Log;

    public class Transaction extends TransactionOperation implements ITransaction
    {
        private static const _log:ILogger = Log.getLogger("kemsky.sql.async.Transaction");

        private var session:Session;

        public function Transaction()
        {
            this.log = _log;
        }

        public function insert(entity:*):void
        {
            addOperation(session.createInsert(entity));
        }

        public function update(entity:*, columns:Array = null, values:Array = null, conditions:Array = null):void
        {
            addOperation(session.createUpdate(entity, columns, values, conditions));
        }

        public function remove(entity:*, conditions:Array = null):void
        {
            addOperation(session.createRemove(entity, conditions));
        }

        public function save(entity:*):void
        {
            addOperation(session.createSave(entity));
        }

        public function get query():IQuery
        {
            var query:Query = session.createQuery();
            addOperation(query);
            return query;
        }

        public function get run():Promise
        {
            return this.execute();
        }

        public function setSession(session:Session):void
        {
            this.session = session;
        }

        override public function dispose():void
        {
            super.dispose();
            this.session = null;
        }
    }
}
