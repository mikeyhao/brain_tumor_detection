function [out] = remove_edge_blobs(img)
    % a low threshold so that most non-black pixels will be included.
    if mode(img(:)) > 100
        blobs = img > 15;
    else
        blobs = img > mode(img(:))+15;
    end
    blobs_label = bwlabel(blobs);
    blobs_props = regionprops(blobs_label, 'Centroid');
    centroids = cat(1, blobs_props.Centroid);
    
    if isempty(centroids)
        out = img;
        return
    end
    
    centroid_x = centroids(:,1);
    centroid_y = centroids(:,2);
    [m,n,~] = size(img);
    edge_y = 0.05*m;
    edge_x = 0.05*n;
    center_blobs = find(centroid_x > edge_x & centroid_x < (n - edge_x) & ...
        centroid_y > edge_y & centroid_y < (m + edge_y));
    mask = ismember(blobs_label, center_blobs);
    out = img.*cast(mask, class(img));
end