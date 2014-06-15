package
{
    import flash.events.Event;
    import flash.events.IEventDispatcher;

    import mx.core.FlexGlobals;
    import mx.logging.ILogger;
    import mx.logging.Log;

    import org.flexunit.async.Async;

    public class AsyncTest
    {
        private static const log:ILogger = Log.getLogger("AsyncTest");

        protected function wait(name:String, timeout:int = 4000):void
        {
            var dispatcher:IEventDispatcher = FlexGlobals.topLevelApplication as IEventDispatcher;
            Async.proceedOnEvent(this, dispatcher, name, timeout);
        }

        protected function send(name:String):void
        {
            var dispatcher:IEventDispatcher = FlexGlobals.topLevelApplication as IEventDispatcher;
            var event:Event = new Event(name);
            log.info("response: " + event.toString());
            dispatcher.dispatchEvent(event);
        }

        protected function fault(e:Error):void
        {
            log.error("error: {0}", e.toString());
            send("error");
        }
    }
}
