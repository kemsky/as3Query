package sql
{
    import kemsky.sql.Column;
    import kemsky.sql.EntityDescriptor;
    import kemsky.sql.EntityMapper;
    import kemsky.sql.Index;

    import mx.logging.ILogger;
    import mx.logging.Log;

    import org.flexunit.asserts.assertEquals;
    import org.flexunit.asserts.assertFalse;
    import org.flexunit.asserts.assertNull;
    import org.flexunit.asserts.assertTrue;

    public class EntityMapperTest
    {
        private static const log:ILogger = Log.getLogger("com.cost.guide.services.sql.EntityMapperTest");

        [Test]
        public function testMapping():void
        {
            var entityManager:EntityMapper = new EntityMapper();
            entityManager.registerEntity(TestEntity);

            //test descriptor
            var descriptor:EntityDescriptor = entityManager.getDescriptor(TestEntity);

            assertEquals(10, descriptor.columns.length);
            assertEquals(1, descriptor.foreignKeys.length);

            assertEquals(2, descriptor.indices.length);

            for each (var index:Index in descriptor.indices)
            {
                switch (index.name)
                {
                    case "test_index_1":
                        assertEquals(2, index.columns.length);
                        assertEquals(0, strictCompare(["unsigned", "bool"], index.columns));
                        break;
                    case "test_index_2":
                        assertEquals(1, index.columns.length);
                        assertEquals(0, strictCompare(["str"], index.columns));
                        assertEquals(true, index.unique);
                        break;
                    default:
                        assertFalse(true);
                }
            }

            for each (var column:Column in descriptor.columnDescriptors)
            {
                switch (column.name)
                {
                    case "id":
                        assertEquals(true, column.primaryKey);
                        assertEquals(false, column.nullable);
                        assertEquals("INTEGER", column.type);
                        assertNull(column.defValue);
                        assertNull(column.foreignKey);
                        assertNull(column.options);
                        assertFalse(column.unique);
                        break;
                    case "unsigned":
                        assertEquals(false, column.primaryKey);
                        assertEquals(true, column.nullable);
                        assertEquals("INTEGER", column.type);
                        assertEquals("1", column.defValue);
                        assertNull(column.foreignKey);
                        assertNull(column.options);
                        assertFalse(column.unique);
                        break;
                    case "date":
                        assertEquals(false, column.primaryKey);
                        assertEquals(true, column.nullable);
                        assertEquals("DATE", column.type);
                        assertNull(column.defValue);
                        assertNull(column.foreignKey);
                        assertNull(column.options);
                        assertTrue(column.unique);
                        break;
                    case "xml":
                        assertEquals(false, column.primaryKey);
                        assertEquals(true, column.nullable);
                        assertEquals("XML", column.type);
                        assertNull(column.defValue);
                        assertNull(column.foreignKey);
                        assertNull(column.options);
                        assertFalse(column.unique);
                        break;
                    case "xmlList":
                        assertEquals(false, column.primaryKey);
                        assertEquals(true, column.nullable);
                        assertEquals("XMLList", column.type);
                        assertNull(column.defValue);
                        assertNull(column.foreignKey);
                        assertNull(column.options);
                        assertFalse(column.unique);
                        break;
                    case "object":
                        assertEquals(false, column.primaryKey);
                        assertEquals(true, column.nullable);
                        assertEquals("Object", column.type);
                        assertNull(column.defValue);
                        assertNull(column.foreignKey);
                        assertNull(column.options);
                        assertFalse(column.unique);
                        break;
                    case "bool":
                        assertEquals(false, column.primaryKey);
                        assertEquals(true, column.nullable);
                        assertEquals("BOOLEAN", column.type);
                        assertNull(column.defValue);
                        assertNull(column.foreignKey);
                        assertNull(column.options);
                        assertFalse(column.unique);
                        break;
                    case "num":
                        assertEquals(false, column.primaryKey);
                        assertEquals(true, column.nullable);
                        assertEquals("REAL", column.type);
                        assertNull(column.defValue);
                        assertNull(column.foreignKey);
                        assertNull(column.options);
                        assertFalse(column.unique);
                        break;
                    case "str":
                        assertEquals(false, column.primaryKey);
                        assertEquals(true, column.nullable);
                        assertEquals("TEXT", column.type);
                        assertNull(column.defValue);
                        assertNull(column.foreignKey);
                        assertNull(column.options);
                        assertFalse(column.unique);
                        break;
                    case "fk_table":
                        assertEquals(false, column.primaryKey);
                        assertEquals(true, column.nullable);
                        assertEquals("TEXT", column.type);
                        assertNull(column.defValue);
                        assertEquals("table(id)", column.foreignKey);
                        assertEquals("deferred", column.options);
                        assertFalse(column.unique);
                        break;
                    default:
                        assertFalse(true);
                }
            }
        }
    }
}
