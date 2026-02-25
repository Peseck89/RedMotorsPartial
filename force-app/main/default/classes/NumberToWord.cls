public with sharing class NumberToWord {  
    static String[] to_19 = new string[]{ 'cero', 'uno',  'dos', 'tres', 'cuatro',  'cinco',  'seis',  
    'siete', 'ocho', 'nueve', 'diez',  'once', 'doce', 'trece',  
    'catorce', 'quince', 'dieciséis', 'diecisiete', 'dieciocho', 'diecinueve' };  
  static String[] tens = new string[]{ 'veinte', 'treinta', 'cuarenta', 'ciencuenta', 'sesenta', 'setenta', 'ochenta', 'noventa'};  
static String[] denom = new string[]{ '',  
    'mil',   'millón',     'billón',    'trillón',    'quatrillón',  
   'quintillón', 'seistillón',   'septillón',  'octillón',   'nontillón',  
    'deicillón',  'undecillón',   'duodecillón', 'tridecillón',  'quatrodecillón',  
    'sixtidecillón', 'septidecillón', 'octodecillón', 'novedecillón', 'vigecidecillón' };  
  // convert a value < 100 to English.    
 public static String convert_nn(integer val) {  
     if(val <0){
         val = val*-1;
     }
    if (val < 20)  
      return to_19[val];  
    if(val == 100)  
        return 'Cien';  
    for (integer v = 0; v < tens.size(); v++) {  
      String dcap = tens[v];  
      integer dval = 20 + 10 * v;  
      if (dval + 10 > val) {  
        if (Math.Mod(val,10) != 0)  
          return dcap + ' ' + to_19[Math.Mod(val,10)];  
        return dcap;  
      }      
    }  
    return 'No se puede';  
 }  
  // convert a value < 1000 to english, special cased because it is the level that kicks   
  // off the < 100 special case. The rest are more general. This also allows you to  
  // get strings in the form of "forty-five hundred" if called directly.  
  public static String convert_nnn(integer val) {  
    String word = '';  
   integer rem = val / 100;  
   integer mod = Math.mod(val,100);  
    if (rem > 0) {  
      word = to_19[rem] + ' cientos';  
      if (mod > 0) {  
        word += ' ';  
      }  
    }  
    if (mod > 0) {  
      word += convert_nn(mod);  
    }  
    return word;  
  }  
  public static String english_number(long val) {  
    if (val < 100) {  
      return convert_nn(val.intValue());  
    }  
    if (val < 1000) {  
      return convert_nnn(val.intValue());  
    }  
    for (integer v = 0; v < denom.size(); v++) {  
      integer didx = v - 1;  
      integer dval = (integer)Math.pow(1000, v);  
      if (dval > val) {  
        integer mod = (integer)Math.pow(1000, didx);  
        integer l = (integer) val / mod;  
        integer r = (integer) val - (l * mod);  
        String ret = convert_nnn(l) + ' ' + denom[didx];  
        if (r > 0) {  
          ret += ', ' + english_number(r);  
        }  
        return ret;  
      }  
   }  
    return 'No se puede';  
  }  
}