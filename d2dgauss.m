%%%%%%% The functions used in the main.m file %%%%%%%
% Function "d2dgauss.m":
% This function returns a 2D edge detector (first order derivative
% of 2D Gaussian function) with size n1*n2; theta is the angle that
% the detector rotated counter clockwise; and sigma1 and sigma2 are the
% standard deviation of the gaussian functions.
function h = d2dgauss(n1,sigma1,n2,sigma2,theta)
r=[cos(theta) -sin(theta);
   sin(theta)  cos(theta)];
for i = 1 : n2 
    for j = 1 : n1
        u = r * [j-(n1+1)/2 i-(n2+1)/2]';
        h(i,j) = gauss(u(1),sigma1)*dgauss(u(2),sigma2);
    end
end
h = h / sqrt(sum(sum(abs(h).*abs(h))));

% Function "gauss.m":
function y = gauss(x,std)
y = exp(-x^2/(2*std^2)) / (std*sqrt(2*pi));

% Function "dgauss.m"(first order derivative of gauss function):
function y = dgauss(x,std)
y = -x * gauss(x,std) / std^2;
%%%%%%%%%%%%%% end of the functions %%%%%%%%%%%%%