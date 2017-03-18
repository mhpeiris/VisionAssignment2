%% 1a)
x = [1:500]';
y = [1:500]';
a = 2;%randi([1,500],1,1);
b = 5;%randi([1,500],1,1);
c = 7;%randi([1,500],1,1);
z = a*x + b*y + c;
z = z + randn(size(x));
subplot(2,2,1);
scatter(x,y,z)
title('Without Gaussian')
z = imnoise(z,'gaussian');
subplot(2,2,2)
scatter(x,y,z)
title('With Gaussian')

%% 1b)
A = [x y ones(size(x))];
mb_estimate = A\z

%% 1c)

%% 2-1)
