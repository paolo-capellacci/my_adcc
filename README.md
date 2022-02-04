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
Erlang permette di avviare un processo su una macchina in rete e tale processo si identifica come nodo e tale nodo può comunicare con altri nodi dello stesso computer, ma anche con nodi su altri computer e / o reti diverse. Quindi una volta definito un nome al processo, Erlang provvederà a identificarlo all0interno del computer ed in rete.  

## Gestione dei nodi.
Il progetto prevedere l'uso della console da cui vi avvia un processo dandogli un nome, ogni istanza sarà un nodo con un nome univoco del tipo nome_nodo@nome_computer.
A seguito è necessario implementare le seguenti funzioni al fine che soddisfino le specifiche del progetto.
- addNode(TS, Node)
- removeNode(TS node)
- listNode(TS)

## Gestione delle Tuple
In questo caso il progetto deve provvedere:
- new(name)
crea un nuovo TS con un nome
- out(TS, Tuple)
permette di unseirire una tupla nel TS indicato
- rd(TS, Pattern)
permette di cercare ne TS se una tupla esiste
- in(TS, Pattern)


