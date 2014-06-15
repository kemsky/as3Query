package kemsky.sql.async
{
    import mx.logging.ILogger;
    import mx.logging.Log;

    /**
     * @see http://www.sqlite.org/vdbe.html
     */
    public class PrintExplainPlan
    {
        private static const log:ILogger = Log.getLogger("kemsky.sql.async.PrintExplainPlan");

        [ArrayElementType("kemsky.sql.async.ExplainPlanRow")]
        private var rows:Array;

        public function PrintExplainPlan(rows:Array)
        {
            this.rows = rows;
        }

        public function call():void
        {
            log.info("SQL EXECUTION PLAN:");


            var maxSize:Number = 4;
            for each (var p:ExplainPlanRow in rows)
            {
                maxSize = Math.max(maxSize, p.p4.length);
            }

            log.info("╔════════╦═════════════════╦══════╦══════╦══════╦" + format("", maxSize, "═") + "═╦══════╗");
            log.info("║addr    ║ opcode          ║ p1   ║ p2   ║ p3   ║ " + format("p4", maxSize, " ") + "║ p5   ║");
            log.info("╠════════╬═════════════════╬══════╬══════╬══════╬" + format("", maxSize, "═") + "═╬══════╣");

            for each (var record:ExplainPlanRow in rows)
            {
                log.info("║{0}    ║ {1}║ {2} ║ {3} ║ {4} ║ {5}║ {6} ║", format(record.addr.toString()), format(record.opcode, 16), format(record.p1.toString()), format(record.p2.toString()), format(record.p3.toString()), format(record.p4, maxSize), format(record.p5.toString()));
            }
            log.info("╚════════╩═════════════════╩══════╩══════╩══════╩" + format("", maxSize, "═") + "═╩══════╝");

        }

        private function format(value:String, size:Number = 4, char:String = " "):String
        {
            var result:String = "";
            if(value != null)
            {
                result = value + space(size - value.length, char);
            }
            else
            {
                result = space(size);
            }
            return result;
        }

        private function space(count:Number, char:String = " "):String
        {
            var result:String = "";
            for(var i:int = 0; i < count; i++)
            {
                result = result + char;
            }
            return result;
        }
    }
}
