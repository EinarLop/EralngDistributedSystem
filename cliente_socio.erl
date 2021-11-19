-module(cliente_socio).
-export([consulta_socio/1, crea_pedido/2, crea_socio/1, lista_socios/0, elimina_socio/1, lista_existencias/0]).

matriz() -> 'tienda@MSI'.

lista_socios() ->
    llama_banco({lista_socios}).

elimina_socio(Quien) ->
    llama_banco({elimina_socio, Quien}).

consulta_socio(Quien) -> 
    llama_banco({consulta_socio, Quien}).

crea_socio(Quien) -> 
    llama_banco({crea_socio, Quien}).

lista_existencias() -> % Hay que mover este metodo a clientes, El metodo muestra todos los productos disponibles en existencia.
    llama_banco({lista_existencias}).

crea_pedido(Quien, Productos) ->
    llama_banco({crea_pedido, Quien, Productos}).

llama_banco(Mensaje) ->
    Matriz = matriz(),
    %Monitorea nodo en caso de haberse caido
    monitor_node(Matriz, true),
    {servidor_tienda, Matriz} ! {self(), Mensaje},
    receive 
        {servidor_tienda, Respuesta} ->
            monitor_node(Matriz, false),
            Respuesta;
        {nodedown, Matriz} ->
            'nodo caido'
    end.