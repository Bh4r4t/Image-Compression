% Encoder based on Huffman Encoding
function [trees, codes_list] = Encoder(pixels, probs, lists)
    trees = cell(1, length(pixels));
    codes_list = cell(1, length(pixels));
    for idx=1:length(pixels)
        % huffman tree for one block
       for i=1:length(pixels{idx})
          tree{i} = pixels{idx}(i); 
       end
       
       %huffman coding
       while length(tree)-2>0
          [probs{idx}, indices] = sort(probs{idx});
          tree = tree(indices);
          tree{2} = {tree{1}, tree{2}};
          tree(1) = [];
          probs{idx}(2) = probs{idx}(1)+probs{idx}(2);
          probs{idx}(1) = [];
       end
       trees{idx} = tree;
       code_dict = containers.Map((1000), ([1000, 2, 7]));
       code_dict = getCode(tree, [], code_dict);
       remove(code_dict, 1000);
       for i=1:length(lists{idx})-1
            codes_list{idx} = [codes_list{idx} code_dict(lists{idx}(i))];
       end
       
    end
end

% returns the code of particular value
% based on the huffman tree formed
function code_dict = getCode(tree, str, code_dict)
    if isa(tree, 'cell')
        % right path is labeled 1
        code_dict = getCode(tree{1}, [str, 0], code_dict);
        % left path is labeled 0
        code_dict = getCode(tree{2}, [str, 1], code_dict);
    else
        code_dict(tree) = str;
    end
end

% packing blocks(traversing in zigzag pattern) to list
function list = for_zigzag(blocks, n)
    list = cell(1, length(blocks));
    for q=1:length(blocks)
        str = zeros(1, n*n, 'double');
        idx=1;
        % first half block
        for i=1:n
            for j=1:i
               if mod(i, 2)==1
                   str(idx) = blocks{q}(i+1-j, j);
               else
                   str(idx) = blocks{q}(j, i+1-j);
               end
               idx=idx+1;
            end
        end
        
        % second half block
        for i=2:n
            for j=i:n
                if mod(n-i, 2)==1
                    str(idx) = blocks{q}(j, n+i-j);
                else
                    str(idx) = blocks{q}(n+i-j, j);
                end
                idx=idx+1;
            end
        end
        
        % marking the last non zero index
        idx = find(str, 1, 'last');
        if isempty(idx)
            idx=0;
        end
        str(idx+1) = -1000;
        list{q} = str(1:idx+1);
        
    end
end