function maxEig = pacefilt(img, L, sigma)
    % maxEig = pacefilt(img, L, sigma)
    %
    % detects ridges in a 2D image "img" via eigenvalues of local Hessian
    % matricies for each pixel. The Hessian describes the "ridge" vs.
    % "valley" structure from the local gradients of the pixels.
    %
    % Inputs:
    %   img:
    %       2D image of any type
    %
    %   L:
    %       the size (in pixels) of the gaussian kernel used for computing
    %       smoothg gradients 
    %   
    %   sigma:
    %       the SD of the gaussian, which determines the spatial frequency
    %       for the convolution
    %
    % Adpated from ridgfilt and eig2image functions from mathworks

   
    g = fspecial('gaussian', L, sigma);

    [gx , gy ] = gradient(g);
    [gxx, gxy] = gradient(gx);
    [~  , gyy] = gradient(gy);
    
    % determine second derivatives
    rxx = conv2(img, gxx, 'same');
    rxy = conv2(img, gxy, 'same');
    ryy = conv2(img, gyy, 'same');

    % Compute the eigenvalues
    tmp  = sqrt((rxx - ryy).^2 + 4*rxy.^2);
    eig1 = 0.5*(rxx + ryy - tmp);
    eig2 = 0.5*(rxx + ryy + tmp);
    
    % Sort eigen values by absolute value 
    check = abs(eig2) > abs(eig1);
    eig1(check) = eig2(check);

    maxEig = abs(eig1);
end