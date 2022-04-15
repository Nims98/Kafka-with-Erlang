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
