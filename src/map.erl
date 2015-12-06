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
  hivePheromon,foodPheromon,hivePheromonStrength,foodPheromonStrength}).

%%-define (Map,#map).

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
      [{XY,Strength,Time}] = ets:lookup(Name,Key),


      {_,_,NewTime} = ets:update_element(Name,Key,{XY,Strength,Time+DeltaT}),
      if NewTime > 100 ->
        ets:delete(Name,Key);
        true ->
          ok
      end,
      updateTable(Name,ets:next(Name,Key),DeltaT)
  end.


addHivePheromon(Map,X,Y,Time) ->
  addPheromon(Map#map.hivePheromon,X,Y,Time).

addFoodPheromon(Map,X,Y,Time) ->
  addPheromon(Map#map.foodPheromon,X,Y,Time).

addPheromon(Table,X,Y,Time)->
  Strength = 100 - Time,
  %Only add if the Phereomon is stronger
  Ans = ets:lookup(Table,X*Y),
  if Ans /= [] ->
    {_,OldStrength,_}=tl(Ans),
    if Strength > OldStrength ->
      ets:insert(Table,{X*Y,Strength,0});
      true ->
        ok
    end;
    true ->
      ok
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
  if Dist < 4 ->
    {FX,FY};
    true ->
      close_to(X,Y,Food)
  end.


home_dir(Map,X,Y)->
  dir(X,Y,get_neighbours(Map#map.hivePheromon,X,Y),0,false,Map#map.height).

food_dir(Map,X,Y)->
  dir(X,Y,get_neighbours(Map#map.foodPheromon,X,Y),0,false,Map#map.height).

dir(_,_,[],_,XYPos,MapHeight)->
  if XYPos == false ->
    false;
    true ->
      {XYPos/MapHeight,XYPos rem MapHeight}
  end;
dir(X,Y,[HD|TL],OldStrength,XYPos,MapHeight) ->
  {XY,Strength,_} = HD,

  if OldStrength < Strength ->
    dir(X,Y,TL,Strength,XY,MapHeight);
    true ->
      dir(X,Y,TL,OldStrength,XYPos,MapHeight)
  end.


get_neighbours(Table,X,Y)->
  ets:lookup(Table,{(X+1)*(Y-1)}) ++ ets:lookup(Table,{(X)*(Y-1)}) ++ ets:lookup(Table,{(X-1)*(Y-1)}) ++
    ets:lookup(Table,{(X+1)*(Y+1)}) ++ ets:lookup(Table,{(X)*(Y+1)}) ++ ets:lookup(Table,{(X-1)*(Y+1)}) ++
    ets:lookup(Table,{(X+1)*(Y)}) ++ ets:lookup(Table,{(X+1)*(Y)}).




















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
