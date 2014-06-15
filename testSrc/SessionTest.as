package {
    import com.codecatalyst.promise.Promise;

    import flash.data.SQLConnection;
    import flash.data.SQLMode;
    import flash.data.SQLResult;
    import flash.data.SQLTableSchema;
    import flash.filesystem.File;

    import kemsky.CreateTables;

    import kemsky.Session;

    import kemsky.sql.EntityMapper;
    import kemsky.sql.Order;
    import kemsky.sql.Restrictions;
    import kemsky.sql.async.IQuery;
    import kemsky.sql.async.ISQLOperation;
    import kemsky.sql.async.ITransaction;

    import mx.logging.ILogger;
    import mx.logging.Log;

    import org.flexunit.asserts.assertEquals;
    import org.flexunit.asserts.assertNotNull;
    import org.flexunit.asserts.assertNull;

    public class SessionTest extends AsyncTest
    {
        private static const log:ILogger = Log.getLogger("SessionTest");

        private var file:File;
        private var mapper:EntityMapper;
        private var session:Session;

        [Before]
        public function setup():void
        {
            file = new File(File.applicationDirectory.nativePath + File.separator + "database.sqlite");
            if(file.exists)
            {
                file.deleteFile();
            }
            log.info("db path: {0}", file.nativePath);

            mapper = new EntityMapper();

            var connection:SQLConnection = new SQLConnection();
            try
            {
                connection.open(file, SQLMode.CREATE);
                mapper.registerEntity(TestCriteriaEntity);

                new CreateTables(connection, [TestCriteriaEntity], mapper).call();

                connection.loadSchema(SQLTableSchema, "test");
            }
            finally
            {
                if(connection.connected)
                {
                    connection.close();
                }
            }

            session = new Session(mapper);
        }

        [Test(async)]
        public function testTransaction():void
        {
            wait("success");

            session.open(file.nativePath, SQLMode.UPDATE).then(function ():Promise
                    {
                        var testCriteriaEntity1:TestCriteriaEntity = new TestCriteriaEntity();
                        testCriteriaEntity1.str = "inserted1";
                        var testCriteriaEntity2:TestCriteriaEntity = new TestCriteriaEntity();
                        testCriteriaEntity2.str = "inserted2";

                        var transaction:ITransaction = session.transaction;

                        transaction.insert(testCriteriaEntity1);
                        transaction.insert(testCriteriaEntity2);
                        transaction.remove(TestCriteriaEntity);
                        transaction.insert(testCriteriaEntity1);
                        transaction.insert(testCriteriaEntity2);

                        var query:IQuery = transaction.query;
                        query.text = "update test set str=:str where str=:id";
                        query.parameters[":id"] = "inserted2";
                        query.parameters[":str"] = "inserted3";


                        return transaction.run.then(function (operation:ISQLOperation):Promise
                        {
                            var result:* = operation.result;
                            log.info("result: {0}", result);
                            return session.criteria(TestCriteriaEntity).by(Order.asc(TestCriteriaEntity.ATTR_ID)).list;
                        }).then(function (operation:ISQLOperation):void
                                {
                                    var result:Array = operation.result;
                                    assertEquals(2, result.length);
                                    assertEquals("inserted1", TestCriteriaEntity(result[0]).str);
                                    assertEquals(1, TestCriteriaEntity(result[0]).id);
                                    assertEquals("inserted3", TestCriteriaEntity(result[1]).str);
                                    assertEquals(2, TestCriteriaEntity(result[1]).id);
                                    send("success");
                                }, fault);
                    }
            );
        }

        [Test(async)]
        public function testQuery():void
        {
            wait("success");

            session.open(file.nativePath, SQLMode.UPDATE).then(function ():Promise
            {
                var query:IQuery = session.query;
                query.text = "select count(*) from test where id=:id";
                query.parameters[":id"] = 0;
                query.transform = function (result:SQLResult):int
                {
                    assertNotNull(result);
                    assertEquals(1, result.data.length);
                    return result.data[0]["count(*)"];
                };

                return query.run;
            }).then(function (operation:ISQLOperation):void
                    {
                        var count:int = operation.result;
                        log.info("result: {0}", count);
                        assertEquals(0, count);
                        send("success");
                    },
                    fault);
        }

        [Test(async)]
        public function testCRUDArrays():void
        {
            wait("success");

            session.open(file.nativePath, SQLMode.UPDATE).then(function ():Promise
                    {
                        var testCriteriaEntity1:TestCriteriaEntity = new TestCriteriaEntity();
                        testCriteriaEntity1.str = "insert";
                        var testCriteriaEntity2:TestCriteriaEntity = new TestCriteriaEntity();
                        testCriteriaEntity2.str = "insert";
                        return session.save([testCriteriaEntity1, testCriteriaEntity2]);
                    }
            ).then(function (operation:ISQLOperation):Promise
                    {
                        return session.criteria(TestCriteriaEntity).by(Order.desc(TestCriteriaEntity.ATTR_ID)).list;
                    }).then(function (operation:ISQLOperation):Promise
                    {
                        assertEquals(2, operation.result.length);
                        var entity:TestCriteriaEntity = operation.result[0];
                        assertEquals(2, entity.id);
                        return session.criteria(TestCriteriaEntity).by(Order.asc(TestCriteriaEntity.ATTR_ID)).list;
                    }).then(function (operation:ISQLOperation):Promise
                    {
                        assertEquals(2, operation.result.length);
                        var entity:TestCriteriaEntity = operation.result[0];
                        assertEquals(1, entity.id);
                        assertEquals("insert", entity.str);
                        entity.str = "update";
                        return session.save([entity]);
                    }).then(function (operation:ISQLOperation):Promise
                    {
                        return session.criteria(TestCriteriaEntity).when(Restrictions.Eq(TestCriteriaEntity.ATTR_ID, 1)).list;
                    }).then(function (operation:ISQLOperation):Promise
                    {
                        assertEquals(1, operation.result.length);
                        var entity:TestCriteriaEntity = operation.result[0];
                        assertNotNull(entity);
                        assertEquals(1, entity.id);
                        assertEquals("update", entity.str);
                        return session.remove([entity]);
                    }).then(function (operation:ISQLOperation):Promise
                    {
                        return session.criteria(TestCriteriaEntity).unique;
                    }).then(function (operation:ISQLOperation):void
                    {
                        var entity:TestCriteriaEntity = operation.result;
                        assertNotNull(entity);
                        assertEquals(2, entity.id);
                        assertEquals("insert", entity.str);
                        send("success");
                    }, fault);
        }

        [Test(async)]
        public function testCRUD():void
        {
            wait("success");
            session.open(file.nativePath, SQLMode.UPDATE).then(function ():Promise
                    {
                        var testCriteriaEntity:TestCriteriaEntity = new TestCriteriaEntity();
                        testCriteriaEntity.str = "insert";
                        return session.save(testCriteriaEntity)
                    }
            ).then(function (operation:ISQLOperation):Promise
                    {
                        var entity:TestCriteriaEntity = operation.result;
                        assertNotNull(entity);
                        assertEquals(1, entity.id);
                        return session.criteria(TestCriteriaEntity).unique;
                    }).then(function (operation:ISQLOperation):Promise
                    {
                        var entity:TestCriteriaEntity = operation.result;
                        assertNotNull(entity);
                        assertEquals(1, entity.id);
                        assertEquals("insert", entity.str);
                        entity.str = "update";
                        return session.save(entity);
                    }).then(function (operation:ISQLOperation):Promise
                    {
                        return session.criteria(TestCriteriaEntity).unique;
                    }).then(function (operation:ISQLOperation):Promise
                    {
                        var entity:TestCriteriaEntity = operation.result;
                        assertNotNull(entity);
                        assertEquals(1, entity.id);
                        assertEquals("update", entity.str);
                        return session.remove(entity);
                    }).then(function (operation:ISQLOperation):Promise
                    {
                        return session.criteria(TestCriteriaEntity).unique;
                    }).then(function (operation:ISQLOperation):void
                    {
                        assertNull(operation.result);
                        send("success");
                    }, fault);
        }

        [After]
        public function cleanup():void
        {
            session.close();

            if(file && file.exists)
            {
                try
                {
                    file.deleteFile();
                    log.info("deleted db: {0}", file.nativePath);
                }
                catch(e:Error)
                {
                    log.warn("failed to delete db: {0}", file.nativePath);
                }
            }
        }
    }
}
