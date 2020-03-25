
% problem values
int: n_users;
set of int: USER = 1..n_users;
array[USER] of int: weight;
int: size;
int: tolerance;

set of int: POS_X = -size..size;
set of int: POS_Y = -size..size;

array[USER,1..2] of int: preferred;

% DECISIONS: associate each user to a position
array[USER] of var POS_X: x;
array[USER] of var POS_Y: y;

% constraints: balance along X and balance along Y
var int: imbalance1_x;
constraint imbalance1_x = sum(u in USER)( weight[u] *  (bool2int(x[u] > 0) - bool2int(x[u] < 0)));

var int: imbalance1_y;
constraint imbalance1_y = sum(u in USER)( weight[u] *  (bool2int(y[u] > 0) - bool2int(y[u] < 0)));

var int: imbalance2_x;
constraint imbalance2_x = sum(u in USER)( x[u] * weight[u] );

var int: imbalance2_y;
constraint imbalance2_y = sum(u in USER)( y[u] * weight[u] );

1..2: use_balance;

% constraint: tolerance on imbalance
constraint (use_balance = 1) -> abs(imbalance1_x) <= tolerance  /\ abs(imbalance1_y) <= tolerance;
constraint (use_balance = 2) -> abs(imbalance2_x) <= tolerance  /\ abs(imbalance2_y) <= tolerance;

% constraint: at most one user per sit
constraint forall(u1, u2 in USER where u1 < u2)
  (   (x[u1] != x[u2])
  \/  (y[u1] != y[u2])
  );

% todo: symmetry breaking  

array[USER0] of var bool: happy;
constraint happy[0] = false;
constraint forall(u in USER)
  (happy[u] = (x[u] = preferred[u,1] /\ y[u] = preferred[u,2]));

var int: happy_cnt = sum(u in USER)(happy[u]);
solve maximize happy_cnt;



% auxiliary variable
set of int: USER0 = 0..n_users;
array[POS_X, POS_Y] of var USER0: user0;
array[USER0] of var int: weight0;

output [ "happy = \(happy_cnt)\n"
       , "(x,y)+ = \(imbalance1_x) \(imbalance1_y)\n"
       , "(x,y)+ = \(imbalance2_x) \(imbalance2_y)\n"
       ] ++
       [  concat([ if fix(happy[user0[idx_x,idx_y]])
                   then "\(weight0[user0[idx_x,idx_y]])+ "
                   else "\(weight0[user0[idx_x,idx_y]])  "
                   endif
                 | idx_x in POS_X]) ++ "\n"
       | idx_y in POS_Y
       ];
       
       
constraint forall(idx_x in POS_X, idx_y in POS_Y)
  ( (user0[idx_x, idx_y] > 0)
      ->
    (  (x[user0[idx_x, idx_y]] = idx_x)
    /\ (y[user0[idx_x, idx_y]] = idx_y)
    )
  );
constraint forall(u in USER)
  ( user0[x[u], y[u]] = u
  );
constraint weight0[0] = 0;
constraint forall(u in USER)
  ( weight0[u] = weight[u]
  );