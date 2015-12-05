%%%-------------------------------------------------------------------
%%% @author anders
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 05. Dec 2015 15:38
%%%-------------------------------------------------------------------
-module(ants).
-author("anders").

%% API
-export([new/3,update/3]).
-import( ant, [newAnt/3,update/2,setXDir/2,setYDir/2,looking_for_food/1]).
-import(map,[close_to_food/3]).


new(N,X,Y)->
  Ants =  [ {X,Y} || _ <- lists:duplicate(N,1)],
  AntsInfo =  [ ant:newAnt(rand:uniform()*2 -1,rand:uniform()*2 -1,1) || _ <- lists:duplicate(N,1)],
  {Ants,AntsInfo}.

update(Ant,Map,Time)->
  {_,AntInfo} = Ant,
  {update(Ant,[],Map,Time),AntInfo}.
update(Ant,OldAntPos,Map,Time)->
  {A,AntPos,I,AntInfo} = getNext(Ant),

  {X,Y} = A,
  NewAntPos =  [newPath(X,Y,I,Map,Time)] ++ OldAntPos,
  if AntPos == [] ->
    NewAntPos;
    true ->
      update({AntPos,AntInfo},NewAntPos,Map,Time)
  end.





getNext(Ant)->
{[A|AntPos],[I|AntInfo]} = Ant,
{A,AntPos,I,AntInfo}.


newPath(X,Y,AntInfo,Map,Time)->
  ant:update(X,Y,AntInfo,Map,Time),


  XDir = ant:getXDir(AntInfo),
  YDir = ant:getYDir(AntInfo),
  NewX = X + XDir*Time,
  NewY = Y + YDir*Time,

  %if the values are out of bound
  XMim = map:get_xmin(Map),
  XMax = map:get_xmax(Map),

  YMin = map:get_ymin(Map),
  YMax = map:get_ymax(Map),

  if NewX >=  XMax ->
    AnsX = XMax,
    ant:setXDir(AntInfo,-XDir);
    NewX <  XMim ->
      AnsX = XMim,
      ant:setXDir(AntInfo,-XDir);
    true ->
      AnsX = NewX
  end,
  if NewY >=  YMax ->
    AnsY = YMax,
    ant:setYDir(AntInfo,-YDir);
    NewY <  YMin ->
      AnsY = YMin,
      ant:setYDir(AntInfo,-YDir);
    true ->
      AnsY = NewY
  end,

  {AnsX, AnsY}.


