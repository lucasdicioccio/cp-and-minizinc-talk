
% problem values
int: n_users;
set of int: USER = 1..n_users;
array[USER] of int: weight;
int: size;
int: tolerance;

set of int: POS_X = -size..size;
set of int: POS_Y = -size..size;

% DECISIONS: associate each user to a position
array[USER] of var POS_X: x;
array[USER] of var POS_Y: y;

% constraints: balance along X and balance along Y
var int: imbalance1_x;
constraint imbalance1_x = sum(u in USER)( weight[u] *  (bool2int(x[u] > 0) - bool2int(x[u] < 0)));

var int: imbalance1_y;
constraint imbalance1_y = sum(u in USER)( weight[u] *  (bool2int(y[u] > 0) - bool2int(y[u] < 0)));

var int: imbalance2_x;
constraint imbalance2_x = sum(u in USER)( abs(x[u]) * weight[u] *  (bool2int(x[u] > 0) - bool2int(x[u] < 0)));

var int: imbalance2_y;
constraint imbalance2_y = sum(u in USER)( abs(y[u]) * weight[u] *  (bool2int(y[u] > 0) - bool2int(y[u] < 0)));

1..2: use_balance = 2;

% constraint: tolerance on imbalance
constraint (use_balance = 1) -> abs(imbalance1_x) <= tolerance  /\ abs(imbalance1_y) <= tolerance;
constraint (use_balance = 2) -> abs(imbalance1_x) <= tolerance  /\ abs(imbalance1_y) <= tolerance;

% constraint: at most one user per sit
constraint forall(u1, u2 in USER where u1 < u2)
  (   (x[u1] != x[u2])
  \/  (y[u1] != y[u2])
  );

% todo: symmetry breaking  

solve satisfy;



% auxiliary variable
array[POS_X, POS_Y] of var 0..n_users: user0;
array[0..n_users] of var int: weight0;

output [  concat([ "\(weight0[user0[idx_x,idx_y]]) " | idx_x in POS_X]) ++ "\n"
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