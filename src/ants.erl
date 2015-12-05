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
-export([]).













newPath(X,Y,AntInfo,Map,Time)->
  ant:update(AntInfo),

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


