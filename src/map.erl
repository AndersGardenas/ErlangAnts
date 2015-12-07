%%%-------------------------------------------------------------------
%%% @author anders
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 01. Dec 2015 18:11
%%%-------------------------------------------------------------------
-module(map).
-author("anders").
%% API
-export([new/8,
  home_dir/3,food_dir/3,
  close_to_food/3,close_to_hive/3,update/2,
  addFoodPheromon/4,addHivePheromon/4,
  get_ymin/1,get_ymax/1,get_xmin/1,get_xmax/1,
  get_height/1,get_width/1]).

-record(map,{xmin,xmax,ymin,ymax,width,height,food,hive,
  hivePheromon,foodPheromon}).

-define(HIVESIZE,5*5).
-define(PHEROMONLIFETIME,200).
-define(MAXEMUMSTRENGTH,50).

new(Xmin, Xmax,Ymin,Ymax,Food,Hive,HivePheromon,FoodPheromon) ->

  #map{
    width=round(-Xmin+Xmax),height=round(-Ymin+Ymax),
    xmin = Xmin, xmax =  Xmax, ymin = Ymin, ymax = Ymax,
    food = Food, hive = Hive,
    hivePheromon = HivePheromon,foodPheromon = FoodPheromon}.



update(Map,Time)->
  updateTable(Map#map.foodPheromon,ets:first(Map#map.foodPheromon),Time),
  updateTable(Map#map.hivePheromon,ets:first(Map#map.hivePheromon),Time).


updateTable(Name,Key,DeltaT)->
  if Key == '$end_of_table' ->
    ok;
    true ->
      %Update counter wood be faster but doesent work, only takes integer
      [{_,_,Time}] = ets:lookup(Name,Key),
      %Remove phoromon if its old
      if Time+DeltaT > ?PHEROMONLIFETIME ->
        updateTable(Name,ets:next(Name,Key),DeltaT),
        ets:delete(Name,Key);
        true ->
          ets:update_element(Name,Key,{3,Time+DeltaT}),
          updateTable(Name,ets:next(Name,Key),DeltaT)
      end
  end.


addHivePheromon(Map,X,Y,Time) ->
  addPheromon(Map#map.hivePheromon,round(X),round(Y),Time).

addFoodPheromon(Map,X,Y,Time) ->
  addPheromon(Map#map.foodPheromon,round(X),round(Y),Time).

addPheromon(Table,X,Y,Time)->
  Strength = ?MAXEMUMSTRENGTH - Time,
  %Only add if the Pheromon is stronger
  Ans = ets:lookup(Table,{X,Y}),

  if Ans /= [] ->
    [{_,OldStrength,_}]= Ans,
    if Strength >= OldStrength ->
      ets:insert(Table,{{X,Y},Strength,0});
      true ->
        ok
    end;
    true ->
      ets:insert(Table,{{X,Y},Strength,0})
  end.







close_to_food(Map,X,Y)->
  close_to(X,Y,Map#map.food).

close_to_hive(Map,X,Y)->
  close_to(X,Y,Map#map.hive).

close_to(_,_,[])->
  false;
close_to(X,Y,[{FX,FY}|Food])->

  XDist = X-FX,
  YDist = Y-FY,
  Dist = XDist*XDist+YDist*YDist,
  if Dist < ?HIVESIZE ->
    {FX,FY};
    true ->
      close_to(X,Y,Food)
  end.


home_dir(Map,X,Y)->
  dir(get_neighbours(Map#map.hivePheromon,X,Y),0,false).

food_dir(Map,X,Y)->
  dir(get_neighbours(Map#map.foodPheromon,X,Y),0,false).

dir([],_,XYPos)->
  if XYPos == false ->
    false;
    true ->
      XYPos
  end;
dir([HD|TL],OldStrength,XYPos) ->
  {XY,Strength,_} = HD,
  if OldStrength < Strength ->
    dir(TL,Strength,XY);
    true ->
      dir(TL,OldStrength,XYPos)
  end.


get_neighbours(Table,Xin,Yin)->
  X = round(Xin),
  Y = round(Yin),
  ets:lookup(Table,{(X+1),(Y-1)}) ++ ets:lookup(Table,{(X-1),(Y+1)}) ++ ets:lookup(Table,{(X),(Y+1)}) ++
    ets:lookup(Table,{(X+1),(Y+1)}) ++ ets:lookup(Table,{(X-1),(Y-1)}) ++ ets:lookup(Table,{(X),(Y-1)}) ++
    ets:lookup(Table,{(X+1),(Y)}) ++ ets:lookup(Table,{(X-1),(Y)}).



forAll(Name)->
  forAll(Name,ets:first(Name)).
forAll(Name,Key)->
  if Key == '$end_of_table' ->
    io:format("\n"),
    [];
    true ->
      io:format("Print key ~p ", [Key]),
      ets:lookup(Name,Key) ++ forAll(Name,ets:next(Name,Key))
  end.













get_height (Map)->
  Map#map.height.

get_width(Map)->
  Map#map.width.

get_xmin(Map)->
  Map#map.xmin.

get_xmax(Map)->
  Map#map.xmax.

get_ymin(Map)->
  Map#map.ymin.

get_ymax(Map)->
  Map#map.ymax.
