% Monty Hall Example - a Matlab Script

% Set up random number generator
myStream=RandStream('mt19937ar');
RandStream.setGlobalStream(myStream)

% Number of trials to run
Ntrials = 20000;

% Player initial door selection probabilities
p_1 = 1/3;
p_2 = 1/3;
p_3 = 1 - p_1 - p_2;
% Note that the probabilities for the actual location of the prize and the
% door to be opened are "hardwired" in below.

% Initialize data structures
outcomes_s1 = zeros(Ntrials,1);
outcomes_s2 = outcomes_s1;

% experiment

for t = 1:Ntrials,
    
    % simulate player selection
    dum = rand;
    if dum <= p_1,
        selection = 1;
    elseif dum > p_1 && dum <= p_1 + p_2,
        selection = 2;
    else
        selection = 3;
    end
    
    % simulate actual location
    dum = rand;
    if dum <= 1/3,
        actual = 1;
    elseif dum > 1/3 && dum <= 2/3,
        actual = 2;
    else
        actual = 3;
    end

    % simulate host response
    if selection == actual, % then open one of other two doors with equal probability
        
        if selection == 1,
            dum = rand;
            if dum < 1/2,
                open = 2;
            else
                open = 3;
            end
        elseif selection == 2,
            dum = rand;
            if dum < 1/2,
                open = 1;
            else
                open = 3;
            end
        else,
            dum = rand;
            if dum < 1/2,
                open = 1;
            else
                open = 2;
            end
        end
        
    else % open the unselected door without the prize
        
        if selection == 1,
            if actual == 2,
                open = 3;
            else
                open = 2;
            end
        elseif selection == 2,
            if actual == 1,
                open = 3;
            else
                open = 1;
            end
        else
            if actual == 1,
                open = 2;
            else
                open = 1;
            end
        end
        
    end
    
    % implement strategy 1
    final_selection = selection;
    
    % record outcome strategey 1
    if final_selection == actual;
        outcomes_s1(t,1) = 1;
    end
    
    % implement strategy 2
    if selection == 1,
        if open == 2,
            final_selection = 3;
        else
            final_selection = 2;
        end
    elseif selection == 2,
        if open == 1,
            final_selection = 3;
        else
            final_selection = 1;
        end
    else
        if open == 1,
            final_selection = 2;
        else
            final_selection = 1;
        end
    end
    
    % record outcome strategey 2
    if final_selection == actual;
        outcomes_s2(t,1) = 1;
    end
    
end

runningaverages_s1 = zeros(Ntrials,1);
runningaverages_s2 = runningaverages_s1;
for t = 1:Ntrials,
    runningaverages_s1(t) = sum(outcomes_s1(1:t))/t;
    runningaverages_s2(t) = sum(outcomes_s2(1:t))/t; % should be the same as 1-runningaverages_s1(t)
end

plot([1:Ntrials]',[runningaverages_s1 runningaverages_s2])
grid
xlabel('Trial number')
ylabel('Fraction (running average) of trials winning the prize')
gtext('Switching Strategy')
gtext('Sticking Strategy')

phat_win_s1 = sum(outcomes_s1)/Ntrials
phat_win_s2 = sum(outcomes_s2)/Ntrials