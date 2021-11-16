-module(cliente_socio).
-export([consulta_socio/1,crea_socio/1, lista_socios/1, elimina_socio/1]).

matriz() -> 'tienda@LAPTOP-MS8JD713'.

lista_socios(Quien) ->
    llama_banco({lista_socios, Quien}).

elimina_socio(Quien) ->
    llama_banco({elimina_socio, Quien}).

consulta_socio(Quien) -> 
    llama_banco({consulta_socio, Quien}).

crea_socio(Quien) -> 
    llama_banco({crea_socio, Quien}).


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