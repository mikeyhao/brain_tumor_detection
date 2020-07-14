function [glcm_contrast, glcm_correlation, glcm_energy, glcm_homogeneity, glcm_entropy, glcm_sd] = pre_imgs_stats(img)
    % smoothing    
    img = medfilt2(img, [3 3]);
    
    % remove white blobs with centroids which are within 10% of the edge
    % to remove texts or other noise
    img = remove_edge_blobs(img);
    
    % enhancement filter
    kernel = [0 -1  0; -1  5 -1; 0 -1  0];
    img = imfilter(img, kernel);
   
    % adaptive histogram equalisation
    hist_img = adapthisteq(img);

    % skull stripping - connected regions
    starting_threshold = 0.02;
    cr_img = auto_strip_skull(hist_img, starting_threshold);
    filled = imfill(cr_img, "holes");
    
    % skull stripping - dilation
    dilation_se = strel("square", 3);
    dilated = imdilate(~filled, dilation_se);
    mask = ~dilated;
    
    % final results of skull stripping
    ss_img = img .* uint8(mask);
    
    % find GLCM of image
    glcm = graycomatrix(ss_img);

    % find contrast, correlation, energy, homogeneity, entropy and standard deviation
    glcm_contrast = graycoprops(glcm, 'contrast');
    glcm_correlation = graycoprops(glcm, 'correlation');
    glcm_energy = graycoprops(glcm, 'energy');
    glcm_homogeneity = graycoprops(glcm, 'homogeneity');
    glcm_entropy = entropy(glcm);
    glcm_sd = std2(glcm);
end