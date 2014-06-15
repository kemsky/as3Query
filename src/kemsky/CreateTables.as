package kemsky
{
    import flash.data.SQLConnection;
    import flash.data.SQLStatement;
    import flash.utils.getTimer;

    import kemsky.sql.EntityDescriptor;

    import kemsky.sql.EntityMapper;

    import mx.logging.ILogger;
    import mx.logging.Log;

    public class CreateTables
    {
        private static const log:ILogger = Log.getLogger("kemsky.CreateTables");

        private var entities:Array;
        private var connection:SQLConnection;
        private var entityManager:EntityMapper;

        public function CreateTables(connection:SQLConnection, entities:Array, entityManager:EntityMapper)
        {
            this.connection = connection;
            this.entities = entities;
            this.entityManager = entityManager;
        }

        public function call():void
        {
            var start:Number = getTimer();

            try
            {
                var st:SQLStatement = new SQLStatement();
                st.sqlConnection = connection;

                for each (var entity:Class in entities)
                {
                    var table:EntityDescriptor = entityManager.getDescriptor(entity);

                    st.text = table.getTableScript();
                    log.info("DDL:\n{0}", st.text);
                    st.execute();
                    log.info("DDL: success");

                    var indexScripts:Array = table.getIndexScripts();
                    for each (var indexDDL:String in  indexScripts)
                    {
                        st.text = indexDDL;
                        log.info("INDEX DDL:\n{0}", indexDDL);
                        st.execute();
                        log.info("INDEX DDL: success");
                    }
                }

                log.info("creation time: {0} ms", getTimer() - start);
            }
            finally
            {
                connection = null;
            }
        }
    }
}