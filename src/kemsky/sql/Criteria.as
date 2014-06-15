package kemsky.sql
{
    import com.codecatalyst.promise.Promise;

    import flash.data.SQLConnection;

    import kemsky.sql.async.SelectOperation;

    public class Criteria
    {
        private var _clazz:Class;

        [ArrayElementType("kemsky.sql.IRestriction")]
        private var _restrictions:Array = [];

        [ArrayElementType("String")]
        private var _fields:Array;
        private var _order:IOrder;
        private var _sqlConnection:SQLConnection;
        private var _distinct:Boolean;
        private var _manager:EntityMapper;

        public function Criteria(clazz:Class, manager:EntityMapper, sqlConnection:SQLConnection)
        {
            _clazz = clazz;
            _manager = manager;
            _sqlConnection = sqlConnection;
            _fields = _manager.getDescriptor(clazz).columns;
        }

        public function columns(columns:Array):Criteria
        {
            _fields = columns;
            return this;
        }

        public function get distinct():Criteria
        {
            _distinct = true;
            return this;
        }

        public function when(restriction:IRestriction):Criteria
        {
            _restrictions.push(restriction);
            return this;
        }

        public function by(order:IOrder):Criteria
        {
            _order = order;
            return this;
        }

        public function get list():Promise
        {
            var selectOperation:SelectOperation = new SelectOperation(_manager, _clazz, _fields, _restrictions, _order, false, _distinct);
            selectOperation.setConnection(_sqlConnection);
            clean();
            return selectOperation.execute();
        }

        public function get unique():Promise
        {
            var selectOperation:SelectOperation = new SelectOperation(_manager, _clazz, _fields, _restrictions, _order, true, _distinct);
            selectOperation.setConnection(_sqlConnection);
            clean();
            return selectOperation.execute();
        }

        public function get count():Promise
        {
            var selectOperation:SelectOperation = new SelectOperation(_manager, _clazz, _fields, _restrictions, _order, true, _distinct, true);
            selectOperation.setConnection(_sqlConnection);
            clean();
            return selectOperation.execute();
        }

        private function clean():void
        {
            _clazz = null;
            _restrictions = null;
            _fields = null;
            _order = null;
            _sqlConnection = null;
        }
    }
}
