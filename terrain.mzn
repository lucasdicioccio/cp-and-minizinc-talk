
int: xlen;
int: ylen;
enum TILE;
array[TILE] of string: display;
array[TILE] of int: min_weight;
array[TILE] of int: max_weight;
array[int,int] of TILE: txs;

set of int: X = 1..xlen;
set of int: Y = 1..ylen;

predicate transition(var TILE:l, var TILE: r) =
  (l = r)
  \/ exists(x in index_set_1of2(txs))(l = txs[x,1] /\ r = txs[x,2]);

predicate allowed(var TILE:l, var TILE: r) =
  transition(l,r) \/ transition(r,l);

constraint forall(x in 1..xlen-1, y in Y)
  (allowed(terrain[x,y], terrain[x+1,y]));

constraint forall(y in 1..ylen-1, x in X)
  (allowed(terrain[x,y], terrain[x,y+1]));

array[X,Y] of var TILE: terrain;

include "globals.mzn";

constraint global_cardinality_low_up(array1d(terrain),
  TILE,
  min_weight,
  max_weight);

solve :: int_search(terrain, first_fail, indomain_random, complete)
   satisfy;

output [ concat([ display[fix(terrain[x,y])] | x in X]) ++ "\n"
       | y in Y
       ]