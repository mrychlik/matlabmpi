function count = mandel(x1,x2,y1,y2,gridSize,maxIterations,radius)
    x = linspace( x1, x2, gridSize(1) );
    y = linspace( y1, y2, gridSize(2) );
    [xGrid,yGrid] = meshgrid( x, y );
    z0 = xGrid + 1i*yGrid;
    count = ones( size(z0) );

    % Calculate
    z = z0;
    for n = 0:maxIterations
        z = z.*z + z0;
        inside = abs( z )<=radius;
        count = count + inside;
    end
    count = log( count );
end
