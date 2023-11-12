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

`lauti = User.new("lauti")`
`agus = User.new("agus")`
`{:ok, lauti_pid} = Chat.start_link(%Chat.State{}, LautiChat)`
`{:ok, agus_pid} = Chat.start_link(%Chat.State{}, AgusChat)`
`Chat.send_message(lauti_pid, Message.new("1", "Hola Agus", lauti, agus))`
`Chat.send_message(agus_pid , Message.new("2", "Hola lauti", agus, lauti))`