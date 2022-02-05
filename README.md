# ADCC - Progetto A.A. 2021/2022 
## Implementazione di uno spazio di tuple in Erlang

Progetto di Applicazioni Distribuite e Cloud Computing 

## Applicazioni distribuite e Cloud Computing

Autore 
## Paolo Capellacci


## Descrizione
Questo progetto consiste nell'implementare uno spazio di tuple in linguaggio Erlang

L'implementazione dell'algoritmo si deve soddisfare le seguenti specifiche.
- Gestione dei nodi
- Gestione delle Tuple
- Gestire il sincronismo telle tuple tra i nodi
- Modalita di ricerca con Time Out
- Pattern Macching

## Premessa
Erlang permette di avviare un processo su una macchina in rete e tale processo si identifica come nodo e tale nodo può comunicare con altri nodi dello stesso computer, ma anche con nodi su altri computer e / o reti diverse. Quindi una volta definito un nome al processo, Erlang provvederà a identificarlo all'interno del computer ed in rete.  

## Gestione dei nodi.
Il progetto prevedere l'uso della console da cui vi avvia un processo dandogli un nome, ogni istanza sarà un nodo con un nome univoco del tipo `<nome_nodo@nome_computer>`.
A seguito è necessario implementare le seguenti funzioni al fine che soddisfino le specifiche del progetto.
- addNode(TS, Node)
- removeNode(TS node)
- listNode(TS)
- per funzionare correttamente è necessario implementare una serie di funzioni che risolvono le problematiche di singronizzazione 
##### `Gestire il sincronismo telle tuple tra i nodi)`

## Gestione delle Tuple
In questo caso il progetto deve provvedere:
- ### new(name)

crea un nuovo TS con un nome 
- ### out(TS, Tuple)

permette di unseirire una tupla nel TS indicato
- ### rd(TS, Pattern)

permette di cercare ne TS se una tupla esiste
- ### in(TS, Pattern)

## Pattern Macching
Il pattern Macching deve presedere il carattere jolly identificato con l'atomo any
Example: `<match([any,3,”pippo”], [1,3,”pippo”]) = true>`


```
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
```


## Gestire il sincronismo telle tuple tra i nodi
per rincronizzare i nodi raggiungibilo o meno ma che nell'ets lNode hanno una corrispondenza sono necessarie le seguenti funzioni
- `<node:nodes(TS)>` prende il nome di un TS e restituisce la lista di nodi che hanno corrispondenza nell'lNode, usando ets:select(lNode, `<[{{'$1','$2', '$3'},[{'=:=','$3',TS}],['$2']}])>` 
- (es: listNode, node1@localhost, ts1)
- `<node:listNodes()>` non pende nessun argomento e restutuisce tutti i nodi che sono presenti nell'ets lNode, usando ets:select(lNode,`<[{{'_','$2','_'},[],['$2']}])>`
- `<esame:getListTuples(Node)>` prende come argomento un nodo e restituisce la lista delle tuple per quel nodo, usando ets:select(lNode, `<[{{'$1','$2','$3'},[{'=:=','$2',Node}],['$3']}])>`

Per far si che tutti i nodi abbiano un aggiornamento delle tuple a cui hanno visibilità si è aggiunto la lunzione `<node:ceckAll()>` che utilizzando la funzione `<node:listNode()`>, ha a disposizione tutti i nodi che hanno motivo di essare contattati, e con la funzione `<esame:getListTuple(Node)>` torna la lista dei TS che serve inviare o aggiornare.
In seguito la funzione `<node:updateTsNode(TS, Node)>` aggiorna il nodo con il solo TS che vengono passati come argomento, utile da richiamare all'aggiunta di un nuovo nodo e/o un nuovo TS,

Nel caso di un novo TS non è necessario contattare tutti i nodi e riaggiornare tutti i TS, quindi ho provveduto a aggiungere la funzione `<node:ceckAllNode(TS)>` che passando il `<TS>` come argomneto contatta i soli nodi che hanno visibilità per quel `<TS>` e li aggiorna.





