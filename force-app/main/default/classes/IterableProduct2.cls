public class IterableProduct2 implements Iterable<Product2> {
    private List<Product2> products;
    public IterableProduct2(List<Product2> products)
    {
        this.products = products;
    }
    public Iterator<Product2> iterator(){
       return new IteratorProduct2(products);
    }
 }