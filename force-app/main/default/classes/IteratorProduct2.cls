public class IteratorProduct2 implements Iterator<Product2>{ 
 
    private List<Product2> products;
    private Integer currentIndex;
  
    public IteratorProduct2(List<Product2> products){
        this.products = products;
        this.currentIndex = 0;
    }
  
    public boolean hasNext(){ 
        return currentIndex < products.size() - 1;
    }    
  
    public Product2 next(){
        if(hasNext()) {
            currentIndex++;
            return products[currentIndex];
        } else {
            throw new NoSuchElementException();
        }
    } 
}