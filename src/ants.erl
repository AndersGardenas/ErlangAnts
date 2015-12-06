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
-import( ant, [newAnt/2,update/2,setXDir/2,setYDir/2,looking_for_food/1]).
-import(map,[close_to_food/3]).


new(N,X,Y)->
  Ants =  [ {X,Y} || _ <- lists:duplicate(N,1)],
  AntsInfo =  [ ant:newAnt(rand:uniform()*2 -1,rand:uniform()*2 -1) || _ <- lists:duplicate(N,1)],
  {Ants,AntsInfo}.

update(Ant,Map,Time)->
  update(Ant,{[],[]},Map,Time).
update(Ant,{AntPos,AtomInfo},Map,Time)->
  {A,OldAntPos,I,OldAtomInfo} = getNext(Ant),

  {X,Y} = A,
  {Pos,Info} = newPath(X,Y,I,Map,Time),
  NewAntPos =  [Pos] ++ AntPos,
  NewAntInfo = [Info] ++ AtomInfo,

  if OldAntPos == [] ->
    {NewAntPos,NewAntInfo};
    true ->
      update({OldAntPos,OldAtomInfo},{NewAntPos,NewAntInfo},Map,Time)
  end.





getNext(Ant)->
{[A|AntPos],[I|AntInfo]} = Ant,
{A,AntPos,I,AntInfo}.


newPath(X,Y,AntInfo,Map,Time)->
  NewAntInfo = ant:update(X,Y,AntInfo,Map,Time),

  Speed = 10,
  XDir = ant:getXDir(NewAntInfo),
  YDir = ant:getYDir(NewAntInfo),
  NewX = X + XDir*Time*Speed,
  NewY = Y + YDir*Time*Speed,

  %if the values are out of bound
  XMim = map:get_xmin(Map),
  XMax = map:get_xmax(Map),

  YMin = map:get_ymin(Map),
  YMax = map:get_ymax(Map),

  if NewX >=  XMax ->
    AnsX = XMax;
   % ant:setXDir(NewAntInfo,-XDir);
    NewX <  XMim ->
      AnsX = XMim;
    %  ant:setXDir(NewAntInfo,-XDir);
    true ->
      AnsX = NewX
  end,
  if NewY >=  YMax ->
    AnsY = YMax;
    %ant:setYDir(NewAntInfo,-YDir);
    NewY <  YMin ->
      AnsY = YMin;
     % ant:setYDir(NewAntInfo,-YDir);
    true ->
      AnsY = NewY
  end,

  {{AnsX, AnsY},NewAntInfo}.


