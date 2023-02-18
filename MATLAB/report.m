% FILE:     report.m
function report(nb)
% Let soldiers report who their neighbors are.
    spmd
        me=labindex;
        fprintf(['Soldier %d reporting, sir! ',... 
                 'My neighbors are %s sir!\n'],...
                me, num2str(nb,'%d, '));
    end
end
