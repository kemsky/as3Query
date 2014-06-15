package kemsky.sql
{
    import avmplus.R;

    import flash.utils.Dictionary;
    import flash.utils.getTimer;

    import mx.logging.ILogger;
    import mx.logging.Log;

    /**
     * Required static properties for entities
     */
    public class EntityMapper
    {
        private static const log:ILogger = Log.getLogger("kemsky.sql.EntityMapper");

        private static const types:Dictionary = new Dictionary();
        {
            types["int"] = "INTEGER";
            types["uint"] = "INTEGER";
            types["Number"] = "REAL";
            types["XML"] = "XML";
            types["XMLList"] = "XMLList";
            types["String"] = "TEXT";
            types["Date"] = "DATE";
            types["Boolean"] = "BOOLEAN";
        }

        private const registry:Dictionary = new Dictionary();

        public function registerEntity(entity:Class):void
        {
            var start:Number = getTimer();

            if(registry[entity] != null)
            {
                return;
            }


            var json:Object = R.describe(entity,  R.ACCESSORS | R.VARIABLES | R.METADATA | R.TRAITS);

            var classMetadata:Object = getMetadata("Table", json.traits.metadata);

            if(classMetadata == null)
            {
                throw new EntityError("Entity class must have exactly one 'Table' metadata" + json.name);
            }

            var tableName:String = getMetadata("name", classMetadata.value) as String;


            var indices:Array = [];

            var indexMetadata:Array = getMetadataList("Index", json.traits.metadata);

            if(indexMetadata.length > 0)
            {
                for each (var index:Object in indexMetadata)
                {
                    var indexName:String = getMetadata("name", index.value) as String;
                    var indexColumns:String = getMetadata("columns", index.value) as String;
                    var unique:String = getMetadata("unique", index.value) as String;
                    indices.push(new Index(indexName, indexColumns.split(","), unique == "true"));
                }
            }

            if(tableName == null)
            {
                throw new EntityError("'Table' metadata must have 'name' argument: " + json.name);
            }

            [ArrayElementType("kemsky.sql.Column")] var columns:Array = [];

            [ArrayElementType("kemsky.sql.Column")] var foreignKeys:Array = [];

            parse(json.traits.variables, columns, foreignKeys, tableName);
            parse(json.traits.accessors, columns, foreignKeys, tableName);

            this.registry[entity] = new EntityDescriptor(entity, tableName, columns, foreignKeys, indices);

            log.info("registered {0}, {1} ms", json.name, getTimer() - start);
        }

        private function parse(properties:Array, columns:Array, foreignKeys:Array, tableName:String):void
        {
            var nullable:String;
            var defValue:String;
            var pKey:String;
            var fKey:String;
            var type:String;
            var options:String;
            var unique:String;

            var column:Column;

            for each (var property:Object in properties)
            {
                var propertyColumn:Object = getMetadata("Column", property.metadata);

                if(propertyColumn)
                {
                    nullable = getMetadata("nullable", propertyColumn.value) as String;
                    unique = getMetadata("unique", propertyColumn.value) as String;
                    defValue = getMetadata("default", propertyColumn.value) as String;
                    pKey = getMetadata("primaryKey", propertyColumn.value) as String;
                    fKey = getMetadata("foreignKey", propertyColumn.value) as String;
                    options = getMetadata("options", propertyColumn.value) as String;

                    //Object => AMF3 serialization
                    type = types[property.type] != null ? types[property.type] : "Object";

                    column = new Column(property.name, type, pKey != null, (nullable == null || nullable == "true") && (pKey == null), defValue, fKey, options, unique == "true");

                    if(fKey != null && fKey.length > 0)
                    {
                        foreignKeys.push(column);
                    }
                    columns.push(column);
                }
            }
        }

        public function getDescriptor(entity:Class):EntityDescriptor
        {
            var descriptor:EntityDescriptor = registry[entity];

            if(descriptor == null)
            {
                throw new EntityError("Entity was not registered: " + descriptor);
            }

            return  descriptor;
        }

        private function getMetadata(name:String, property:Array):Object
        {
            for each (var metadata:Object in property)
            {
                if(metadata.name == name)
                {
                    return metadata;
                }
                else if(metadata.key == name)
                {
                    return metadata.value;
                }
                else if(metadata.key == "" && metadata.value == name)
                {
                    return metadata.value;
                }
            }
            return null;
        }

        private function getMetadataList(name:String, property:Array):Array
        {
            var result:Array = [];
            for each (var metadata:Object in property)
            {
                if(metadata.name == name)
                {
                    result.push(metadata);
                }
            }
            return result;
        }
    }
}
