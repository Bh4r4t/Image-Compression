function Main(fname_inp, fname_out, n, transform, toshow)
    %---------------------------------------------------------%
    %    fname_inp: input image                               %
    %    fname_out: Name of output(decompressed) image        %
    %    n: (n x n)size of quantization Table                 %
    %    transform (str): transform function                  %
    %                  either 'DCT' or 'DFT'                  %
    %    toshow (bool): To display results                    %
    %---------------------------------------------------------%

    img = imread(fname_inp);

    padded_img = padImage(img, n);
    out_img = zeros(size(padded_img), 'uint8');
    for channel=1:size(padded_img, 3)
        grey_img = padded_img(:, :, channel);
        sz = size(grey_img);
        % (compression)
        blocks = getBlocks(grey_img, n);
        blocks = shift(blocks, 128, 0);
        blocks = transformNorm(blocks, n, 0, transform);
        list_for = for_zigzag(blocks, n);
        [keys, probs] = getProbs(list_for, n);
        [trees, codes_list] = Encoder(keys, probs, list_for);
        
        % (Decompression)
        lists = Decode(codes_list, trees);
        blks1 = rev_zigzag(lists, n);
        blks = transformNorm(blks1, n, 1, transform);
        blks = shift(blks, 128, 1);
        out_img(:, :, channel) = joinBlocks(blks, n, sz);
        disp("channel "+channel + " done");
    end
    
    % save recovered image
    imwrite(out_img, (fname_out+"_"+n+".png"));
    
    if toshow
        figure();
        subplot(1,2,1);imshow(padded_img);title('Original image');
        rmse = RMSE(padded_img, out_img);
        subplot(1,2,2);imshow(out_img);title("Output image [RMSE: " + rmse + "]");
    end
end

% DCT/fft transform/inv_transform + Normalization
function blocks = transformNorm(blocks, n, inv, transform)
    %------------------------------------%
    % if inv==1 ? denormlize -> inv_DCT  %
    % else inv==0 ? DCT -> Normalize     %
    %------------------------------------%
    
    if n==8
    % size 8x8
    quant_table = [16, 11, 10, 16, 24, 40, 51, 61;
               12, 12, 14, 19, 26, 58, 60, 55;
               14, 13, 16, 24, 40, 57, 69, 56;
               14, 17, 22, 29, 51, 87, 80, 62;
               18, 22, 39, 56, 68, 109, 103, 77;
               24, 35, 55, 64, 81, 104, 113, 92;
               49, 64, 78, 87, 103, 121, 120, 101;
               72, 92, 95, 98, 112, 100, 103, 99];
           
    elseif n==7
     % size 7x7
     quant_table = [16, 11, 10, 16, 24, 40, 51;
               12, 12, 14, 19, 26, 58, 60;
               14, 17, 22, 29, 51, 87, 80;
               18, 22, 39, 56, 68, 109, 103;
               24, 35, 55, 64, 81, 104, 113;
               49, 64, 78, 87, 103, 121, 120;
               72, 92, 95, 98, 112, 100, 103];
           
    elseif n==5
     %size 5x5
     quant_table = [40, 78, 93, 117, 98;
                 167, 185, 168, 222, 138;
                 99, 177, 188, 233, 150;
                 101, 171, 30, 87, 61;
                 81, 100, 92, 230, 149];
    end
    
    if inv==0
        for i=1:length(blocks)
            %--------Transformation--------%
            if transform == 'DCT'
                % DCT
                blocks{i} = dct2(blocks{i});
            elseif transform == 'DFT'
                % DFT
                blocks{i} = real(fft2(blocks{i}));
            end
            %-----------Normalize-----------%
            blocks{i} = round(blocks{i}./quant_table);
        end 
    else
       for i=1:length(blocks)
            %------------Inverse Normalize-----------%
            blocks{i} = (blocks{i}.*quant_table);
            
            %---------Inverse Transformation---------%
            if transform == 'DCT'
                % DCT
                blocks{i} = idct2(blocks{i});
            elseif transform=='DFT'
                % IDFT
                blocks{i} = real(ifft2(blocks{i}));
            end
        end 
    end
end