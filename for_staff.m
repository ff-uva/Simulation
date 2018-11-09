clear;
x = input('What time is it now? Please input only the hour. e.g 12 for 12:30  ');
disp(' ');
if (x < 0) | (x > 24)
    disp ('Wrong input. Input again:');
    x = input();
end
if (x == 4) | (x == 5) |(x == 11) |(x == 13) |(x == 14) |(x == 15) |(x == 17)
    disp ('It is neccesary to open up a second line for baggage checking');
else
    disp ('It is not neccesary to open up a second line for baggage checking');
end