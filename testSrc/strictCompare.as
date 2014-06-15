package {
    import mx.utils.ObjectUtil;

    /**
     *  Compares the Objects and returns an integer value
     *  indicating if the first item is less than greater than or equal to
     *  the second item.
     *  This method will recursively compare properties on nested objects and
     *  will return as soon as a non-zero result is found.
     *  By default this method will recurse to the deepest level of any property.
     *  To change the depth for comparison specify a non-negative value for
     *  the <code>depth</code> parameter.
     *
     *  @param a Object.
     *
     *  @param b Object.
     *
     *  @param depth Indicates how many levels should be
     *  recursed when performing the comparison.
     *  Set this value to 0 for a shallow comparison of only the primitive
     *  representation of each property.
     *  For example:<pre>
     *  var a:Object = {name:"Bob", info:[1,2,3]};
     *  var b:Object = {name:"Alice", info:[5,6,7]};
     *  var c:int = ObjectUtil.compare(a, b, 0);</pre>
     *
     *  <p>In the above example the complex properties of <code>a</code> and
     *  <code>b</code> will be flattened by a call to <code>toString()</code>
     *  when doing the comparison.
     *  In this case the <code>info</code> property will be turned into a string
     *  when performing the comparison.</p>
     *
     *  @return Return 0 if a and b are null, NaN, or equal.
     *  Return 1 if a is null or greater than b.
     *  Return -1 if b is null or greater than a.
     *
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function strictCompare(a:Object, b:Object, depth:int = -1):int
    {
       return ObjectUtil.compare(a, b, depth);
    }
}