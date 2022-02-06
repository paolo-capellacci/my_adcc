-module(test).
-export([test/0, test1/0]).


test() ->

	db:initdb(),
.

test1() ->

	db:initdb(),


	esame:new(ts1),
	esame:populate(ts1),
	esame:new(ts2),
	esame:populate(ts2),

	esame:look_up(ts1),
  esame:look_up(ts2)

.
