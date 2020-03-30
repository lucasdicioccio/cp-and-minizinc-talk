
enum OBJ = {Human, Chicken, Grain, Fox};
enum BANK = {Left, Right};

int: maxStep = 8;
set of int: TIME = 1..maxStep;

array[OBJ,TIME] of var BANK: pos;

% items start on the left and must go to the right
constraint forall(o in OBJ)(pos[o,1] = Left);
constraint forall(o in OBJ)(pos[o,maxStep] = Right);

% at most one movement at a time
predicate moves(OBJ: o, 1..maxStep-1: t) =
  pos[o,t] != pos[o,t+1];
predicate stays(OBJ: o, 1..maxStep-1: t) =
  pos[o,t] = pos[o,t+1];

constraint forall(t in 1..maxStep-1, o1, o2 in {Chicken, Grain, Fox} where o1 != o2)
  ( moves(o1, t) -> stays(o2, t)
  );

% human moves with the items
predicate moves(OBJ: o, 1..maxStep-1: t, BANK: from, BANK: to) =
  pos[o,t] = from /\ pos[o,t+1] = to;

constraint forall(o in {Chicken, Grain, Fox}, t in 1..maxStep-1)
  (   ( moves(o, t, Left, Right) -> moves(Human, t, Left, Right) )
   /\ ( moves(o, t, Right, Left) -> moves(Human, t, Right, Left) )
  );

% human must prevents things being eaten
predicate eats(OBJ: what, OBJ: eaten) =
  forall(t in TIME)
    ( pos[what,t] = pos[eaten,t] -> pos[Human,t] = pos[eaten,t]
    );

constraint forall(t in TIME)
  (  eats(Chicken, Grain)
  /\ eats(Fox, Chicken)
  );

output [  "time=\(t): "
       ++ concat([ "\(o): \(pos[o,t]); " | o in OBJ])
       ++ "\n"
       | t in TIME
       ];