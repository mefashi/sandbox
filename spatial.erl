%% http://postgis.refractions.net/documentation/manual-1.5/reference.html

-module(spatial).
-include_lib("eunit/include/eunit.hrl").
-export([make_point/2, make_polygon/1, make_polygon/2, make_line/1, make_line/2, len/1]).

%% constructors.
make_point(X, Y) ->
    {point, [X, Y]}.

make_polygon(Exterior) ->
    make_polygon(Exterior, []).
make_polygon({linestring, Coords}, Interiors) ->
    unimplemented.
    %% Holes = lists:map(fun({linestring, C}) -> C end, Interiors),
    %% {polygon, [Coords|Holes]}.

make_line(Points) when is_list(Points) ->
    {linestring, proplists:get_all_values(point, Points)}.
make_line(StartPoint, EndPoint) ->
    make_line([StartPoint, EndPoint]).


%% 'length' is a BIF !
len({point, _}) -> 0.0;
len({linestring, Coords}) ->
    {_, Sum} = lists:foldl(fun(Point, {LastPoint, Sum}) ->
                        {Point, Sum + distance(Point, LastPoint)}
                end, {hd(Coords), 0}, Coords),
    Sum;
len({polygon, Coords}) ->
    len({linestring, hd(Coords)}).

%%
distance([X, Y], [X, Y]) -> 0.0;
distance([X1, Y1], [X2, Y2]) ->
    math:sqrt((X2 - X1) * (X2 - X1) + (Y2 - Y1) * (Y2 - Y1)).


constructors_test() ->
    ?assertEqual(make_point(12, 9), {point, [12, 9]}),
    ?assertEqual(make_line([make_point(9,20), make_point(12,4)]),
                 {linestring, [[9,20], [12, 4]]}),

    Ext = make_line([make_point(12,-1), make_point(14,42)]),
    ?assertEqual(make_polygon(Ext), {polygon, [[[12,-1], [14,42]]]}),
    Int = [make_line([make_point(9,-12), make_point(0,0)])],
    ?assertEqual(make_polygon(Ext, Int), {polygon, [[[12,-1], [14,42]],
                                                    [[9,12], [0,0]]]}).

len_test() ->
    ?assertEqual(len({point, [20, 42]}), 0.0),
    ?assertEqual(len({linestring, [[1, 0], [0, 0], [1, 0], [1, 1]]}), 3.0).
