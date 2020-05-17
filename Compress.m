% Decoder to get the values from code
function lists = Decode(codes, trees)
    lists = cell(1, length(trees));
    for idx=1:length(codes)
        values = getValue(trees{idx}, codes{idx});
        % replacing the eob symbol;
        values(length(values)+1) = -1000;
        lists{idx} = values;
    end
end

function values = getValue(tree, str)
    values = [];
    idx = 1;
    temp_tree = tree;
    while ~isempty(str)
        % traverse tree
        if str(1) == 0
            tree = tree{1};
        else
            tree = tree{2};
        end
        % remove current bit
        str(1) = [];
        % check if the current node is a leaf
        if isa(tree, 'cell')
            continue
        else
            values(idx) = tree;
            idx=idx+1;
            % reset root of the tree to decode new value
            tree = temp_tree;
        end
    end
end

% unpacking list(packed in zigzag block traversal) to block
function blocks = rev_zigzag(list, n)
    blocks = cell(1, length(list));
    for idx=1:length(list)
        block = zeros(n, 'double');
        q=1;
        % first half block
        for i=1:n
            if list{idx}(q)==-1000
               break;
            end
            for j=1:i
               if mod(i, 2)==1
                   block(i+1-j, j) = list{idx}(q);
               else
                   block(j, i+1-j) = list{idx}(q);
               end
               q=q+1;
               if list{idx}(q)==-1000
                   break;
               end
            end
            if list{idx}(q)==-1000
               break;
            end
        end
        
        % second half block
        for i=2:n
            if list{idx}(q)==-1000
               break;
            end
            for j=i:n
                if mod(n-i, 2)==1
                    block(j, n+i-j) = list{idx}(q);
                else
                    block(n+i-j, j) = list{idx}(q); 
                end
                q=q+1;
                if list{idx}(q)==-1000
                   break;
                end
            end
            if list{idx}(q)==-1000
                break;
            end
        end
        
        % updating current block into blocks list
        blocks{idx} = block;
    end
end