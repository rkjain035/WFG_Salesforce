public class PairNumbers {
	
    Integer x, y;
    
    public PairNumbers()
    {
        
    }
    
    public PairNumbers(integer x, integer y)
    {
        this.x = x;
        this.y = y;
    }
    
    public boolean equals(Object obj)
    {
        System.debug('Does it execute...');
        if(obj instanceOf PairNumbers)
        {
            PairNumbers p = (PairNumbers)obj;
            return ( (this.x == x) && (this.y == y) );
        }
        return false;
    }
    
    public Integer hashCode()
    {
        return (31*x) ^ 10;
    }
}