% Clear command window
clear
home

% Set simulation stop time and warmup time
hours_of_simulation_time = input('Number of hours of simulation time: ');
hours_of_warmup_time = input('Number of hours of warmup time: ');
T = hours_of_simulation_time*60*60;  % X*60*60 corresponds to X hours
T_warmup = hours_of_warmup_time*60*60;  % X*60*60 corresponds to X hours
disp(' ')

% Parameter for arrival times
lambda_arrival = (1/115.236);

% Parameters for different service times
mean_id_check = 27.13;
mean_baggage_check = 27.60;
mean_metal_detector = 5.359;
std_id_check = 16.43;
std_baggage_check = 8.601;
std_metal_detector = 2.186;

% Create truncated normal distributions for service times
pd1 = makedist('Normal','mu', mean_id_check,'sigma', std_id_check);
pd2 = makedist('Normal','mu',mean_baggage_check,'sigma',std_baggage_check);
pd3 = makedist('Normal','mu',mean_metal_detector,'sigma',std_metal_detector);
truncateID = truncate(pd1, 0, 10^307);
truncateBag = truncate(pd2, 0, 10^307);
truncateMetal = truncate(pd3, 0, 10^307);

% Initialize placeholder times
t1a = 0;
t1b = 0;
t20a = 0;
t21a = 0;
t22a = 0;
t23a = 0;
t20b = 0;
t21b = 0;
t22b = 0;
t23b = 0;
t3a = 0;
t3b = 0;

% Initialize counters
NA1 = 0;  % number of system arrivals in phase 1 up to t
ND1 = 0;  % number of system departures in phase 1 up to t
event_counter1 = 1;  % number of events in phase 1 up to t (treating the initial as the first event)
NA2 = 0;  % number of system arrivals in phase 2 up to t
ND2 = 0;  % number of system departures in phase 2 up to t
event_counter2 = 1;  % number of events in phase 2 up to t (treating the initial as the first event)
NA3 = 0;  % number of system arrivals in phase 3 up to t
ND3 = 0;  % number of system departures in phase 3 up to t
event_counter3 = 1;  % number of events in phase 3 up to t (treating the initial as the first event)

% Initialize states of different parts of the system
n1 = 0;
n2a = 0;
n2b = 0;
n2c = 0;
n3 = 0;

% Initialize placeholder states
n2aa = 1;
n2bb = 1;

% Initialize temporary arrival and departure times
tA1 = exponential_random_variable(lambda_arrival);
tD1 = T-1;
tA2 = T-1;
tD2a = T-1;
tD2b = T-1;
tD2c = T-1;
tA3 = T-1;
tD3 = T-1;

% Initialize time after simulation
Tp = 0;

% Initialize output data structures
A1 = -1*ones(100000,1);  % phase 1 arrival times
D1 = -1*ones(100000,1);  % phase 1 departure times
A2 = -1*ones(100000,1);  % phase 2 arrival times
D2 = -1*ones(100000,1);  % phase 2 departure times
A3 = -1*ones(100000,1);  % phase 3 arrival times
D3 = -1*ones(100000,1);  % phase 3 departure times

% Data structures for plotting the time course of people in the system
times1 = -1*ones(200000,1); % phase 1 event times
times1(1, 1) = t1a;
ns1 = -1*ones(200000,1); % numbers of people during phase 1 event times
ns1(1, 1) = n1;
times2 = -1*ones(200000,1); % phase 2 event times
times2(1, 1) = t20a;
ns2 = -1*ones(200000,1); % numbers of people during phase 2 event times
ns2(1, 1) = (n2a+n2b+n2c);
times3 = -1*ones(200000,1); % phase 3 event times
times3(1, 1) = t3a;
ns3 = -1*ones(200000,1); % numbers of people during phase 3 event times
ns3(1, 1) = n3;

