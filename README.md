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

#Arquitectura
Esta sección pretende describir brevemente la arquitectura implementada para resolver el trabajo práctico. 

##Arquitectura alto nivel
Esencialmente se trata de una arquitectura distribuida, de tipo P2P, donde se puede agregar y quitar nodos al cluster sin configuraciones adicionales. Los nodos detectan estas fluctuaciones y actúan en consecuencia. En cada nodo podremos encontrar una réplica integral del estado que nos interesa almacenar (desarrollado en las siguientes secciones) y procesos de forma distribuida, según sea necesario. De esta forma, si se produce la caída de algún nodo, los procesos que vivían en el mismo son re distribuidos en los nodos que permanecen vivos. Por otro lado, al tener el estado completamente replicado en todos los nodos, aseguramos que no se pierda información al realizarse los procesos de failover y takeover.

##Arquitectura nivel medio
Bajando a nivel Nodo, vamos a poder encontrar los siguientes componentes:
* Chats de grupo
* Chats 1 a 1
* Notificaciones
* Componentes de replicación y administración del Nodo

##Arquitectura de componentes
###Chats de grupo
Este componente esta formado a su vez por los siguientes actores:
* ChatGroups.Supervisor -> Supervisor
    * Encargado de supervisar a todos los actores de este componente
* ChatGroups.DynamicSupervisor -> Horde.DynamicSupervisor
    * Encargado de supervisar los ChatGroups dinámicamente
* ChatGroups.Registry -> Horde.Registry
    * Encargado de mantener una referencia a cada uno de los ChatGroups
* ChatGroups -> GenServer
    * Encargado de resolver la lógica funcional inherente al problema de negocio de los Chats de grupo

###Chats 1 a 1
Este componente esta formado a su vez por los siguientes actores:
* Chats.Supervisor -> Supervisor
    * Encargado de supervisar a todos los actores de este componente
* Chats.DynamicSupervisor -> Horde.DynamicSupervisor
    * Encargado de supervisar los Chats dinámicamente
* Chats.Registry -> Horde.Registry
    * Encargado de mantener una referencia a cada uno de los Chats
* Chats-> GenServer
    * Encargado de resolver la lógica funcional inherente al problema de negocio de los Chats 1 a 1

###Notificaciones
Este componente esta formado a su vez por los siguientes actores:
* Notifications.Supervisor -> Supervisor
    * Encargado de supervisar a  Notifications.DynamicSupervisor,    Notifications.Registry
* Notifications.DynamicSupervisor -> Horde.DynamicSupervisor
    * Encargado de supervisar los Notifications dinámicamente
* Notifications.Registry -> Horde.Registry
    * Encargado de mantener una referencia a cada uno de los Notifications
* Notifications -> GenServer
    * Encargado de resolver la lógica de notificar a los usuarios y recuperar las mismas.

###Componentes de replicación y administración del Nodo
Respecto a los componentes de replicación y administración del Nodo, podemos encontrar:
* Cluster.Supervisor -> encargado de gestionar la comunicación del Horde Cluster.
* Pigeon.Node.Observer -> encargado de monitorear el ingreso y egreso de nodos al cluster, actualizando los members de los actores para una correcta distribució y replicación.
* Chats.Crdt -> abstracción encargada de funcionar como un key value storage, donde almacenamos tanto el estado de cada ChatGroups como de cada Chats. Se encarga de replicar el estado a todos los nodos del cluster.
