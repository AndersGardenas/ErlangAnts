%%%-------------------------------------------------------------------
%%% @author anders
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 01. Dec 2015 18:00
%%%-------------------------------------------------------------------
-module(array2d).
-author("anders").


%% API
-export( [create/2, get/4, set/5,size/1 ]).

create( X, Y ) -> array:new(X * Y ).

get(Array, X, Y, Height) -> array:get( round(X)* Height + round(Y), Array).

set(Array, X, Y, Value ,Height) ->
  Index = round(X)*Height+round(Y),
  array:set( Index, Value, Array).

size(Array)->
  array:size(Array).