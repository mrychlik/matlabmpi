% FILE: soldiers2.m
% NOTE: Make sure to modify the parpool to allow 14 workers.

buildTroop;

% Main course: count the soldiers by message passing
spmd
    me=labindex;
    N=length(nb);                   % Neighbor count
    m=0;                            % Message count
    v=-ones(N,1);                   % Message values
    V=0;                            % Running total of messages

    labBarrier;                     % Not needed, harmless, for demo purposes

    % Receive first N-2 messages
    while m < N-1
        [isDataAvail,source]=labProbe;
        if isDataAvail              % If available, get the data
            n=find(source==nb,1);   % Find which neighbor sent the msssage
            assert(~isempty(n));    % Otherwise it is not a neighbor
            fprintf('%d sees data available from %d...\n ',me,source);
            value=labReceive(source);
            fprintf('%d received value %d from %d.\n',me,value,source);
            m=m+1;
            v(n)=value;
            V=V+value;
        end
    end

    %labBarrier;                     % Will break the code!!!

    assert(m==N-1);                 % Check number of messages

    % Send the message to who has not send us a message
    n=find(v==-1,1);        % Identify who has not send us a message
    dest=nb(n);
    value_to_send=V+1;
    fprintf('%d sending %d to %d...\n',me,value_to_send,dest);
    labSend(value_to_send,dest);
    %labSendReceive(value_to_send,dest);
    fprintf('%d completed sending %d to %d.\n',me,value_to_send,dest);
    fprintf('%d waiting for message from %d...\n',me,dest);
    [value,last_source]=labReceive(dest);
    fprintf('%d received %d from %d.\n',me,value,last_source);
    assert(last_source==dest);      % Last message source
    v(n)=value;
    V=V+value;
    m=m+1;

    %labBarrier;                     % Will break the code!!!

    assert(m==N);                   % Check message count

    % Send message to everyone except the one who was the last to send us
    % a message.
    for l=1:N
        if l==n
            continue;               % Do not send again
        end
        value_to_send=V+1-v(l);
        fprintf('%d sending %d to %d...\n',me,value_to_send,nb(l));
        labSend(value_to_send,nb(l));
        fprintf('%d completed sending %d to %d.\n',me,value_to_send,nb(l));
    end
    if me==commander
        fprintf('COMMANDER %d reporting count of %d.\n', me, V+1);
    end
    fprintf('%d is done.\n',me);
end

% A demonstration that a Composite is a kind of cell array
% Print the totals of all soldiers.
for n=1:numSoldiers
    fprintf('Running total of %d is %d.\n', n, V{n});
end
