% add padding on bottom and right side of image
function image = padImage(inp_image, n)
    r = size(inp_image, 1);
    c = size(inp_image, 2);
    channels = size(inp_image, 3);
    if mod(r, n)
        r_new  = r+n-mod(r, n);
    else
        r_new = r;
    end
    if mod(c, n)
        c_new = c+n-mod(c, n);
    else
        c_new = c;
    end
    image = zeros([r_new, c_new, channels], 'uint8');
    image(1:r, 1:c, :) = inp_image;
end

% Division into blocks(subimages)
function blocks = getBlocks(grey_img, n)
    x = size(grey_img, 1);
    y = size(grey_img, 2);
    blocks = cell(1, (x/n)*(y/n));
    idx = 1;
    for i=0:size(grey_img, 1)/n - 1
        for j=0:size(grey_img, 2)/n - 1
            blocks{idx} = double(grey_img(i*n+1:i*n+n, j*n+1:j*n+n));
            idx=idx+1;
        end
    end
end

% joining all subimages
function image = joinBlocks(blocks, n, sz)
    idx=1;
    for i=0:sz(1)/n - 1
        for j=0:sz(2)/n - 1
            image(i*n+1:i*n+n, j*n+1:j*n+n) = uint8(blocks{idx});
            idx=idx+1;
        end
    end
end

% level shifting
function blocks = shift(blocks, n_term, inv)
    %------------------------------------------------%
    % level shift                                    %
    % if inv==1 ? inverse level shift : level shift  %
    %------------------------------------------------%
    if inv==1 
        n_term = n_term*(-1);
    end
    for i=1:length(blocks)
        blocks{i} = blocks{i} - n_term;
    end
end

% funtion to get the probabilites of pixel values in each block
function [keys, probs] = getProbs(lists, n)
    probs = cell(1, length(lists));
    keys = cell(1, length(lists));
    for idx=1:length(lists)
        % replacing the eob symbol with 0
        lists{idx}(lists{idx}==-1000) = 0;
        % getting all the unique pixel values
        keys{idx} = unique(lists{idx});
        % updating the number of occurances of pixel values
        for i=1:length(keys{idx})
            probs{idx}(i) = double(sum(lists{idx}==keys{idx}(i), 'all'))/(n*n);
        end
        % updating the number of zeros as after the eob symbol.
        probs{idx}(keys{idx}==0) = probs{idx}(keys{idx}==0) + double((n*n)-length(lists{idx}))/(n*n);
    end
end

