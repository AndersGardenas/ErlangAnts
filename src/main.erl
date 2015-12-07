%%%-------------------------------------------------------------------
%%% @author anders
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 01. Dec 2015 18:03
%%%-------------------------------------------------------------------
-module(main).
-author("anders").

%% API
-export([main/0,run/0]).
-import( map, [new/8,update/2]).
-import(ants,[new/ 3,update/3]).

main() ->
  %% Node = node("clientNode"),
  io:format("Started erlang prog \n"),
  receive doNothing ->
    ok
  end.




run()->
  WaintTime = 10000,
  io:format("Run has started \n"),
  receive {masterPid,MasterPid} ->
    io:format("Recived ~p \n", [MasterPid])
  after WaintTime ->
    MasterPid = self()
  end,



  receive {nrAnts,NrAnts} ->
    io:format("Recived NrAnts ~p \n", [NrAnts])
  after WaintTime ->
    NrAnts = 10.0
  end,



  receive {worldMax,WorldMax} ->
    io:format("Recived WorldMax ~p  \n", [WorldMax])
  after WaintTime ->
    WorldMax = 10.0
  end,


  receive {start,Start} ->
    io:format("Recived Start ~p  \n", [Start])
  after WaintTime ->
    Start = 10.0
  end,

  receive {nrActors,N} ->
    io:format("Recived WorldMax ~p  \n", [N])
  after WaintTime ->
    N = 10
  end,



  ets:new(hive,[set,named_table,public]),
  ets:new(food,[set,named_table,public]),


  %Init world
  StartX = Start,
  StartY = Start,
  Map = map:new(0,WorldMax,0,WorldMax,[{StartX +80,StartY + 80}],[{StartX,StartY}],hive,food),

  Self = self(),
  NrActors = max(NrAnts / N,1),

  io:format("Number of actors is ~p  \n", [NrActors]),
  Pids = [spawn_link(fun () -> ants(Self,N,StartX,StartY,Map,MasterPid) end) || _ <- lists:duplicate(trunc(NrActors),1)],

  run(Pids,Map, erlang:timestamp(),MasterPid).
run(Pids,Map,OldTime,MasterPid) ->
  FPS = 1/60,

  NewTime =erlang:timestamp(),
  %%To second
  FirstTimeDif = timer:now_diff(NewTime,OldTime)/1000000,
  if(FirstTimeDif < FPS)->
    timer:sleep(round(FPS*1000 -FirstTimeDif*1000));
    true ->
      ok
  end,
  FinalTime = erlang:timestamp(),
  TimeDif = timer:now_diff(FinalTime,OldTime)/1000000,
  %io:format("FPS ~p \n", [1/TimeDif]),



  %update all ants
  Refs = [send_message(Pid,TimeDif) || Pid <- Pids],
  lists:foreach(
    fun (Ref) ->
      receive Ref ->
        ok
      end
    end
    ,Refs),
%Mutebull object shod not store result
  map:update(Map,TimeDif),

  run(Pids,Map,FinalTime,MasterPid).

%Send a maesge to a Ant
send_message(Pid,TimeDif)->
  Ref =  make_ref(),
  Pid ! {Ref,TimeDif},
  Ref.


%Attns
ants(Pid,N,X,Y,Map,JavaPid)->
  Ants = ants:new(N,X,Y),

  ants(Pid,Ants,Map,JavaPid).
ants(Pid,Ants,Map,JavaPid)->

  receive {Ref,Time} ->
    NewAnts = ants:update(Ants,Map,Time),
    {NewAntsPos,_} = NewAnts,
    JavaPid ! NewAntsPos,
    Pid ! Ref
  after 10000 ->
    NewAnts = null,
    throw("out of time ")
  end,
  ants(Pid,NewAnts,Map,JavaPid).




