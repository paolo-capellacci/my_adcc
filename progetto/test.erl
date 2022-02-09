-module(test).
-export([start/0, addTS/0, testRD/0, testIN/0]).

start() ->
	db:initdb()
.


addTS() ->

	db:initdb(),
	esame:new(ts1),
	esame:new(ts2),
	esame:populate(ts1),
	esame:populate(ts2),
	node:addNode(ts1, node2@localhost),
	node:addNode(ts2, node2@localhost),
	node:addNode(ts1, node1@localhost),
	node:addNode(ts2, node3@localhost),
	node:addNode(ts1, node3@localhost)

.

testRD() ->
	db:initdb(),
	esame:new(ts1),
	esame:populate(ts1),
	esame:out(ts1, {22, 3, 4}),
	esame:rd(ts1, {22, any, any})
.

testIN() ->

	db:initdb(),
	esame:new(ts1),
	esame:populate(ts1),
	esame:out(ts1, {22, 3, 4}),
	esame:rd(ts1, {22, any, any})
.