% Start simulation loop
not_done = 1;
while not_done
    
    if (tA1 <= tD1) && (tA1 <= T)  % new arrival at phase 1 (Case 1)
        t1a = tA1;
        NA1 = NA1 + 1;
        n1 = n1 + 1;
        tA1 = t1a + exponential_random_variable(lambda_arrival);
        if n1 == 1 % arrival is the only person in phase 1
            tD1 = t1a + random(truncateID);
            tA2 = tD1;
        end
        A1(NA1, 1) = t1a;
        event_counter1 = event_counter1 + 1;
        ns1(event_counter1, 1) = n1;
        times1(event_counter1, 1) = t1a;
        
    elseif ((n2a == 1) && (n2b == 1) && (n2c == 1)) && (tA2 <= min([tD2a tD2b tD2c])) && (tA2 <= T)  % no departure from phase 1 and no arrival for phase 2 (Case 2)
        tD1 = min([tD2a tD2b tD2c]);
        if tD1 < 10^307 
            tA2 = tD1;
        end
        n3 = n3 + 1;
        if (min([tD2a tD2b tD2c]) == tD2a) % next departure is from line 1
            t20a = tD2a;
            t3a = tD2a;
            n2a = n2a - 1;
            ND2 = ND2 + 1;
            NA3 = NA3 + 1;
            if n3 == 1 % arrival is the only person in phase 3
                tD3 = t3a + random(truncateMetal);
            end
            tD2a = inf;
            D2(ND2, 1) = t20a;
            A3(NA3, 1) = t3a;
            event_counter2 = event_counter2 + 1;
            event_counter3 = event_counter3 + 1;
            ns2(event_counter2, 1) = (n2a+n2b+n2c);
            ns3(event_counter3, 1) = n3;
            times2(event_counter2, 1) = t20a;
            times3(event_counter3, 1) = t3a;
        elseif (min([tD2a tD2b tD2c]) == tD2b) % next departure is from line 2
            t20a = tD2b;
            t3a = tD2b;
            n2b = n2b - 1;
            ND2 = ND2 + 1;
            NA3 = NA3 + 1;
            if n3 == 1 % arrival is the only person in phase 3
                tD3 = t3a + random(truncateMetal);
            end
            tD2b = inf;
            D2(ND2, 1) = t20a;
            A3(NA3, 1) = t3a;
            event_counter2 = event_counter2 + 1;
            event_counter3 = event_counter3 + 1;
            ns2(event_counter2, 1) = (n2a+n2b+n2c);
            ns3(event_counter3, 1) = n3;
            times2(event_counter2, 1) = t20a;
            times3(event_counter3, 1) = t3a;
        elseif (min([tD2a tD2b tD2c]) == tD2c) % next departure is from line 3
            t20a = tD2c;
            t3a = tD2c;
            n2c = n2c - 1;
            ND2 = ND2 + 1;
            NA3 = NA3 + 1;
            if n3 == 1 % arrival is the only person in phase 3
                tD3 = t3a + random(truncateID);
            end
            tD2c = inf;
            D2(ND2, 1) = t20a;
            A3(NA3, 1) = t3a;
            event_counter2 = event_counter2 + 1;
            event_counter3 = event_counter3 + 1;
            ns2(event_counter2, 1) = (n2a+n2b+n2c);
            ns3(event_counter3, 1) = n3;
            times2(event_counter2, 1) = t20a;
            times3(event_counter3, 1) = t3a;
        end
        if min([tD2a tD2b tD2c]) < 10^307
            tA3 = min([tD2a tD2b tD2c]);
        end
        
    elseif ((n2a == 0) || (n2b == 0) || (n2c == 0)) && (tA2 <= min([tD2a tD2b tD2c])) && (tA2 <= T)  % departure from phase 1 and arrival for phase 2 (Case 3)
        n1 = n1 - 1;
        if (n2a == 0) % no one is in line 1
            t1a = tD1;
            t21a = tD1;
            n2a = n2a +1;
            n2aa = 0;
            ND1 = ND1 + 1;
            NA2 = NA2 + 1;
            if n1 > 0 % someone is in phase 1
                tD1 = t1a + random(truncateID);
            else % no one is in phase 1
                tD1 = inf;
            end
            tD2a = t21a + random(truncateBag);
            D1(ND1, 1) = t1a;
            A2(NA2, 1) = t21a;
            event_counter1 = event_counter1 + 1;
            event_counter2 = event_counter2 + 1;
            ns1(event_counter1, 1) = n1;
            ns2(event_counter2, 1) = (n2a+n2b+n2c);
            times1(event_counter1, 1) = t1a;
            times2(event_counter2, 1) = t21a;
        elseif (n2aa == 1 && n2b == 0) % someone is in line one but no one is in line 2
            t1a = tD1;
            t22a = tD1;
            n2b = n2b + 1;
            n2bb = 0;
            ND1 = ND1 + 1;
            NA2 = NA2 + 1;
            if n1 > 0 % someone is in phase 1
                tD1 = t1a + random(truncateID);
            else % no one is in phase 1
                tD1 = inf;
            end
            tD2b = t22a + random(truncateBag);
            D1(ND1, 1) = t1a;
            A2(NA2, 1) = t22a;
            event_counter1 = event_counter1 + 1;
            event_counter2 = event_counter2 + 1;
            ns1(event_counter1, 1) = n1;
            ns2(event_counter2, 1) = (n2a+n2b+n2c);
            times1(event_counter1, 1) = t1a;
            times2(event_counter2, 1) = t22a;
        elseif (n2aa == 1 && n2bb == 1 && n2c == 0) % someone is in line one and two but no one is in line 3
            t1a = tD1;
            t23a = tD1;
            n2c = n2c + 1;
            ND1 = ND1 + 1;
            NA2 = NA2 + 1;
            if n1 > 0 % someone is in phase 1
                tD1 = t1a + random(truncateID);
            else % no one is in phase 1
                tD1 = inf;
            end
            tD2c = t23a + random(truncateBag);
            D1(ND1, 1) = t1a;
            A2(NA2, 1) = t23a;
            event_counter1 = event_counter1 + 1;
            event_counter2 = event_counter2 + 1;
            ns1(event_counter1, 1) = n1;
            ns2(event_counter2, 1) = (n2a+n2b+n2c);
            times1(event_counter1, 1) = t1a;
            times2(event_counter2, 1) = t23a;
        end
        n2aa = 1;
        n2bb = 1;
        if tD1 < 10^307
            tA2 = tD1;
        end
        if min([tD2a tD2b tD2c]) < 10^307
            tA3 = min([tD2a tD2b tD2c]);
        end
        
    elseif (tA3 <= tD3) && (tA3 <= T) % departure for phase 2 and arrival for phase 3 (Case 4)
        n3 = n3 + 1;        
        if (min([tD2a tD2b tD2c]) == tD2a) % next departure is from line 1
            t20a = tD2a;
            t3a = tD2a;
            n2a = n2a - 1;
            ND2 = ND2 + 1;
            NA3 = NA3 + 1;
            if n3 == 1 % arrival is the only person in phase 3
                tD3 = t3a + random(truncateMetal);
            end
            tD2a = inf;
            D2(ND2, 1) = t20a;
            A3(NA3, 1) = t3a;
            event_counter2 = event_counter2 + 1;
            event_counter3 = event_counter3 + 1;
            ns2(event_counter2, 1) = (n2a+n2b+n2c);
            ns3(event_counter3, 1) = n3;
            times2(event_counter2, 1) = t20a;
            times3(event_counter3, 1) = t3a;
        elseif (min([tD2a tD2b tD2c]) == tD2b) % next departure is from line 2
            t20a = tD2b;
            t3a = tD2b;
            n2b = n2b - 1;
            ND2 = ND2 + 1;
            NA3 = NA3 + 1;
            if n3 == 1 % arrival is the only person in phase 3
                tD3 = t3a + random(truncateMetal);
            end
            tD2b = inf;
            D2(ND2, 1) = t20a;
            A3(NA3, 1) = t3a;
            event_counter2 = event_counter2 + 1;
            event_counter3 = event_counter3 + 1;
            ns2(event_counter2, 1) = (n2a+n2b+n2c);
            ns3(event_counter3, 1) = n3;
            times2(event_counter2, 1) = t20a;
            times3(event_counter3, 1) = t3a;
        elseif (min([tD2a tD2b tD2c]) == tD2c) % next departure is from line 3
            t20a = tD2c;
            t3a = tD2c;
            n2c = n2c - 1;
            ND2 = ND2 + 1;
            NA3 = NA3 + 1;
            if n3 == 1 % arrival is the only person in phase 3
                tD3 = t3a + random(truncateMetal);
            end
            tD2c = inf;
            D2(ND2, 1) = t20a;
            A3(NA3, 1) = t3a;
            event_counter2 = event_counter2 + 1;
            event_counter3 = event_counter3 + 1;
            ns2(event_counter2, 1) = (n2a+n2b+n2c);
            ns3(event_counter3, 1) = n3;
            times2(event_counter2, 1) = t20a;
            times3(event_counter3, 1) = t3a;
        end
        if min([tD2a tD2b tD2c]) < 10^307
            tA3 = min([tD2a tD2b tD2c]);
        end
        
    elseif (tD3 < tA3) && (tD3 <= T) % departure for phase 3 (Case 5)
        t3a = tD3;
        n3 = n3 - 1;
        ND3 = ND3 + 1;
        if n3 > 0 % someone is in phase 3
            tD3 = t3a + random(truncateMetal);
        else % no one is in phase 3
            tD3 = inf;
        end
        D3(ND3, 1) = t3a + 100;
        event_counter3 = event_counter3 + 1;
        ns3(event_counter3, 1) = n3;
        times3(event_counter3, 1) = t3a;
        
    elseif ((n2a == 1) && (n2b == 1) && (n2c == 1)) && (tA2 > T) && (n1 > 0) % no departure from phase 1 and no arrival for phase 2 (Case 6)
        tD1 = min([tD2a tD2b tD2c]);
        if tD1 < 10^307
            tA2 = tD1;
        end
        n3 = n3 + 1;
        if (min([tD2a tD2b tD2c]) == tD2a) % next departure is from line 1
            t20b = tD2a;
            t3b = tD2a;
            n2a = n2a - 1;
            ND2 = ND2 + 1;
            NA3 = NA3 + 1;
            if n3 == 1 % arrival is the only person in phase 3
                tD3 = t3b + random(truncateMetal);
            end
            tD2b = inf;
            D2(ND2, 1) = t20b;
            A3(NA3, 1) = t3b;
            event_counter2 = event_counter2 + 1;
            event_counter3 = event_counter3 + 1;
            ns2(event_counter2, 1) = (n2a+n2b+n2c);
            ns3(event_counter3, 1) = n3;
            times2(event_counter2, 1) = t20b;
            times3(event_counter3, 1) = t3b;
        elseif (min([tD2a tD2b tD2c]) == tD2b) % next departure is from line 2
            t20b = tD2a;
            t3b = tD2a;
            n2b = n2b - 1;
            ND2 = ND2 + 1;
            NA3 = NA3 + 1;
            if n3 == 1 % arrival is the only person in phase 3
                tD3 = t3b + random(truncateMetal);
            end
            tD2b = inf;
            D2(ND2, 1) = t20b;
            A3(NA3, 1) = t3b;
            event_counter2 = event_counter2 + 1;
            event_counter3 = event_counter3 + 1;
            ns2(event_counter2, 1) = (n2a+n2b+n2c);
            ns3(event_counter3, 1) = n3;
            times2(event_counter2, 1) = t20b;
            times3(event_counter3, 1) = t3b;
        elseif (min([tD2a tD2b tD2c]) == tD2c) % next departure is from line 3
            t20b = tD2c;
            t3b = tD2c;
            n2c = n2c - 1;
            ND2 = ND2 + 1;
            NA3 = NA3 + 1;
            if n3 == 1 % arrival is the only person in phase 3
                tD3 = t3b + random(truncateMetal);
            end
            tD2c = inf;
            D2(ND2, 1) = t20b;
            A3(NA3, 1) = t3b;
            event_counter2 = event_counter2 + 1;
            event_counter3 = event_counter3 + 1;
            ns2(event_counter2, 1) = (n2a+n2b+n2c);
            ns3(event_counter3, 1) = n3;
            times2(event_counter2, 1) = t20b;
            times3(event_counter3, 1) = t3b;
        end
        if min([tD2a tD2b tD2c]) < 10^307
            tA3 = min([tD2a tD2b tD2c]);
        end
        
    elseif ((n2a == 0) || (n2b == 0) || (n2c == 0)) && (tA2 > T) && (n1 > 0) % departure from phase 1 and arrival for phase 2 after run time (Case 7)
        n1 = n1 - 1;
        if (n2a == 0) % no one is in line 1
            t1b = tD1;
            t21b = tD1;
            n2a = n2a + 1;
            n2aa = 0;
            ND1 = ND1 + 1;
            NA2 = NA2 + 1;
            tD1 = t1b + random(truncateID);
            tD2a = t21b + random(truncateBag);
            D1(ND1, 1) = t1b;
            A2(NA2, 1) = t21b;
            event_counter1 = event_counter1 + 1;
            event_counter2 = event_counter2 + 1;
            ns1(event_counter1, 1) = n1;
            ns2(event_counter2, 1) = (n2a+n2b+n2c);
            times1(event_counter1, 1) = t1b;
            times2(event_counter2, 1) = t21b;
        elseif (n2aa == 1 && n2b == 0) % someone is in line one but no one is in line 2
            t1b = tD1;
            t22b = tD1;
            n2b = n2b + 1;
            n2bb = 0;
            ND1 = ND1 + 1;
            NA2 = NA2 + 1;
            tD1 = t1b + random(truncateID);
            tD2b = t22b + random(truncateBag);
            D1(ND1, 1) = t1b;
            A2(NA2, 1) = t22b;
            event_counter1 = event_counter1 + 1;
            event_counter2 = event_counter2 + 1;
            ns1(event_counter1, 1) = n1;
            ns2(event_counter2, 1) = (n2a+n2b+n2c);
            times1(event_counter1, 1) = t1b;
            times2(event_counter2, 1) = t22b;
        elseif (n2aa == 1 && n2bb == 1 && n2c == 0) % someone is in line one and two but no one is in line 3
            t1b = tD1;
            t23b = tD1;
            n2c = n2c + 1;
            ND1 = ND1 + 1;
            NA2 = NA2 + 1;
            tD1 = t1b + random(truncateID);
            tD2c = t23b + random(truncateBag);
            D1(ND1, 1) = t1b;
            A2(NA2, 1) = t23b;
            event_counter1 = event_counter1 + 1;
            event_counter2 = event_counter2 + 1;
            ns1(event_counter1, 1) = n1;
            ns2(event_counter2, 1) = (n2a+n2b+n2c);
            times1(event_counter1, 1) = t1b;
            times2(event_counter2, 1) = t23b;
        end
        n2aa = 1;
        n2bb = 1;
        if tD1 < 10^307
            tA2 = tD1;
        end
        if min([tD2a tD2b tD2c]) < 10^307
            tA3 = min([tD2a tD2b tD2c]);
        end
        
    elseif (tA3 > T) && (max([n2a n2b n2c]) > 0) % departure from phase 2 and arrival for phase 3 after run time (Case 8)
        n3 = n3 + 1;
        if (max([n2a n2b n2c]) == n2a) % next departure is from line 1
            t20b = tD2a;
            t3b = tD2a;
            n2a = n2a - 1;
            ND2 = ND2 + 1;
            NA3 = NA3 + 1;
            if n3 == 1 % arrival is the only person in phase 3
                tD3 = t3b + random(truncateMetal);
            end
            D2(ND2, 1) = t20b;
            A3(NA3, 1) = t3b;
            event_counter2 = event_counter2 + 1;
            event_counter3 = event_counter3 + 1;
            ns2(event_counter2, 1) = (n2a+n2b+n2c);
            ns3(event_counter3, 1) = n3;
            times2(event_counter2, 1) = t20b;
            times3(event_counter3, 1) = t3b;
        elseif (max([n2a n2b n2c]) == n2b) % next departure is from line 2
            t20b = tD2b;
            t3b = tD2b;
            n2b = n2b - 1;
            ND2 = ND2 + 1;
            NA3 = NA3 + 1;
            if n3 == 1 % arrival is the only person in phase 3
                tD3 = t3b + random(truncateMetal);
            end
            D2(ND2, 1) = t20b;
            A3(NA3, 1) = t3b;
            event_counter2 = event_counter2 + 1;
            event_counter3 = event_counter3 + 1;
            ns2(event_counter2, 1) = (n2a+n2b+n2c);
            ns3(event_counter3, 1) = n3;
            times2(event_counter2, 1) = t20b;
            times3(event_counter3, 1) = t3b;
        elseif (max([n2a n2b n2c]) == n2c) % next departure is from line 3
            t20b = tD2c;
            t3b = tD2c;
            n2c = n2c - 1;
            ND2 = ND2 + 1;
            NA3 = NA3 + 1;
            if n3 == 1 % arrival is the only person in phase 3
                tD3 = t3b + random(truncateMetal);
            end
            D2(ND2, 1) = t20b;
            A3(NA3, 1) = t3b;
            event_counter2 = event_counter2 + 1;
            event_counter3 = event_counter3 + 1;
            ns2(event_counter2, 1) = (n2a+n2b+n2c);
            ns3(event_counter3, 1) = n3;
            times2(event_counter2, 1) = t20b;
            times3(event_counter3, 1) = t3b;
        end
        if min([tD2a tD2b tD2c]) < 10^307
            tA3 = min([tD2a tD2b tD2c]);
        end
        
    elseif (tD3 > T) && (n3 > 0) % departure from phase 3 after run time (Case 9)
        t3b = tD3;
        n3 = n3 - 1;
        ND3 = ND3 + 1;
        tD3 = t3b + random(truncateMetal);
        D3(ND3, 1) = t3b + 100;
        event_counter3 = event_counter3 + 1;
        ns3(event_counter3, 1) = n3;
        times3(event_counter3, 1) = t3b;
        
    elseif (tA1 > T) && (tA2 > T) && (tA3 > T) && (tD3 > T) && (n1 <= 0) && (n2a <= 0) && (n2b <= 0) && (n2c <= 0) && (n3 <= 0) % end simulation (Case 10)
        if tD3 > 10^307
            Tp = max(tA3-T, 0);
        else
            Tp = max(tD3-T, 0);
        end
        not_done = 0;
        
    end
    
