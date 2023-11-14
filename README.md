# IASC Pigeon - 2C2023

### Instalacion

Para instalar hay que hacer solo un `mix deps.get`, para bajar las dependencias

Que pasa si recibo un error como el siguiente?

```
{:failed_connect, [{:to_address, {'repo.hex.pm', 443}}, {:inet, [:inet], {:option, :server_only, :honor_cipher_order}}]}
```

Vamos a tener que ejecutar el siguiente comando -> `mix local.hex` y despues ejecutar el primer comando.

## Como pruebo los cambios desde iex??

Cargando las dependencias y el modulo mediante mix, ejecutando el siguiente comando:

`iex -S mix`

## Casos de prueba basicos

### Envio de mensajes 1 a 1

`lauti = User.new("lauti")`

`agus = User.new("agus")`

`{:ok, chatAgusLauti} = Chat.start_link(%Chat.State{}, ChatAgusLauti)`

`Chat.send_message(chatAgusLauti, Message.new("Hola Agus", lauti, agus))`

`Chat.get_messages(chatAgusLauti)`

### Modificación de un mensaje

`Chat.modify_message(chatAgusLauti, 1699931948791, "Hola Aguuuuus!" )`

`Chat.get_messages(chatAgusLauti)`

### Eliminación de un mensaje

`Chat.delete_message(chatAgusLauti, 1699931948791)`

`Chat.get_messages(chatAgusLauti)`