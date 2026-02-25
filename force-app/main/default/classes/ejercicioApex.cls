public class ejercicioApex {
    //0 1 1 2 3 5 8 13 21 34 55 89
    public static integer fibonacci(Integer n){
        //devolver el numero en la posicion N
       integer a = 0;
       integer b = 1; 
       integer c = 0;
       	if(n > 1){
           for(Integer i = 1; i < n ; i++){                 
            	 c = a + b;
               	 a = b ;
               	 b = c;
        	}     
        }else if(n == 0){
            return 0;
        }else if(n == 1){
            return 1;
        }
        System.debug(b);

       	return b;
    }

}