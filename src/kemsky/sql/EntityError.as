package kemsky.sql
{
    public class EntityError extends Error
    {
        public function EntityError(message:String = "",id:Number = 0)
        {
            super(message, id);
        }
    }
}
