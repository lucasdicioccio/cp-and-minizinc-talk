% Use this editor as a MiniZinc scratch book
var 5..20: x;
var 0..20: y;

constraint (x > y)  
 -> (   (y mod 2 = 0)
     /\ (y >= 6 /\ y <= 8) 
    );
    
constraint x > 12;
constraint y < 10;
