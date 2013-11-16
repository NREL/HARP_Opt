function f = optStruct(WTPoup)


%% there are not many useful structural objectives that can be obtained from
% only a BEMT analysis
% minimimze the root flap bending moment from WT_Perf
f = max(WTPoup.flapMom);

end % function optStruct