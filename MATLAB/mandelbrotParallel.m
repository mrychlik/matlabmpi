%----------------------------------------------------------------
% File:     mandelbrotParallel.m
%----------------------------------------------------------------
%
% Author:   Marek Rychlik (rychlik@arizona.edu)
% Date:     Mon Feb 27 12:32:56 2023
% Copying:  (C) Marek Rychlik, 2020. All rights reserved.
% 
%----------------------------------------------------------------
% Mandelbrot without GPU, parfor (MATLAB stock example, modified)
p=gcp('nocreate');
if isempty(p)
    p = parpool('local', 8)
end

disp(sprintf('Number of workers: %d', p.NumWorkers));

maxIterations = 500; 
gridSize = [1000,1000];                 % Must be divisible by 8
xlim = [-0.748766713922161, -0.748766707771757];
ylim = [ 0.123640844894862,  0.123640851045266];

% Setup
x1 = xlim(1); x2=xlim(2); y1=ylim(1); y2=ylim(2);
count = mandel(x1, x2, y1, y2,gridSize,maxIterations);

dx = (x2-x1)./p.NumWorkers;
gridSizeParallel = gridSize./[p.NumWorkers,1];
count = [];

q = Par(p.NumWorkers)
parfor j=1:p.NumWorkers
    Par.tic;
    countLocal = mandel(x1 + (j-1).*dx, x1 + j.*dx, y1, y2, gridSizeParallel, maxIterations);
    count = [count, countLocal];
    q(j)=Par.toc;
end
stop(q);
plot(q);

% Show
cpuTime = toc( t );
fig = gcf;
fig.Position = [200 200 600 600];
imagesc( x, y, count );
colormap( [jet();flipud( jet() );0 0 0] );
axis off
title( sprintf( '%1.2fsecs (without GPU)', cpuTime ) );

function count = mandel(x1,x2,y1,y2,gridSize,maxIterations)
    x = linspace( x1, x2, gridSize(1) );
    y = linspace( y1, y2, gridSize(2) );
    [xGrid,yGrid] = meshgrid( x, y );
    z0 = xGrid + 1i*yGrid;
    count = ones( size(z0) );

    % Calculate
    z = z0;
    for n = 0:maxIterations
        z = z.*z + z0;
        inside = abs( z )<=2;
        count = count + inside;
    end
    count = log( count );
end