end

% Save results of simulation in arrays
ns1 = ns1(1:event_counter1, 1);
times1 = times1(1:event_counter1, 1);
A1 = A1(1:NA1, 1);
D1 = D1(1:ND1, 1);
ns2 = ns2(1:event_counter2, 1);
times2 = times2(1:event_counter2, 1);
A2 = A2(1:NA2, 1);
D2 = D2(1:ND2, 1);
ns3 = ns3(1:event_counter3, 1);
times3 = times3(1:event_counter3, 1);
A3 = A3(1:NA3, 1);
D3 = D3(1:NA1, 1);

% Report total number of people serviced
disp(['Total number of people serviced: ' num2str(length(D3)-10) ' (people)'])

% Compute and report average time in system
average_time_in_system = D3(1:length(A1)-10)-A1(1:end-10);
disp(['Average time in system: ' num2str(mean(average_time_in_system)) ' (sec)'])

% Report extra time after simulation the server must work
disp(['Extra time the last server must work: ' num2str(Tp) ' (sec)'])

% Graph of counts of times in system
figure(4)
histogram(D3(1:NA1-10, 1) - A1(1:NA1-10, 1))
xlabel('Time in System (sec)')
ylabel('Count')  

% Graph of time in system for travelers
figure(3)
plot(D3(1:end-10, 1), average_time_in_system)
xlabel('Traveler Number')
ylabel('Time in System')
grid

% Graph of total system arrivals and departures during times
figure(2)
plot(A1, (1:NA1), 'r', D3, (1:NA1), 'b')
axis auto
xlabel('Time (sec)')
ylabel('Total System Arrivals (red) and Departures (blue)')
grid

% Graph of number of people waiting at id check during times
figure(1)
scatter(times1(1:end-10), ns1(1:end-10))
axis auto
xlabel('Time (sec)')
ylabel('Number of People Waiting at ID Check (people)')
grid
