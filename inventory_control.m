% Startup
clear
home
disp('Welcome to the Inventory Control Simulator!')
disp(' ')
 Min1 = -1*ones(10000,3);
 Min2 =  -1*ones(10000,3);
 iterator = 1;

% Get Parameters
%
% N = input('Time Horizon, N: ');
% c = input('Per Unit Ordering Cost, c: ');
% fc = input('Fixed Cost Component, fc: ');
% p = input('Per Unit Backlog Cost, p: ');
% h = input('Per Unit Inventory Cost, h: ');
% wlo = input('Smallest Possible Demand Per Stage, wlo: ');
% whi = input('Largest Possible Demand Per Stage, whi: ');
% inventory_max = input('Largest Allowable Inventory: ');
% backlog_max = input('Largest Allowable Backlog: ');
% Ntrials = input('Number of trials (>=100): ');
for i = 0:10 
    for j = 0: 10
littleS = i;
%input('s: ');
bigS = j;
%input('S: ');


% Fixed Parameters
%
N = 100;
c = 1.0;
fc = 3.0;
p = 1.5;
h = .85;
wlo = 2;
whi = 6;
inventory_max = 10;
backlog_max = 10;

% CONDITION 1

Ntrials = 1000;
% littleS = 3;
% bigS = 3;

cost_vec1 = NaN(Ntrials, 1);
for trial = 1:Ntrials,

    %Start Command Loop
    cost = 0;
    x = 0;
    for k = 0:N-1,
        if x < littleS
            u = max(0, bigS - x);
        else
            u = 0;
        end
        if x+u > inventory_max,
            u = inventory_max - x; % this prevents the inventory from exceeding inventory_max
        end
        cost = cost + c*u;
        if u > 0, % add fixed cost component if necessary
            cost = cost + fc;
        end
        w = wlo + floor((whi - wlo + 1)*rand);
        x = x+u-w; % ideal next state
        cost = cost + p*max([0,-x]) + h*max([0,x]); 
        x = max([x,-backlog_max]); % now enforce backlog bound
    end

    % Save sample value
    cost_vec1(trial, 1) = cost;
    
end

% Estimate confidence interval
mean_cost1 = mean(cost_vec1)
std_cost1 = std(cost_vec1);
CI_lowerbound1 = mean_cost1 - 1.96*std_cost1/(sqrt(Ntrials))
CI_upperbound1 = mean_cost1 + 1.96*std_cost1/(sqrt(Ntrials))





% CONDITION 2

% Fixed Parameters
%
% littleS = 4;
% bigS = 4;

cost_vec2 = NaN(Ntrials, 1);
for trial = 1:Ntrials,

    %Start Command Loop
    cost = 0;
    x = 0;
    for k = 0:N-1,
        if x < littleS
            u = max(0, bigS - x);
        else
            u = 0;
        end
        if x+u > inventory_max,
            u = inventory_max - x; % this prevents the inventory from exceeding inventory_max
        end
        cost = cost + c*u;
        if u > 0, % add fixed cost component if necessary
            cost = cost + fc;
        end
        w = wlo + floor((whi - wlo + 1)*rand);
        x = x+u-w; % ideal next state
        cost = cost + p*max([0,-x]) + h*max([0,x]); 
        x = max([x,-backlog_max]); % now enforce backlog bound
    end

    % Save sample value
    cost_vec2(trial, 1) = cost;
    
end

% Estimate confidence interval
mean_cost2 = mean(cost_vec2)
std_cost2 = std(cost_vec2);
CI_lowerbound2 = mean_cost2 - 1.96*std_cost2/(sqrt(Ntrials))
CI_upperbound2 = mean_cost2 + 1.96*std_cost2/(sqrt(Ntrials))


% MODIFIED TWO-SAMPLE t CONFIDENCE INTERVAL
fhat_num = (std_cost1^2/Ntrials + std_cost2^2/Ntrials)^2;
fhat_den = (std_cost1^2/Ntrials)^2/(Ntrials-1) + (std_cost2^2/Ntrials)^2/(Ntrials-1);
fhat = fhat_num/fhat_den % effectively infinity
difference_CI_low = (mean_cost1 - mean_cost2) - 1.96*sqrt(std_cost1^2/Ntrials + std_cost2^2/Ntrials)
difference_CI_high = (mean_cost1 - mean_cost2) + 1.96*sqrt(std_cost1^2/Ntrials + std_cost2^2/Ntrials)

Min1(iterator,1) = mean_cost1;
Min1(iterator,2) = i;
Min1(iterator,3) = j;
Min2(iterator,1) = mean_cost2;
Min2(iterator,2) = i;
Min2(iterator,3) = j;
iterator = iterator + 1;
    end
end

