-module(esame).
-export([getListTuples/1]).
-export([new/1, look_up/1, populate/1, out/2, rd/2, rd/3, in/2, in/3]).


getListTuples(Node) ->
	memactor!{getListTuples, Node, self()},
	receive
		{ok, Tuples} ->
			Tuples;
		_ ->
			[]
	end
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% tuples %%%%%%%%%%%%%%%%%%%%%
% crea un nuovo Tuple Space ets (TS)
new(TS) ->
    
    memactor!{new, TS, self()},
    %io:format("esame:new Pid: ~p~n", [self()]),
    receive
        {ok, new} ->   
        	%io:format("esame:new ok ~n"), 
            % sincronizzo i nodi con i nuovi elementi del TS
        	node:addNode(TS, node()),
        	{ok, new};
        {ok, thisExist} -> 
        	
            % sincronizzo i nodi con i nuovi elementi del TS
            node:addNode(TS, node()),
            
            %node:addNode(TS, node()),
        	%io:format("esame:new thisExist ~n"),
            {ok};
        _ ->
        	{error}
    end
.

look_up(TS) ->
	memactor ! {look_up, TS, self()},
	receive
		{look_up, ok} ->
			io:format("esame:look_up -> lista  ok~n", []);
        {error, look_up, ts_non_esiste} ->
            io:format("esame:look_up -> TS non esiste ~n", []);
		_ ->
			io:format("esame:look_up -> lista vuota  ~n", [])
	end
.	

% Puts the tuple Tuple in the TS
populate(TS) ->
    % prendo il memactor del nodo che ha creato il TS
    memactor!{populate, TS, self()},
    % chiama la funzione di sincronizzazione dei nodi
    % nodesactor!{add_to_nodes, {TS, Tupla}}

    receive
        {ok, populate} -> 

            % aggiorno tutti i nodi con i nuovi dati di un TS
        	node:ceckAllNode(TS),
            {ok, populate};
        _ -> 
            {error, ts_non_trovato}
    end
.

% Puts the tuple Tuple in the TS
out(TS, Tuple) ->
    memactor!{out, TS, Tuple, self()},
    receive
        {ok, out} -> 
        	%io:format("esame:out Inserito ~n"),
            node:ceckAll(),
        	{ok, out};

        _ -> 
        	{error, out}
    end
.


rd(TS, Pattern) ->
    io:format("esame:rd ~n", []),
    memactor ! {rd, TS, Pattern, self()},
    receive
        {ok, found, Valore} ->
            io:format("*** esame:rd: Valore trovato: ~p ***\n", [Valore]);
        {error, not_found} -> 
            io:format("*** esame rd match non trovato ***~n", []);
        _ ->
            io:format("*** esame rd error ***~n", [])
    end   
.

rd(TS, Pattern, TimeOut) ->
    io:format("esame:rd ~p~n", [TimeOut]),
    memactor ! {rd, TS, Pattern, self(), TimeOut},
    receive
        {ok, found, Valore} ->
            io:format("*** esame:rd: Valore trovato: ~p ***\n", [Valore]),
            Valore
        after TimeOut ->
            io:format("*** esame rd match non trovato TimeOut ***~n", []),
            {error, not_found}
    end   
.

% Returns a tuple matching the pattern in the TS and deletes if from the TS
% Blocks if there is no tuple matching
in(TS, Pattern) ->
    io:format("esame:in ~n", []),
    memactor ! {in, TS, Pattern, self()},
    receive
        {ok, found, Valore} ->
            % aggiorno i nodi con il cambiamento del TS, 
            % attendo 1 secondo per essere sicuri che la scittura è stata eseguita
            node:ceckDeleteDataTS(TS, Pattern),

            io:format("*** esame:in: Valore trovato: ~p ***\n", [Valore]),
            {ok, found, Valore};
        {ok, not_found} -> 
            io:format("*** esame in match non trovato ***~n", []),
            {error, not_found};
        _ ->
            io:format("*** esame in error ***~n", [])
    end   
.

% Returns a tuple matching the pattern in the TS and deletes if from the TS
% Blocks if there is no tuple matching
in(TS, Pattern, TimeOut) ->
    io:format("esame:in ~n", []),
    memactor ! {in, TS, Pattern, self(), TimeOut},
    receive
        {ok, found, Valore} ->
            % aggiorno i nodi con il cambiamento del TS, 
            % attendo 1 secondo per essere sicuri che la scittura è stata eseguita
            node:ceckDeleteDataTS(TS, Pattern),

            io:format("*** esame:in: Valore trovato: ~p ***\n", [Valore]),
                Valore

        after TimeOut ->
            io:format("*** esame rd match non trovato TimeOut ***~n", []),
            {error, not_found}
    end   
.


