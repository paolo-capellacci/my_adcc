
% il file test è come promemoria per i comandi ma devrei sistemare!! 

c(test).

c(esame).
c(db).
c(node).
db:initdb().

esame:new(ts1).
esame:populate(ts1).
esame:rd(ts1, {222, any, any}).
esame:new(ts2).

esame:populate(ts2).
node:addNode(ts1, node1@localhost).
node:addNode(ts1, node2@localhost).
node:addNode(ts2, node2@localhost).
node:addNode(ts2, node1@localhost).
node:nodes(ts1).
node:ceckAllTuples().

ets:select(lNode,[{{'_','$2','_'},[],['$2']}])

node:removeNode(ts1, node1@localhost).

Q = ets:match(lNode, {'node1@localhost', 'ts1'}).


ets:select(lNode, [{{'$1','$2', '$3'},[{'=:=','$2',node1@localhost},{'=:=','$3',ts1}],['$2','$3']}]).
O = ets:select(lNode, [{{'$1','$2', '$3'},[{'=:=','$2',node1@localhost},{'=:=','$3',ts1}],['$1']}]).
esame:new(ts1).
esame:populate(ts1).
esame:rd(ts1,{2}).
