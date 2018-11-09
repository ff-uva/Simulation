nPoints = 3000;
x=zeros(nPoints,1);
y=zeros(nPoints,1);
inside=zeros(nPoints,1);

figure;


for i=1:100
    w=waitforbuttonpress;
    
    x(i) = rand*2-1;
    y(i) = rand*2-1;
    
    inside(i) = 1*(x(i)^2+y(i)^2<=1.0);
    
    subplot(1,2,1);
    hold off;
    circle(0,0,1);
    hold on;
    I = find(inside>0);
    plot(x(I),y(I),'r.');
    I = find(inside<1);
    plot(x(I),y(I),'b.');
    
    subplot(1,2,2);
    hold off;
    piEstimate=4*cumsum( inside )./cumsum(ones(nPoints,1));
    piUpperEstimate=piEstimate+2./sqrt(cumsum(inside));
    piLowerEstimate=piEstimate-2./sqrt(cumsum(inside));
    plot( 1:i, piEstimate(1:i) );
    hold on;
    plot( 1:i, piUpperEstimate(1:i),'b:' );
    plot( 1:i, piLowerEstimate(1:i),'b:' );

    str1 = ['\pi \approx ' num2str(piEstimate(i))];
    text(i,piEstimate(i),str1);
    title('4 X Fraction of Points Inside the Circle');
    xlabel('Number of points');
    ylabel('Estimate of \pi');
    axis([0,100,2,4]);
end

for i=101:nPoints
    x(i) = rand*2-1;
    y(i) = rand*2-1;
    
    inside(i) = 1*(x(i)^2+y(i)^2<=1.0);
    
    subplot(1,2,1);
    hold off;
    circle(0,0,1);
    hold on;
    I = find(inside>0);
    plot(x(I),y(I),'r.');
    I = find(inside<1);
    plot(x(I),y(I),'b.');

    subplot(1,2,2);
    hold off;
    piEstimate=4*cumsum( inside )./cumsum(ones(nPoints,1));
    piUpperEstimate=piEstimate+2./sqrt(cumsum(inside));
    piLowerEstimate=piEstimate-2./sqrt(cumsum(inside));
    plot( 1:i, piEstimate(1:i),'r' );
    hold on;
    plot( 1:i, piUpperEstimate(1:i),'b:' );
    plot( 1:i, piLowerEstimate(1:i),'b:' );
    axis([0,nPoints,2,4]);
    str1 = ['\pi \approx ' num2str(piEstimate(i))];
    text(i,piEstimate(i),str1);
    title('4 X Fraction of Points Inside the Circle');
    xlabel('Number of points');
    ylabel('Estimate of \pi');
    pause(.003);
end

