Kafka
=====

![Kafka Structure](D:\Internship\Kafka\01-kafka-cluster-hero.png)

#### Basic Building blocks

* Zookeeper

* Client

* Producer

* Consumer

##### Zookeeper

ZooKeeper is primarily used to track the status of nodes in the Kafka cluster and maintain a list of Kafka topics and messages. It exists for management purposes.



##### Client

It is a gen_server which has the primary responsibility of establish tcp sockets to kafka brokers and maintain those connections. Once a client is started, it can be used in anywhere in the application for handling data with producers and consumers.



```erlang
-module(testApp_client_svr).
-behaviour(gen_server).

%% API
-export([start_link/0]).
-export([init/1]).
-record(state, {}).
-define(SERVER, ?MODULE).

start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

init(_Args) ->
    {ok, _} = application:ensure_all_started(brod),
    KafkaBootstrapEndpoints = [{"localhost", 9092}],
    ok = brod:start_client(KafkaBootstrapEndpoints, client1),
    {ok, #state{}}.

```



##### Producer

Producers used to publish messages to  a specified Topic in kafka cluster.

```erlang
-module(testApp_publish).
-behaviour(application).
-export([publish/1]).

publish(Msg) ->
    Topic = <<"test-topic">>,
    Partition = 0,
    ok = brod:start_producer(client1, Topic, _ProducerConfig = []),
    {ok, FirstOffset} = brod:produce_sync_offset(
        client1, Topic, Partition, <<"key1">>, <<Msg>>
    ).

```



##### Consumer

Consumer is a gen_server that continously listen to a specified or automatically assigned partition in a specified Topic. Assigning of the partitions to consumers is done by the zookeeper. Primarily consumers exists as groups in kafka. A consumer is responsible for one or more partitions in a specified Topic. Also the maximum number of consumers in a given group cannot be more than the number of partitions in the topic that it consumes.



```erlang

```
