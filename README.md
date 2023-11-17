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

----------------------------------

# CHAT

ChatWithAgent.send_message(ChatAgusLauti, Message.new("Hola", %User{id: "lauti"}, %User{id: "agus"}))

ChatWithAgent.get_messages(ChatAgusLauti)

ChatWithAgent.modify_message(ChatAgusLauti,1700247261156, "AAAAAAAAA")

ChatWithAgent.delete_message(ChatAgusLauti,1700247261156)

ChatWithAgent.delete_messages(ChatAgusLauti,[1700246636182, 1700246642924, 1700246652675, 1700246653110])


# AGENT
Chats.ChatAgent.add_message(ChatAgent, Message.new("Que onda", %User{id: "lauti"}, %User{id: "agus"}) )

Chats.ChatAgent.get_messages(ChatAgent)

Chats.ChatAgent.modify_message(ChatAgent,1700246344618, "BBBBBBBBBBB" )

Chats.ChatAgent.delete_message(ChatAgent, 1700246344618)

Chats.ChatAgent.delete_messages(ChatAgent, [1700246704557, 1700246702916])

