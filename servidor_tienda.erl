-module(servidor_tienda).
-export([abre_tienda/0, pedido_ajustado/2, ajuste_compra/2, cierra_tienda/0, servidor/1, busca_socio/2, crea_socio/2, lista_socios/1, elimina_socio/2]).

servidor(Datos) -> %Datos = socios
    receive
        %Devuelve ok
        {De, {crea_socio, Quien}} ->
            De ! {servidor_tienda, ok},
            servidor(crea_socio(Quien, Datos));

        %Devuelve algo más
        {De, {lista_socios}} ->
        De ! {servidor_tienda, lista_socios(Datos)},
            servidor(Datos);
        
         %Devuelve ok
        {De, {elimina_socio, Quien}} ->
        De ! {servidor_tienda, ok},
            servidor(elimina_socio(Quien, Datos));

        %Devuelve algo más
        {De, {consulta_socio, Quien}}->
            De ! {servidor_tienda, busca_socio(Quien, Datos)},
            servidor(Datos);

        {De, {registra_producto, Producto, Cantidad}} ->
            case lista_producto(Producto, Datos) of
                indefinido ->
                    if
                        Cantidad >= 0 ->
                            De ! {servidor_tienda, ok},
                            servidor(registra_producto(Producto, Cantidad, Datos));
                        true ->
                            De ! {servidor_tienda, no},
                            servidor(Datos)
                    end;
                _ ->
                    De ! {servidor_tienda, no},
                    servidor(Datos)
            end;

        {De, {elimina_producto, Producto}} ->
            case lista_producto(Producto, Datos) of
                indefinido ->
                    De ! {servidor_tienda, no},
                    servidor(Datos);
                _ ->
                    De ! {servidor_tienda, ok},
                    servidor(elimina_producto(Producto, Datos))
            end;

        {De, {modifica_producto, Producto, Cantidad}} ->
            case lista_producto(Producto, Datos) of
                indefinido ->
                    De ! {servidor_tienda, no},
                    servidor(Datos);
                Cantidad when Cantidad >= 0 ->
                    De ! {servidor_tienda, ok},
                    servidor(modifica_producto(Producto, Cantidad, Datos));
                Saldo when Saldo >= -Cantidad ->
                    De ! {servidor_tienda, ok},
                    servidor(modifica_producto(Producto, Cantidad, Datos));
                _ ->
                     De ! {servidor_tienda, no},
                    servidor(Datos)
            end;

        {De, {lista_producto, Producto}} ->
            De ! {servidor_tienda, lista_producto(Producto, Datos)},
            servidor(Datos);

        {De, {lista_existencias}} ->
            De ! {servidor_tienda, lista_existencias(Datos)},
            servidor(Datos);

        {De, {crea_pedido, Quien, Productos}} ->
            De ! {servidor_tienda, {Quien, pedido_ajustado(Productos, Datos)}},
            servidor(Datos);

        {fin} -> trabajo_terminado
    end.

pedido_ajustado(Productos, Datos) ->
    Inventario = lista_existencias(Datos),
    lists:map(fun(X) -> ajuste_compra(X, Inventario) end, Productos).

ajuste_compra({Producto, Cantidad}, Inventario) ->
    ExistenciaTupla = lists:keyfind(Producto, 1, Inventario),
    {_, Existencia} = ExistenciaTupla, 
    if
        (Cantidad > Existencia) -> {Producto, Existencia};
        true -> {Producto, Cantidad}
    end.

ajuste_existencia({Producto, Cantidad}, [Curr | Tail]) ->
    case Curr of
        {_, _} -> 
            %ExistenciaTupla = lists:keyfind(Producto, 1, Datos),
            {_, Existencia} = Curr,
            [{Producto, Existencia - Cantidad} | ajuste_existencia(Tail)].

busca_socio(Quien, [Quien|_])->
    Quien;
    
busca_socio(Quien, [_|T]) -> 
    busca_socio(Quien, T);

busca_socio(_, _) -> 
    indefinido.

elimina_socio(Quien, Socios) ->
    Socios -- [Quien].
    


lista_socios([A | T])->
    case A of
        {_, _} -> lista_socios(T);
        _ -> [A | lista_socios(T)]
    end;
lista_socios([]) -> [].

crea_socio(Quien, Socios) ->
    case lists:member(Quien,Socios) of
        false -> lists:append(Socios, [Quien]);
        true -> Socios
    end.

registra_producto(Producto, X, [{Producto, Cantidad}| T]) ->
    [{Producto, Cantidad + X} | T];
registra_producto(Producto, X, [H | T]) ->
    [H | registra_producto(Producto, X, T)];
registra_producto(Producto, X, []) ->
    [{Producto, X}].

elimina_producto(Producto, Datos) ->
    lists:delete({Producto, lista_producto(Producto, Datos)}, Datos).

modifica_producto(Producto, X, [{Producto, Saldo}| T]) ->
    [{Producto, Saldo + X} | T];
modifica_producto(Producto, X, [H | T]) ->
    [H | modifica_producto(Producto, X, T)];
modifica_producto(_, _, []) ->
    indefinido.

lista_producto(Producto, [{Producto, Saldo} | _]) ->
    Saldo;
lista_producto(Producto, [_ | T]) ->
    lista_producto(Producto, T);
lista_producto(_, _) ->
    indefinido.

lista_existencias([H | T]) -> 
    case H of
        {_, _} -> [H | lista_existencias(T)];
        _ -> lista_existencias(T) 
    end;
lista_existencias([]) -> [].

abre_tienda() ->
    register(servidor_tienda, %Cambiar a tienda
        spawn(?MODULE, servidor, [[]])).

cierra_tienda() ->
    servidor_tienda ! {fin}.

%Eliminar con menos de 2 elementos crash (creo que ya quedó, chequen)