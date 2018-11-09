clear;
x = input('What time is your flight? Please input only the hour. e.g 12 for a flight at 12:30  ');
disp(' ');
if (x < 0) | (x > 24)
    disp ('Wrong input. Input again:');
    x = input();
end
if (x == 5) | (x == 6) |(x == 12) |(x == 14) |(x == 15) |(x == 16) |(x == 18)
    disp ('The airport will be busy. Security check will probably take more than 15 minutes.');
    disp ('Please arrive the airport at least 2 hours before the departure.');
else
    disp ('The airport will not be busy. Security check will probably take less than 5 minutes.');
    disp ('Please arrive the airport 1 hour before the departure.');
end