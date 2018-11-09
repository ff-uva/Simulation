
x=zeros(3000,1);
y=zeros(3000,1);

figure;

for i=1:50
    w=waitforbuttonpress;
    x(i) = rand*2-1;
    y(i) = rand*2-1;
    
    hold off;
    circle(0,0,1);
    hold on;
    plot(x,y,'r.');
end

for i=51:3000
    x(i) = rand*2-1;
    y(i) = rand*2-1;
end

hold off;
circle(0,0,1);
hold on;
plot(x,y,'r.');
