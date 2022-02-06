-module(node).
-export([addNode/2, nodes/1, removeNode/2, listNode/0]).
-export([updateTsNode/2]).
-export([ceckAll/0, ceckAllNode/1, updateNodeData/0, ceckDataTS/1, ceckDataTS/2, ceckDeleteDataTS/2]).

addNode(TS, Node) ->

    memactor ! {ceckNodeTS, TS, self()}, %case ets:info(lNode) of
    receive
        undefined ->
            %io:format("node:addNode il TS non esiste Pid: ~p~n", [Node]);
            {ts_undefined};
        _ ->
            memactor!{addNode, TS, Node, self()},
            %io:format("node:addNode Pid: ~p~n", [Node]),
            receive
                {ok, addNode} ->   
                    %io:format("node:addNode ok ~n"), 

                    node:ceckAll(),

                    {ok, addNode};
                {lNode, non_trovato} -> 
                    io:format("node:addNode thisExist ~n");
                _ ->
                    {error}
            end
    end


.
nodes(TS) ->
    memactor!{nodes, TS, self()},
    receive
        {ok, Nodes} ->
            %io:format("node:nodes: -> lista  ok 1 ~p~n", [Nodes]),
            Nodes;
        {error} ->
            io:format("node:nodes -> TS non esiste 2 ~n", []);
        _ ->
            io:format("node:nodes -> lista vuota 3 ~n", [])
    end
.   


removeNode(TS, Node) ->
    %io:format("node:removeNode ~n", []),
    memactor ! {removeNode, TS, Node, self()},
    receive
        {ok, Node} ->
            % aggiorno i nodi con il cambiamento del TS, 

            %io:format("*** node:removeNode: Nodo trovato: ~p ***\n", [Node]),
            %node:ceckDataTS(lNode),
            {ok, Node};
        _ ->
            %io:format("*** node:removeNode error ***~n", []),
            {error}
    end   
.

listNode() ->
    memactor ! {listNode, self()},
    receive
        {ok, Node} ->
            % aggiorno i nodi con il cambiamento del TS, 

            %io:format("*** node:removeNode: Nodo trovato: ~p ***\n", [Node]),
            %node:ceckDataTS(lNode),
            Node;
        _ ->
            %io:format("*** node:removeNode error ***~n", []),
            {[]}
    end 
.

% deve sincronizzare lNode, lTuple, TS  %%%%%%%%%%%%%%%%%%%%%%%%%%%%% da finire
ceckAll() ->
    %io:format("io sono in node:ceckAll()~n",[]),


    FunNodes = fun(Node) ->

        %  faccio il ping per essere sicuro che il nodo può rispondete
        case P = net_adm:ping(Node) of
            pong ->

                % il nodo è raggiungibile allora gli mando l'ets con l'elenco [node tuple]
                %io:format("il nodo: ~p ha fatto ~p ~n",[Node, P]),
                case ceckDataTS(lNode) of 
                    ok ->
                        % controllo se il nodo ha visibilità di qualche TS
                        case _TS = esame:getListTuples(Node) of
                            [] ->
                                %io:format("il nodo ~p, non ha visibilità di nessun TS~n",[Node])
                                {ok};
                            _ ->
                                %io:format("il nodo ~p, ha visibilità dei TS ~p ~n",[Node, _TS]),
                                % invio i TS
                                FunTS = fun(Tuples) ->

                                    PidTuples = spawn(Node, ?MODULE, updateNodeData, []),
                                    PidTuples ! {updateND, Tuples, ets:tab2list(Tuples), self()},

                                    receive 
                                        {ok, dump} ->
                                            {ok};
                                        _ ->
                                            {error}
                                    end

                                end, % FunTS
                                lists:foreach(FunTS, esame:getListTuples(Node))

                        end; % case Tuples = getListTuples(Node) of
                    _ ->
                        {error}
                end; % ceckDataTS(lNode)
            _ ->
                io:format("il nodo: ~p ha fatto ~p ~n",[Node, P]),
                {pang}

        end % case P = net_adm:ping(node) of

    end, % FunNodes
    lists:foreach(FunNodes, node:listNode())


.

ceckAllNode(TS) -> % controllo a tutti i nodi il TS
    io:format("sono in node:ceckAll(TS)~n",[]),

    FunNodes = fun(Node) ->
        %  faccio il ping per essere sicuro che il nodo può rispondete
        case P = net_adm:ping(Node) of
            pong ->
                % il nodo è raggiungibile allora gli mando l'ets con l'elenco [node tuple]
                io:format("il nodo: ~p ha fatto ~p ~n",[Node, P]),
                case ceckDataTS(lNode) of 
                    ok ->
                        % invio il TS al nodo
                        PidTuples = spawn(Node, ?MODULE, updateNodeData, []),
                        PidTuples ! {updateND, TS, ets:tab2list(TS), self()},

                        receive 
                            {ok, dump} ->
                                {ok};
                            _ ->
                                {error}
                        end;
                           
                    _ ->
                        {error}
                end; % ceckDataTS(lNode)

            _ ->
                {pang}
        end % case P = net_adm:ping(Node) of

    end, % FunNodes(TS)
    lists:foreach(FunNodes, node:nodes(TS))
