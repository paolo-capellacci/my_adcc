-module(db).
-export([initdb/0, db/0]).
-export([match/2, generateDisk/1]).

-record(listNode, {
    node,
    ts
}).


%genera un atomo per dare un nome alla tabella dets
generateDisk(TS) ->
	TS_S = atom_to_list(TS),
	TS_S_D = string:concat(TS_S, "D"),
	TSD = list_to_atom(TS_S_D),
	io:format("TS: ~p TSD: ~p ~n", [TS, TSD]),
	TSD
	%Pid ! {TRD}
.

match([], []) ->
    true;

% controlla la lunghezza dell'array  
match(_A, []) ->
    false;

match([], _B) ->
    false;

match([HP | TP], [HL | TL]) ->

    case HP of
        any -> 
            match(TP, TL);
        HL ->
            match(TP, TL);
        _ ->
            false
    end
.

initdb() ->
    case whereis(memactor) of
        undefined -> 
            register(memactor, spawn(?MODULE, db, []));
        _ -> 
            io:format("db: db exist ~n", [])
            
    end,

    % istanzio un ets per contenere la lista dei nodi
    case ets:info(lNode) of
        undefined ->
            case N = ets:new(lNode, [named_table, bag, public, {keypos,#listNode.node}]) of
                lNode -> 
                    io:format("new listNode: ok ~p~n", [N]);
                _ -> 
                    io:format("new listNode: ko ~p~n", [N])
            end;
        _ ->
            io:format("warning  gia creata lNode ~n", [])

    end
.

db() ->

	%%%%%%%%%%%%%%%%% node %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    receive

        
        {addNode, TS, Node, Pid} ->
            %TSR = generateRam(TS),

            % controllo che lo TS esiste
            case ets:info(lNode) of
                undefined ->
                    io:format("db:addNode TS not exist ~p: ~n", [lNode]),
                    Pid ! {lNode, non_trovato};
                _ ->
                    io:format("db:addNode TS exist ~p: ~n", [lNode]),
                    case _R = ets:insert(lNode, #listNode{node=Node, ts= TS}) of
                        true ->
                            io:format("Table: ~p, Tupla: ~p ~n", [lNode, _R]),  %% mostra il contenuto della tupla
                            %%%%%%%%%%%%%%%%%%%%%%node:ceckNodes(),
                            Pid ! {ok, addNode};
                        _ ->
                            Pid ! {error}
                    end  
            end,
        db();

        {nodes, TS, Pid} ->
            %io:format("db:nodes -> 4~n", []),
            case ets:info(lNode) of
                undefined ->
                    %io:format("db:nodes -> Il TS nonn esiste 5~n", []),
                    Pid ! {error};
                _ ->
                    case Nodes = ets:select(lNode, [{{'$1','$2', '$3'},[{'=:=','$3',TS}],['$2']}]) of
                        [] ->

                            %io:format("db:nodes -> Il TS non esiste 6~n", []),
                            Pid ! {error};
                        _ ->

                            %io:format("db:nodes -> Il TS esiste 7~n", []),
                            Pid ! {ok, Nodes}
                    
                    end
            end,
            db();

        {listNode, Pid} ->
            %io:format("db:listNode ->"),
            case ets:info(lNode) of
                undefined ->
                    %io:format("db:nodes -> Il TS nonn esiste 5~n", []),
                    Pid ! {[]};
                _ ->
                    case Nodes = ets:select(lNode,[{{'_','$2','_'},[],['$2']}]) of
                        [] ->

                            %io:format("db:nodes -> Il TS non esiste 6~n", []),
                            Pid ! {[]};
                        _ ->

                            %io:format("db:nodes -> Il TS esiste 7~n", []),
                            Pid ! {ok, lists:usort(Nodes)}
                    
                    end
            end,
        db();


        {removeNode, TS, Node, Pid} ->

            % controllo che il TS esiste
            case ets:info(lNode) of
                undefined ->
                    io:format("db:removeNode TS not exist ~p: ~n", [lNode]),
                    Pid ! {error, non_trovato};
                _ ->
                    case ets:select_delete(lNode, [{{'$1','$2', '$3'},[{'=:=','$2',Node},{'=:=','$3',TS}],[true]}]) of 
                        1 ->
                            % creo una lista delle sole tuple trovate
                            Pid ! {ok, Node};
                        _ -> 
                            %io:format("  match non trovato: ~p, ~p\n", [Value, Pattern]),
                            Pid ! {error}
                    end
                 
            end,
            db();

        {ceckNodeTS, TS, Pid} ->
            case ets:info(TS) of
                undefined ->
                    Pid ! undefined;
                _ ->
                    Pid ! {ok, exist}
            end,

            db();
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% lTuple %%%%%%%%%%%%%%%

	    {getListTuples, Node, Pid} ->
	    	io:format("db:getListTuples  ~n"),
	    	case ets:info(lNode) of
	    		undefined ->
	    			io:format("non listTuple is not created~n",[]),
	    			Pid ! {[]};
	    		_ ->
	    			 case Tuples = ets:select(lNode, [{{'$1','$2','$3'},[{'=:=','$2',Node}],['$3']}]) of
	    			 	[] ->
	    			 		Pid ! {[]};
	    			 	_ ->
	    			 		Pid ! {ok, Tuples}
	    			end
	    	end,
	    	db();


	    %%%%%%%%%%%%%%%%%%%%%%%%%%%% tuple %%%%%%%%%%%%%%%%%%%%%%%%%
	    {new, TS, Pid} ->
            % genera un atomo per la tupla ets
            %TSD = generateDisk(TS),

            %io:format("db:new now I try to create a new table: ~p ,Pid: ~p ~n", [TS, Pid]),

            % controllo se esiste già uno TS con lo stesso nome
            % se eseiste non lo creo nuovo
            % altrimento inserisco un nuovo TS
            case ets:info(TS) of
                undefined ->
                    ets:new(TS, [named_table, bag, public]),
                    %io:format("db:new I had create a new table with name ~p: ~n", [TS]),

                    %dets:open_file(TSD, [{type, bag}, {file, TSD}]),
                    Pid ! {ok, new};
                _-> 
                    %io:format("db:new I do not create a new table with name this exist ~p: ~n", [TS]),
                    Pid ! {ok, thisExist}
            end,
            db();


        {look_up, TS, Pid} ->

            case ets:info(TS) of
                undefined ->
                    io:format("Il TS nonn esiste ~n", []),
                    Pid ! {error, look_up, ts_non_esiste};
                _ ->
                    case Lista = ets:tab2list(TS) of 
                        [] ->
                            io:format("db:look_up -> lista TS: ~p vuota ~n", [TS]),
                            Pid ! {look_up, lista_vuota};
                        _ ->
                            io:format("db:look_up -> lista TS: ~p -> ~p ~n", [TS, Lista]),
                            Pid ! {look_up, ok}
                    end
            end,
            db();

        {populate, TS, Pid} ->
            %TSD = generateDisk(TS),

            % controllo che lo TS esiste
            case ets:info(TS) of
                undefined ->
                    io:format("db:populate TS not exist ~p: ~n", [TS]),
                    Pid ! {new, non_trovato};
                _ ->
                    % creo una lista con la sequenza di numeri da inserire
                    Seq = lists:seq(1,100),

                    % faccio la funzione per foreach
                    AddTupla1 = fun(Id) -> 
                        ets:insert(TS,{Id})
                        %dets:insert(TSD, {Id}) 
                    end,
                    % richiamo la funzione con foreach
                    lists:foreach(AddTupla1,Seq),
                    

                    % faccio la funzione per foreach
                    AddTupla2 = fun(Id) -> 
                        ets:insert(TS,{Id*2, Id*4})
                        %dets:insert(TSD, {Id+2, Id*4}) 
                    end,
                    % richiamo la funzione con foreach
                    lists:foreach(AddTupla2,Seq),
                    

                    % faccio la funzione per foreach
                    %AddTupla3 = fun(Id) -> 
                    %    ets:insert(TS,{Id, Id*2, Id*3}), 
                    %    dets:insert(TSD, {Id, Id*2, Id*3}) 
                    %end,
                    % richiamo la funzione con foreach
                    %lists:foreach(AddTupla3,Seq),
                    

                    % faccio la funzione per foreach
                    AddTupla4 = fun(_Id) -> 
                        ets:insert(TS,{rand:uniform(100), rand:uniform(100), rand:uniform(100)})
                        %dets:insert(TSD, {rand:uniform(100), rand:uniform(100), rand:uniform(100)}) 
                    end,
                    % richiamo la funzione con foreach
                    lists:foreach(AddTupla4,Seq),


                    Pid ! {ok, populate}

            end,
            db();
        
        {out, TS, Tupla, Pid} ->
            %TSR = generateRam(TS),

            % controllo che lo TS esiste
            case ets:info(TS) of
                undefined ->
                    io:format("db:out TS not exist ~p: ~n", [TS]),
                    Pid ! {new, non_trovato};
                _ ->

                    case ets:insert(TS, Tupla) of
                        true ->
                            io:format("Table: ~p, Tupla: ~p ~n", [TS, Tupla]),
                            %%%%%%%%%%%%%%%%%%%%%%node:ceckNodes(),
                            Pid ! {ok, out};
                        _ ->
                            Pid ! {error, out}
                    end  
            end,
        db();

        {rd, TS, Pattern, Pid} ->
            Start = os:system_time(),
            %TSR = generateRam(TS),

            io:format("db:rd TS ~p Pattern ~p Pid ~p: ~n", [TS, Pattern, Pid]),
            % controllo che il TS esiste
            case ets:info(TS) of
                undefined ->
                    io:format("db:rd -> rd TS not exist ~p: ~n", [TS]),
                    Pid ! {new, non_trovato};
                _ ->

                %io:format("memory:rd tuple_to_list ~p ~n", [Pattern]),
                PatternList = tuple_to_list(Pattern),
                %io:format("memory:rd PatternList ~p ~n", [PatternList]),
                MyFun = fun(Value, Acc) -> 
                    ValueList = tuple_to_list(Value),
                    %io:format("rd match da trovare: ~p =:= ~p\n", [Pattern, Value]),

                    case db:match(PatternList, ValueList) of 
                        true ->
                            io:format("  match trovato: ~p, ~p Acc:~p ~n", [Pattern, Value, Acc]),
                            % creo una lista delle sole tuple trovate
                            [Value | Acc];
                        _ -> 
                            %io:format("  match non trovato: ~p, ~p\n", [Value, Acc]),
                            Acc
                            
                    end
                end,
                End = os:system_time(),
                io:format(" *** Tempo : ~p ***~n",[End-Start]),
                Trovato = ets:foldl(MyFun, [], TS),
                io:format("valore di Acc: ~p~n", [Trovato]),

                case Trovato =:= [] of

                    true -> 
                        io:format("case Valore non trovato ~p~n",[Trovato]),
                        Pid ! {error, notfound};
                    _ -> 
                        io:format("case Valore trovato ~p~n",[Trovato]),
                        Pid ! {ok, found, Trovato}
                end
            end,

            db();

        % re con after
        {rd, TS, Pattern, Pid, TimeOut} ->
            Start = os:system_time(),
            %TSR = generateRam(TS),

            io:format("db:rd TS ~p Pattern ~p Pid ~p: ~n", [TS, Pattern, Pid]),
            % controllo che il TS esiste
            case ets:info(TS) of
                undefined ->
                    io:format("db:rd -> rd TS not exist ~p: ~n", [TS]),
                    Pid ! {new, non_trovato};
                _ ->

                %io:format("memory:rd tuple_to_list ~p ~n", [Pattern]),
                PatternList = tuple_to_list(Pattern),
                %io:format("memory:rd PatternList ~p ~n", [PatternList]),

                MyFun = fun(Value, Acc) -> 
                    ValueList = tuple_to_list(Value),
                    %io:format("rd match da trovare: ~p =:= ~p\n", [Pattern, Value]),

                    case db:match(PatternList, ValueList) of 
                        true ->
                            io:format("  match trovato: ~p, ~p Acc:~p ~n", [Pattern, Value, Acc]),
                            % creo una lista delle sole tuple trovate
                            [Value | Acc];
                        _ -> 
                            %io:format("  match non trovato: ~p, ~p\n", [Value, Acc]),
                            Acc
                            
                    end
                end,
                End = os:system_time(),
                io:format(" *** Tempo : ~p ***~n",[End-Start]),
                Trovato = ets:foldl(MyFun, [], TS),
                io:format("valore di Acc: ~p~n", [Trovato]),


                timer:sleep(100),
                T = TimeOut -100,

                if 
                    T < 0 ->
                        io:format("case tempo scaduto ~p~n",[T]),
                            Pid ! {error, not_found};
                    true ->
                        case Trovato =:= [] of
                            true ->
                                io:format("case Valore non trovato *** ~p~n",[T]),
                                memactor ! {rd, TS, Pattern, Pid, T};
                            _ ->
                                io:format("case Valore trovato ... ~p~n",[Trovato]),
                                Pid ! {ok, found, Trovato}
                        end
                end

            end,

            db();

        {in, TS, Pattern, Pid} ->
            %TSR = generateRam(TS),

            % controllo che il TS esiste
            case ets:info(TS) of
                undefined ->
                    io:format("db:in TS not exist ~p: ~n", [TS]),
                    Pid ! {new, non_trovato};
                _ ->

                PatternList = tuple_to_list(Pattern),

                MyFun = fun(Value, Acc) -> 
                    ValueList = tuple_to_list(Value),
                    %io:format("in match da trovare: ~p =:= ~p\n", [Pattern, Value]),

                    case db:match(PatternList, ValueList) of 
                        true ->
                            io:format("  match trovato: ~p, ~p\n", [Pattern, Value]),
                            ets:match_delete(TS, Value),
                            % creo una lista delle sole tuple trovate
                            [Value | Acc];
                        _ -> 
                            %io:format("  match non trovato: ~p, ~p\n", [Value, Pattern]),
                            Acc
                    end
                end,    

                Trovato = ets:foldl(MyFun, [], TS),
                io:format("valore di Acc: ~p~n", [Trovato]),

                case Trovato =:= [] of

                    true -> 
                        io:format("case Valore non trovato ~n"),
                        Pid ! {error, notfound};
                    _ -> 
                        io:format("case Valore trovato ~n"),
                        % se sono qui posso cancellare il Pattern
                        Pid ! {ok, found, Trovato}
                end

            end,
            db();

        {in, TS, Pattern, Pid, TimeOut} ->
            %TSR = generateRam(TS),

            % controllo che il TS esiste
            case ets:info(TS) of
                undefined ->
                    io:format("db:in TS not exist ~p: ~n", [TS]),
                    Pid ! {new, non_trovato};
                _ ->

                PatternList = tuple_to_list(Pattern),

                MyFun = fun(Value, Acc) -> 
                    ValueList = tuple_to_list(Value),
                    %io:format("in match da trovare: ~p =:= ~p\n", [Pattern, Value]),

                    case db:match(PatternList, ValueList) of 
                        true ->
                            io:format("  match trovato: ~p, ~p\n", [Pattern, Value]),
                            ets:match_delete(TS, Value),
                            % creo una lista delle sole tuple trovate
                            [Value | Acc];
                        _ -> 
                            %io:format("  match non trovato: ~p, ~p\n", [Value, Pattern]),
                            Acc
                    end
                end,    

                Trovato = ets:foldl(MyFun, [], TS),
                io:format("valore di Acc: ~p~n", [Trovato]),

                timer:sleep(100),
                T = TimeOut - 100,

                if 
                    T < 0 ->
                        io:format("case tempo scaduto ~p~n",[T]),
                            Pid ! {error, not_found};
                    true ->
                        case Trovato =:= [] of
                            true ->
                                io:format("case Valore non trovato *** ~p~n",[T]),
                                memactor ! {in, TS, Pattern, Pid, T};
                            _ ->
                                io:format("case Valore trovato ... ~p~n",[Trovato]),
                                Pid ! {ok, found, Trovato}
                        end
                end

            end,
            db()

    end
.    
