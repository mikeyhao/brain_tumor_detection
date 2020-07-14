function [output] = hysteresis(I, T1, T2)
    [m,n,~] = size(I);
    padded_I = padarray(I >= T1, [1 1]);
    strong_I = I >= T2;
    strong_set = [];
    same_cluster_set = [];
    output = zeros(m,n,"uint8");
    cluster_no = 1;
    
    for i = 2:m+1
        for j = 2:n+1
            if padded_I(i,j) == true
                all_neighbours = [];
                neigh_no = 1;
                if padded_I(i-1,j-1) == true
                    all_neighbours(neigh_no) = output(i-2,j-2);
                    neigh_no = neigh_no + 1;
                end
                if padded_I(i-1,j) == true 
                    all_neighbours(neigh_no) = output(i-2,j-1);
                    neigh_no = neigh_no + 1;
                end   
                if padded_I(i,j-1) == true 
                    all_neighbours(neigh_no) = output(i-1,j-2);
                    neigh_no = neigh_no + 1;
                end
                if padded_I(i-1,j+1) == true
                    all_neighbours(neigh_no) = output(i-2,j);
                    neigh_no = neigh_no + 1;
                end
                if size(all_neighbours) > 0
                    min_neigh = min(all_neighbours);
                    output(i-1,j-1) = min_neigh;
                    for k = 1:neigh_no-1
                        curr_neigh = all_neighbours(k);
                        if same_cluster_set(curr_neigh) > min_neigh
                            same_cluster_set(curr_neigh) = min_neigh;
                        end
                        strong_set(curr_neigh) = strong_set(curr_neigh) | strong_I(i-1,j-1);
                    end
                else
                    output(i-1,j-1) = cluster_no;
                    same_cluster_set(cluster_no) = 0;
                    strong_set(cluster_no) = strong_I(i-1,j-1);
                    cluster_no = cluster_no + 1;
                end
            end
        end
    end
    
    for i = 1:cluster_no-1
        k = i;
        while same_cluster_set(k) ~= 0
            k = same_cluster_set(k);
            if strong_set(i) == 1
                strong_set(k) = 1;
            end
        end
        if strong_set(i) == 1
            strong_set(k) = 1;
        end
        same_cluster_set(i) = k;
    end
    
    for i = 1:cluster_no-1
        strong_set(k) = strong_set(same_cluster_set(k));
    end
    
    for i = 1:m
        for j = 1:n
            temp = output(i,j);
            if temp > 0
                I(i,j) = strong_set(temp)*I(i,j);
            end
        end
    end
    
    output = I;
end