.



updateTsNode(TS, Node) ->

    case net_adm:ping(Node) of
        pong ->
            io:format("node:updateTsNodeNode: TS: ~p, Node: ~p ~n ", [TS, Node]),

            Pid = spawn(Node, ?MODULE, updateNodeData, []),
            Pid ! {updateND, TS, ets:tab2list(TS), self()},

            receive
                {ok, dump} ->
                    {ok};
                _ ->
                    {error}
            end;
        _ ->
            {error}
    end
.

% TS = lNode, lTuple, ts1, ts2.. (mando tutto il contenuto dell'ets, l'ets deve esistere)
ceckDataTS(TS) -> 

    io:format("Nodes: ~p Ping:  I'm ~n",[node:nodes(TS)]),
	Fun = fun(Node) -> 
		case Node =:= node() of
			true ->
                % se sono io non faccio niente perchè se sono io ho già il dato
				io:format("Node: ~p Ping:  I'm ~n",[Node]);
			_ ->
				case P = net_adm:ping(Node) of
					pong ->
						io:format("Node: ~p   Ping: ~p~n",[Node, P]),

						Pid = spawn(Node, ?MODULE, updateNodeData, []),
						Pid ! {updateND, TS, ets:tab2list(TS), self()}, 

						receive 
						    {ok, dump} ->
					            {ok};
					        _ ->
					            {error}
					    end;
                    _ ->
                        io:format("Node: ~p Ping: ~p~n",[Node, P]),
                        {pang}
				end
		end
	end,
	lists:foreach(Fun, node:listNode())
.


ceckDataTS(TS, Tupla) -> 

    io:format("Nodes: ~p Ping:  I'm ~n",[node:nodes()]),
    Fun = fun(Node) -> 
        case Node =:= node() of
            true ->
                % se sono io non faccio niente perchè se sono io ho già il dato
                io:format("Node: ~p Ping:  I'm ~n",[Node]);
            _ ->
                case P = net_adm:ping(Node) of
                    pong ->
                        io:format("Node: ~p   Ping: ~p~n",[Node, P]),

                        Pid = spawn(Node, ?MODULE, updateNodeData, []),
                        Pid ! {updateND, TS, Tupla, self()}, 

                        receive 
                            {ok, dump} ->
                                {ok};
                            _ ->
                                {error}
                        end;
                    _ ->
                        io:format("Node: ~p Ping: ~p~n",[Node, P]),
                        {pang}
                end
        end
    end,
    lists:foreach(Fun, node:nodes())
.

ceckDeleteDataTS(TS, Tupla) -> 

    io:format("Nodes: ~p Ping:  I'm ~n",[node:listNode()]),
    Fun = fun(Node) -> 
        case Node =:= node() of
            true ->
                % se sono io non faccio niente perchè se sono io ho già il dato
                io:format("Node: ~p Ping:  I'm ~n",[Node]);
            _ ->
                case P = net_adm:ping(Node) of
                    pong ->
                        io:format("Node: ~p   Ping: ~p~n",[Node, P]),

                        Pid = spawn(Node, ?MODULE, updateNodeData, []),
                        Pid ! {updateNDDelete, TS, Tupla, self()},

                        receive 
                            {ok, dump} ->
                                {ok};
                            _ ->
                                {error}
                        end;
                    _ ->
                        io:format("Node: ~p Ping: ~p~n",[Node, P]),
                        {pang}
                end
        end
    end,
    lists:foreach(Fun, node:listNode())
.

updateNodeData() ->
        % sono il nuovo nodo da aggiornare!!
        % TS -> il nome del tuple space
        % Dump -> la lista delle tuple del TS 
        % Pid -> il pid di chi chiede l'inserimento
    receive

        {updateND, TS, Dump, Pid} ->
            %io:format("mynode:updateNodeData -> {updateND, TS, Dump, Pid} 06 ~n",[]),
            memactor ! {new, TS, self()},
            receive
                {ok, _} ->
                    memactor ! {out, TS, Dump, self()},
                    %io:format("mynode:updateNodeData -> {out, TS, Dump, self()} 07~n",[]),
                    receive
                        {ok, out} ->

                            %io:format("mynode:updateNodeData -> {out, TS, Dump, self()} -> {ok dump 08}~n",[]),
                            Pid ! {ok, dump};
                        _ ->
                            Pid ! {error, dump}
                    end;
                _ -> 
                    {error, new_ts}
            end;

        {updateNDDelete, TS, Tuple, Pid} ->
            %io:format("mynode:updateNDDelete -> {updateND, TS, Dump, Pid} 06 ~n",[]),
            memactor ! {new, TS, self()},
            receive
                {ok, _} ->
                    memactor ! {in, TS, Tuple, self()},
                    %io:format("mynode:updateNDDelete -> {out, TS, Dump, self()} 07~n",[]),
                    receive
                        {ok, out} ->

                            %io:format("mynode:updateNDDelete -> {out, TS, Dump, self()} -> {ok dump 08}~n",[]),
                            Pid ! {ok, dump};
                        _ ->
                            Pid ! {error, dump}
                    end;
                _ -> 
                    {error, new_ts}
            end
    end
.
