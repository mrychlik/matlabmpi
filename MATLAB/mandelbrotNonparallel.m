%----------------------------------------------------------------
% File:     mandelbrotNonparallel.m
%----------------------------------------------------------------
%
% Author:   Marek Rychlik (rychlik@arizona.edu)
% Date:     Mon Feb 27 12:32:56 2023
% Copying:  (C) Marek Rychlik, 2020. All rights reserved.
% 
%----------------------------------------------------------------
% Mandelbrot without GPU (MATLAB stock example, modified)
maxIterations = 500; 
gridSize = [2048,2048];                 % Must be divisible by 8
radius=4;
xlim = [-0.748766713922161, -0.748766707771757];
ylim = [ 0.123640844894862,  0.123640851045266];

% Setup
x1 = xlim(1); x2=xlim(2); y1=ylim(1); y2=ylim(2);
x = linspace( x1, x2, gridSize(1) );
y = linspace( y1, y2, gridSize(2) );


% Non-parallel calculation
tic;
count = mandel(x1, x2, y1, y2,gridSize,maxIterations,radius);disp('Non-parallel time');
cpuTime = toc;

fig = gcf;
fig.Position = [200 200 1024 1024];
imagesc( x, y, count );
colormap( [jet();flipud( jet() );0 0 0] );
axis off
title( sprintf( '%1.2f secs (without GPU, num. workers: %d, radius: %1.2f)', cpuTime, p.NumWorkers, radius ) );


