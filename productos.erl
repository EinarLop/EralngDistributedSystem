-module(productos).
-export([registra_producto/2, modifica_producto/2, elimina_producto/1, lista_existencias/0]).

matriz() -> 'tienda@MSI'.

registra_producto(Producto, Cantidad) -> % El metodo permite generar un producto, debe de ser nombre no registrado y cantidad => 0.
    llama_banco({registra_producto, Producto, Cantidad}).

modifica_producto(Producto, Cantidad) -> % El metodo permite modificar un producto siempre y cuando este registrado y no le quite mayor cantidades a las que tiene.
    llama_banco({modifica_producto, Producto, Cantidad}).

elimina_producto(Producto) -> % El metodo elimina un producto siempre y cuando este en la lista.
    llama_banco({elimina_producto, Producto}).

lista_existencias() -> % Hay que mover este metodo a clientes, El metodo muestra todos los productos disponibles en existencia.
    llama_banco({lista_existencias}).

llama_banco(Mensaje) ->
    Matriz = matriz(),
    monitor_node(Matriz, true),
    {servidor_tienda, Matriz} ! {self(), Mensaje},
    receive
        {servidor_tienda, Respuesta} ->
            monitor_node(Matriz, false),
            Respuesta;
        {nodedown, Matriz} ->
            'nodo caido'
    end.