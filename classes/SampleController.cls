public class SampleController 
{
    public String getMyStringMethod()
    {
        System.debug('getMyStringMethod()...');
        if(myString == null)
        {
            myString = 'b';
        }
        System.debug('Lets see...s');
        return myString;
    }
    
    public String myString
    {
        get
        {
            System.debug('myString get...');
            if(myString == null)
            {
                return 'a';
            }
            return myString;
        }
        private set;
    }
    
    public String getmyString()
    {

        System.debug('getmyString()...');
        return 'getmyString';
    }
}