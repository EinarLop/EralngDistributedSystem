-module(servidor_tienda).
-export([abre_tienda/0, servidor/1, busca_socio/2, crea_socio/2, lista_socios/2, elimina_socio/2]).

servidor(Datos) -> %Datos = socios
    receive
        %Devuelve ok
        {De, {crea_socio, Quien}} ->
        De ! {servidor_tienda, ok},
        servidor(crea_socio(Quien, Datos));

        %Devuelve algo más
        {De, {lista_socios, Quien}} ->
        De ! {servidor_tienda, lista_socios(Quien, Datos)},
            servidor(Datos);
        
         %Devuelve ok
        {De, {elimina_socio, Quien}} ->
        De ! {servidor_tienda, ok},
            servidor(elimina_socio(Quien, Datos));
        
      %Devuelve algo más
        {De, {consulta_socio, Quien}}->
            De ! {servidor_tienda, busca_socio(Quien, Datos)},
            servidor(Datos)
    end.

busca_socio(Quien, [Quien|_])->
    Quien;
    
busca_socio(Quien, [_|T]) -> 
    busca_socio(Quien, T);

busca_socio(_, _) -> 
    indefinido.

elimina_socio(Quien, Socios) ->
    Socios -- [Quien].
    


lista_socios(Quien, [A|T])->
    Quien, %No hace  nada 
    [A|T].

crea_socio(Quien, Socios) ->
    S = lists:member(Quien,Socios),
    if not S ->
        lists:append(Socios, [Quien])
    end.



abre_tienda() ->
    register(servidor_tienda, %Cambiar a tienda
        spawn(?MODULE, servidor, [[]])). 


