clc;
clear all;
close all;

function App
    % 創建應用程式畫面
    fig = figure('Name', 'S11059003_Fianl_Project', ...
                 'Position', [300, 100, 900, 600]);

    % 全域資料(輸入、輸出、檔名、圖片詳細資料)
    data = struct('original_images', [], 'processed_images', [], 'images_name', [], ...
                  'images_info', []);
    setappdata(fig, 'appData', data);

    % ========== [初始頁面] ==========
    panel_main = uipanel('Parent', fig, 'Units', 'normalized', ...
                         'Position', [0, 0, 1, 1], 'Title', 'Main Panel');

    % 定義Main panel相關常數
    main_interval = 0.07;
    main_interval_y = main_interval * 2/3;

    main_axes_w = (1 - 4*main_interval) / 3;
    main_axes_h = (1 - 8*main_interval_y) / 2;

    main_tx_size = 14;

    % Input axes
    for i = 1:3
        in_x = main_interval + (i-1)*(main_axes_w + main_interval);
        in_y = 1 - main_interval_y - main_axes_h;
        axes_input(i) = axes('Parent', panel_main, 'Units', 'normalized', ...
                             'Position', [in_x, in_y, main_axes_w, main_axes_h]);
        title(axes_input(i), "Input" + num2str(i), 'FontSize', main_tx_size);
    end

    % Output axes
    for i = 1:3
        out_x = main_interval + (i-1)*(main_axes_w + main_interval);
        out_y = 1 - 2 * (1.5*main_interval_y+main_axes_h);
        axes_output(i) = axes('Parent', panel_main, 'Units', 'normalized', ...
                              'Position', [out_x, out_y, main_axes_w, main_axes_h]);
        title(axes_output(i), "Output" + num2str(i), 'FontSize', main_tx_size);
    end

    % Upload與Process按鈕
    main_btn_w = main_axes_w;
    main_btn_h = 3*main_interval_y;
    main_btn_x = main_interval;
    main_btn_y = 1 - 4*main_interval_y - 2*main_axes_h - main_btn_h;
    main_btn_tx_size = 12;

    uicontrol('Parent', panel_main, 'Style', 'pushbutton', 'Units', 'normalized', ...
              'Position', [main_btn_x, main_btn_y, main_btn_w, main_btn_h], ...
              'String', 'Upload', 'FontSize', main_btn_tx_size, 'FontWeight', 'bold', ...
              'ForegroundColor', 'k', 'BackgroundColor', 'w', 'Callback', @Upload_Image);

    uicontrol('Parent', panel_main, 'Style', 'pushbutton', 'Units', 'normalized', ...
              'Position', [2*main_btn_x+main_btn_w, main_btn_y, main_btn_w, main_btn_h], ...
              'String', 'Process', 'FontSize', main_btn_tx_size, 'FontWeight', 'bold', ...
              'ForegroundColor', 'k', 'BackgroundColor', 'w', 'Callback', @Process_Images);

    uicontrol('Parent', panel_main, 'Style', 'pushbutton', 'Units', 'normalized', ...
              'Position', [3*main_btn_x+2*main_btn_w, main_btn_y, main_btn_w, main_btn_h], ...
              'String', 'Document', 'FontSize', main_btn_tx_size, 'FontWeight', 'bold', ...
              'ForegroundColor', 'k', 'BackgroundColor', 'w', 'Callback', @Show_Document_Panel);

    % ========== [文件頁面] ==========
    panel_doc = uipanel('Parent', fig, 'Units', 'normalized', ...
                         'Position', [0, 0, 1, 1], 'Title', 'Document Panel', ...
                         'Visible', 'off');

    % 定義Document panel相關常數
    doc_tx_x = 0.025;
    doc_tx_y = 0.05;
    doc_tx_w = 1 - doc_tx_y;
    doc_tx_h = 1- 2 * doc_tx_y;
    doc_tx_size = 30;

    doc_btn_w = 0.4;
    doc_btn_h = doc_btn_w / 3;
    doc_btn_x = (1 - doc_btn_w) / 2;
    doc_btn_y = doc_tx_y;
    doc_btn_tx_size = 14;

    % 圖片1-3的描述
    doc = uicontrol('Parent', panel_doc, 'Style', 'text', ...
              'String', "It isn't processing yet!", 'Units', 'normalized', ...
              'Position', [doc_tx_x, doc_tx_y, doc_tx_w, doc_tx_h], ...
              'FontSize', doc_tx_size, 'FontWeight', 'bold', 'FontName', 'Courier New', ...
              'HorizontalAlignment', 'left', 'Max', 10, 'Min', 1, 'Enable', 'inactive');

    % 返回按鈕
    uicontrol('Parent', panel_doc, 'Style', 'pushbutton', 'Units', 'normalized', ...
          'Position', [doc_btn_x, doc_btn_y, doc_btn_w, doc_btn_h], ...
          'String', 'Back', 'FontSize', doc_btn_tx_size, 'FontWeight', 'bold', ...
          'Callback', @Show_Main_Panel);

    % ========== [函數區域] ==========
    % 上傳影像
    function Upload_Image(~, ~)
        [filenames, pathname] = uigetfile({'*.jpg; *.png', '影像檔案'}, 'Choose 3 images', ...
                                            'MultiSelect', 'on');

        % 阻擋關掉選擇框 + 不等於3個圖片的選擇
        if isequal(filenames, 0) || isequal(pathname, 0) || length(filenames) ~= 3
            return;
        end

        % 定義圖片數量、儲存輸入、輸出圖片
        image_count = 3;
        data.original_images = cell(1, image_count);
        data.processed_images = cell(1, image_count);
        data.images_name = cell(1, image_count);
        data.images_info = cell(1, image_count);
        
        for i = 1:length(filenames)
            fullPath = fullfile(pathname, filenames{i});
            img = imread(fullPath);
            data.original_images{i} = img;
            data.images_name{i} = filenames{i};
            data.images_info{i} = imfinfo(fullPath);
            axes(axes_input(i));
            imshow(img);
            title(axes_input(i), "Input" + num2str(i), 'FontSize', main_tx_size);
        end
        setappdata(fig, 'appData', data);
    end

    % 切換到初始頁面
    function Show_Main_Panel(~, ~)
        set(panel_doc, 'Visible', 'off');
        set(panel_main, 'Visible', 'on');
    end

    % 切換到文件頁面
    function Show_Document_Panel(~, ~)
        set(panel_main, 'Visible', 'off');
        set(panel_doc, 'Visible', 'on');
    end

    % 處理影像
    function Process_Images(~, ~)
        temp = getappdata(fig, 'appData');
        % 如果沒有輸入圖片，不做處理
        if isempty(temp.original_images)
            return;
        end

        for i = 1:3
            img = data.original_images{i};
    
            % 圖像特性分析模塊
            info = temp.images_info{i};
    
            % 圖像特性分析模塊 - 灰階/RGB圖片
            switch info.ColorType
                case 'truecolor'
                    if size(img, 3) == 3
                        color_type = 'Color(RGB)';
                        gray = rgb2gray(img);
                    else
                        color_type = 'Grayscale';
                        gray = squeeze(img);
                    end
                case 'grayscale'
                    color_type = 'Grayscale';
                    gray = squeeze(img);
                otherwise
                    msgbox('Invalid image color type in this program!', 'ERROR', 'error');
                    continue;
            end
    
            % 圖像特性分析模塊 - 分辨率
            resolution = [info.Width, info.Height];
    
            % 圖像特性分析模塊 - 色彩深度(bit depth)
            bit_depth = info.BitDepth;
    
            % 圖像特性分析模塊 - 對比度(Michelson Contrast)
            img_max = double(max(gray(:)));
            img_min = double(min(gray(:)));
            m_contrast = (img_max - img_min) / (img_max + img_min + eps);
            if m_contrast >= 0.7
                contrast_result = 'The contrast is high; the image has a vivid visual appearance.';
            else
                contrast_result = 'The contrast is low; overall image contrast is insufficient.';
            end
    
            % 圖像特性分析模塊 - 清晰度
            sharpness_results = {};
            sharpness_values = {};
            sharpness_names = {'Laplacian Variance', 'Edge Detection'};
    
            % 清晰度 - Laplacian Variance
            sharpness_lap = filtering("imfilter", double(gray), fspecial('laplacian'), 'replicate');
            % 計算Laplacian響應的方變異數
            sharpness = var(sharpness_lap(:));
            sharpness_values{end+1} = sharpness;
            if sharpness < 200
                sharpness_results{end+1} = 'The image has severe blur; details are heavily compromised.';
            else
                sharpness_results{end+1} = 'The image has slight blur or acceptable sharpness; details are recognizable.';
            end
    
            % 清晰度 - (Sobel)邊緣檢測法
            edges = edge(gray, 'sobel');
            edge_density = sum(edges(:)) / numel(edges);
            sharpness_values{end+1} = edge_density;
            if edge_density < 0.05
                sharpness_results{end+1} = 'Edge density is severely low; few or unclear edges are present in the image.';
            else
                sharpness_results{end+1} = 'Edge density is slightly low or acceptable; edges are recognizable in the image.';
            end
    
            % 問題診斷
            % 問題診斷 - 直方圖分析
            [counts, ~] = imhist(gray, 256);        % 計算直方圖
            counts = counts / sum(counts);          % 正規化為機率分布
            std_intensity = std(double(gray(:)));   % 計算亮度標準差
            mean_intensity = mean(gray(:));         % 計算平均亮度
            total_pixels = numel(gray);             % 計算總像素數
    
            % 問題診斷 - 噪聲診斷
            detected_noises = {};

            % 噪聲診斷 - 高斯躁聲
            % 診斷方法: 分析局部方差分布的均勻性和整體亮度標準差
            % 為什麼這樣診斷: 高斯噪聲特徵是加法性、零均值、方差恆定
            if std_intensity > 15 % 整體變異必須足夠大才可能有噪聲
                % 計算局部區域的方差分布
                local_var = stdfilt(double(gray), ones(5)); % 計算每個像素鄰域的標準差
                local_var_mean = mean(local_var(:));        % 局部方差的平均值
                local_var_std = std(local_var(:));          % 局部方差的標準差
                % 高斯噪聲有高的局部方差均值 + 局部方差分佈均勻
                if local_var_mean > 15 && local_var_std / local_var_mean < 1.0
                    detected_noises{end+1} = 'Gaussian Noise';
                end
            end
    
            % 噪聲診斷 - 松柏躁聲
            % 診斷方法: 檢查噪聲是否與訊號強度成正比
            % 為什麼這樣診斷: Poisson噪聲是訊號依賴的，方差等於均值
            intensity_ratio = sum(gray(:)) / (total_pixels * 255); % 整體亮度比例
            intensity_var = var(double(gray(:)));                  % 整體亮度方差
            % Poisson噪聲通常在低光照條件下更明顯
            if intensity_ratio < 0.6 && intensity_var > 5
                % 分析暗區和亮區的噪聲分佈特性
                dark_region = gray < mean_intensity * 0.7;   % 定義暗區
                bright_region = gray > mean_intensity * 1.3; % 定義亮區
                % 確保有足夠的暗區和亮區進行分析
                if sum(dark_region(:)) > total_pixels * 0.1 && sum(bright_region(:)) > total_pixels * 0.1
                    dark_var = var(double(gray(dark_region)));       % 暗區方差
                    bright_var = var(double(gray(bright_region)));   % 亮區方差
                    dark_mean = mean(double(gray(dark_region)));     % 暗區均值
                    bright_mean = mean(double(gray(bright_region))); % 亮區均值
                    % Poisson噪聲的特徵: 方差與均值成正比
                    dark_ratio = dark_var / (dark_mean + eps);
                    bright_ratio = bright_var / (bright_mean + eps);
                    % 檢查暗區和亮區的方差/均值比率是否接近
                    if abs(dark_ratio - bright_ratio) < 0.5 && dark_ratio > 0.1
                        detected_noises{end+1} = 'Poisson Noise';
                    end
                end
            end
    
            % 噪聲診斷 - 椒鹽躁聲
            % 診斷方法: 檢測極值像素和中值濾波後的差異
            % 為什麼這樣診斷: 椒鹽噪聲表現為孤立的極黑或極白像素
            % 計算極值像素比例
            very_dark = sum(gray(:) < 5) / total_pixels;     % 極暗像素比例
            very_bright = sum(gray(:) > 250) / total_pixels; % 極亮像素比例
            extreme_pixel_ratio = very_dark + very_bright;   % 總極值像素比例
            if extreme_pixel_ratio > 0.003 % 極值像素比例閾值
                % 使用中值濾波器檢測突變點
                kernel = 3;
                med_filtered = filtering("medfilt2", gray, [kernel kernel]); % 3x3中值濾波
                diff_img = abs(double(gray) - double(med_filtered));         % 計算差異
                significant_diffs = sum(diff_img(:) > 40) / total_pixels;    % 顯著差異比例
                % 椒鹽噪聲在中值濾波後會有明顯差異
                if significant_diffs > 0.005 && significant_diffs < 0.2
                    detected_noises{end+1} = 'Salt & Pepper Noise';
                end
            end
    
            % 噪聲診斷 - 斑點躁聲
            % 診斷方法: 檢查噪聲是否為乘法性(與像素強度成比例)
            % 為什麼這樣診斷: 斑點噪聲是乘法噪聲，標準化後各區域應有相似特徵
            if std_intensity > 15
                % 定義中等亮度和高亮度區域
                mid_areas = gray >= mean_intensity * 0.7 & gray <= mean_intensity * 1.3;
                bright_areas = gray > mean_intensity * 1.3;
                % 確保有足夠的像素進行分析
                if sum(mid_areas(:)) > total_pixels * 0.1 && sum(bright_areas(:)) > total_pixels * 0.1
                    mid_var = var(double(gray(mid_areas)));         % 中等亮度區域方差
                    bright_var = var(double(gray(bright_areas)));   % 高亮度區域方差
                    mid_mean = mean(double(gray(mid_areas)));       % 中等亮度區域均值
                    bright_mean = mean(double(gray(bright_areas))); % 高亮度區域均值
                    % 標準化方差以檢查與亮度成比例的噪聲
                    mid_norm_var = mid_var / (mid_mean^2 + eps);
                    bright_norm_var = bright_var / (bright_mean^2 + eps);
                    % 斑點噪聲在標準化後各區域應有相似的值
                    if abs(mid_norm_var - bright_norm_var) < 0.3 && mid_norm_var > 0.001
                        detected_noises{end+1} = 'Speckle Noise';
                    end
                end
            end
    
            % 噪聲診斷 - Localvar躁聲
            % 診斷方法: 分析不同強度級別的局部方差變化
            % 為什麼這樣診斷: Localvar噪聲的特點是噪聲強度與訊號強度高度相關
            block_std = stdfilt(double(gray), ones(5)); % 計算局部標準差
            % 將圖像分為多個強度區間進行分析
            intensity_levels = 4;
            level_var = zeros(intensity_levels, 1);  % 各強度級別的方差
            level_count = zeros(intensity_levels, 1); % 各強度級別的像素數
            for level = 1:intensity_levels
                lower = (level-1) * 255/intensity_levels; % 下界
                upper = level * 255/intensity_levels;     % 上界
                level_mask = gray >= lower & gray < upper; % 該級別的像素遮罩
                % 確保該級別有足夠的像素
                if sum(level_mask(:)) > total_pixels * 0.05
                    level_var(level) = mean(block_std(level_mask)); % 該級別的平均局部標準差
                    level_count(level) = sum(level_mask(:));        % 該級別的像素數
                end
            end
            % 計算有效強度級別間的方差比例
            valid_levels = level_count > 0;
            if sum(valid_levels) >= 2
                valid_vars = level_var(valid_levels);
                max_var_ratio = max(valid_vars) / (min(valid_vars) + eps);
                % Localvar噪聲的特點是噪聲強度與訊號強度高度相關
                if max_var_ratio > 1.5 && max_var_ratio < 5
                    detected_noises{end+1} = 'Localvar Noise';
                end
            end
    
            % 噪聲診斷 - 診斷結果
            if isempty(detected_noises)
                noise_summary = sprintf('Detected 0 types. No obvious noise detected.\n');
            else
                noise_summary = sprintf('Detected %d types:\n', length(detected_noises));
                for j = 1:length(detected_noises)
                    noise_summary = [noise_summary, sprintf('   %d. %s\n', j, detected_noises{j})];
                end
            end
    
            % 模糊檢測
            detected_blur = {};

            % 模糊檢測 - Laplacian模糊檢測
            % 診斷方法: 使用Laplacian算子檢測圖像銳利度，提高敏感度
            % 為什麼這樣診斷: Laplacian算子對圖像的二階導數敏感，模糊圖像響應弱
            sharpness_lap = filtering("imfilter", double(gray), fspecial('laplacian'), 'replicate');
            sharpness = var(sharpness_lap(:));
            if sharpness < 200      % 判斷一致
                detected_blur{end+1} = 'Laplacian-based blur';
            end

            % 模糊檢測 - 邊緣模糊檢測
            % 診斷方法: 使用Sobel邊緣檢測，提高敏感度
            % 為什麼這樣診斷: 模糊會減少可檢測的邊緣數量
            edges = edge(gray, 'sobel');
            edge_density = sum(edges(:)) / numel(edges);
            if edge_density < 0.05  % 判斷一致
                detected_blur{end+1} = 'Edge-based blur';
            end

            % 模糊檢測 - 運動模糊檢測
            % 診斷方法: 檢測水平和垂直邊緣密度的不平衡
            % 為什麼這樣診斷: 運動模糊通常在某個方向上更明顯
            if sharpness > 10 && edge_density > 0.005
                h_edges = edge(gray, 'sobel', [], 'horizontal'); % 水平邊緣
                v_edges = edge(gray, 'sobel', [], 'vertical');   % 垂直邊緣
                h_count = sum(h_edges(:));                       % 水平邊緣數量
                v_count = sum(v_edges(:));                       % 垂直邊緣數量
                edge_ratio = max(h_count, v_count) / (min(h_count, v_count) + eps);
                % 邊緣密度不平衡表示可能有運動模糊
                if edge_ratio > 1.5 || edge_ratio < 0.67
                    detected_blur{end+1} = 'Motion blur';
                end
            end
    
            % 模糊檢測 - 診斷結果
            if isempty(detected_blur)
                blur_summary = sprintf('Detected 0 types. No obvious blur detected.\n');
            else
                blur_summary = sprintf('Detected %d types:\n', length(detected_blur));
                for j = 1:length(detected_blur)
                    blur_summary = [blur_summary, sprintf('   %d. %s\n', j, detected_blur{j})];
                end
            end
    
            % 光線問題診斷
            lighting_issues = {};
    
            % 光線問題診斷 - 過度曝光
            % 診斷方法: 分析直方圖高亮度區域和平均亮度
            % 為什麼這樣診斷: 過度曝光表現為大量像素集中在高亮度區域
            over_exp_ratio = sum(counts(230:end)); % 高亮度像素比例
            if over_exp_ratio > 0.25 || (over_exp_ratio > 0.15 && mean_intensity > 200)
                lighting_issues{end+1} = 'Over exposure';
            end
    
            % 光線問題診斷 - 曝光不足
            % 診斷方法: 分析直方圖低亮度區域和平均亮度
            % 為什麼這樣診斷: 曝光不足表現為大量像素集中在低亮度區域
            under_exp_ratio = sum(counts(1:25));    % 低亮度像素比例
            if under_exp_ratio > 0.25 || (under_exp_ratio > 0.15 && mean_intensity < 50)
                lighting_issues{end+1} = 'Under exposure';
            end
    
            % 光線問題診斷 - 對比度不足
            % 診斷方法: 使用之前計算的Michelson對比度
            % 為什麼這樣診斷: 低對比度影響圖像細節的可見性
            if m_contrast < 0.4
                lighting_issues{end+1} = 'Low contrast';
            end

            % 光線問題診斷 - 光照不均---------
            % 診斷方法: 將圖像分割成區塊，分析各區塊間的亮度差異
            % 為什麼這樣診斷: 不均勻光照會造成區域間顯著的亮度差異
            blocks_h = 4;  % 水平方向區塊數
            blocks_w = 4;  % 垂直方向區塊數
            block_height = floor(size(gray, 1) / blocks_h);  % 每個區塊的高度
            block_width = floor(size(gray, 2) / blocks_w);   % 每個區塊的寬度
            block_means = zeros(blocks_h, blocks_w);         % 存儲各區塊的平均亮度
            % 計算各區塊的平均亮度
            for y = 0:blocks_h-1
                for x = 0:blocks_w-1
                    % 提取當前區塊
                    block = gray(y*block_height+1:min((y+1)*block_height, size(gray, 1)), ...
                                 x*block_width+1:min((x+1)*block_width, size(gray, 2)));
                    block_means(y+1, x+1) = mean(block(:)); % 計算區塊平均亮度
                end
            end
            
            % 計算區塊間亮度差異的統計指標
            block_var = var(block_means(:));                              % 區塊亮度方差
            block_range = max(block_means(:)) - min(block_means(:));      % 亮度範圍
            block_rel_range = block_range / (mean(block_means(:)) + eps); % 相對範圍
            
            % 判斷是否為不均勻光照
            if (block_range > 80 && block_rel_range > 0.5) || block_var > 600
                % 檢查是否是自然場景中的正常光照變化
                adjacent_diffs = 0; % 相鄰區塊差異總和
                count_diffs = 0;    % 相鄰區塊對數
                % 計算相鄰區塊的平均差異
                for y = 1:blocks_h
                    for x = 1:blocks_w
                        if x < blocks_w % 水平相鄰
                            adjacent_diffs = adjacent_diffs + abs(block_means(y,x) - block_means(y,x+1));
                            count_diffs = count_diffs + 1;
                        end
                        if y < blocks_h % 垂直相鄰
                            adjacent_diffs = adjacent_diffs + abs(block_means(y,x) - block_means(y+1,x));
                            count_diffs = count_diffs + 1;
                        end
                    end
                end
                avg_adjacent_diff = adjacent_diffs / count_diffs;
                % 相鄰區塊差異大表示不均勻光照，而不是自然場景的正常過渡
                if (avg_adjacent_diff > 35 || block_var > 1200) && block_range > 120
                    lighting_issues{end+1} = 'Non-uniform lighting';
                end
            end
            % 光線問題診斷 - 光照不均end---------

            % 光線問題診斷 - 診斷結果
            if isempty(lighting_issues)
                lighting_summary = sprintf('Detected 0 types. No obvious lighting issues detected.\n');
            else
                lighting_summary = sprintf('Detected %d types:\n', length(lighting_issues));
                for j = 1:length(lighting_issues)
                    lighting_summary = [lighting_summary, sprintf('   %d. %s\n', j, lighting_issues{j})];
                end
            end
    
            % 問題診斷 - 色彩問題診斷
            detected_color = {};
        
            % 判斷是否為彩色圖像，灰階/二值圖片不適用色彩問題診斷
            if isequal(color_type, 'Color(RGB)')
                % 提取RGB三個通道的數值，轉換為double型便於計算，double範圍更大，避免運算溢出
                r = double(img(:,:,1));  % 紅色通道
                g = double(img(:,:,2));  % 綠色通道  
                b = double(img(:,:,3));  % 藍色通道
                % 計算各通道的統計特徵
                % 平均值反映該通道的整體亮度水平
                avg_r = mean(r(:));      % 紅色通道平均值
                avg_g = mean(g(:));      % 綠色通道平均值
                avg_b = mean(b(:));      % 藍色通道平均值
                % 標準差反映該通道的變異程度，標準差小表示顏色變化少
                std_r = std(r(:));       % 紅色通道標準差
                std_g = std(g(:));       % 綠色通道標準差
                std_b = std(b(:));       % 藍色通道標準差
                % 將統計數據組織成向量便於後續處理
                color_std = [std_r, std_g, std_b];    % 標準差向量
                color_avg = [avg_r, avg_g, avg_b];    % 平均值向量
                
                % 色彩問題診斷 - 色彩單調
                % 診斷方法: 當各通道標準差都很小時，表示色彩變化少，畫面單調
                % 為什麼這樣診斷: 標準差反映數據分散程度，標準差小表示像素值集中
                if all(color_std < 25) && mean(color_std) < 18
                    detected_color{end+1} = 'Low color variation';
                end
                
                % 色彩問題診斷 - 色偏
                % 診斷方法: 當某個顏色通道明顯偏高或偏低時，會產生色偏現象
                % 為什麼這樣診斷: 正常圖像的RGB三通道應該相對平衡
                % 計算通道之間的最大差異值
                max_channel_diff = max([abs(avg_r - avg_g), abs(avg_r - avg_b), abs(avg_g - avg_b)]);
                % 找出數值最大的通道(主導色彩通道)
                [~, dominant_idx] = max(color_avg);
                channel_names = {'Red', 'Green', 'Blue'};  % 通道名稱對應
                % 計算各通道相對於整體平均值的比例
                channel_ratios = zeros(1,3);   % 初始化比例數組
                avg_all = mean(color_avg);     % 計算三通道的總平均值
                for c = 1:3
                    % 計算每個通道相對於總平均值的比例
                    channel_ratios(c) = color_avg(c) / (avg_all + eps); % 防止分母為零
                end
                max_ratio = max(channel_ratios);  % 找出最大比例值
                if max_channel_diff > 15 && max_ratio > 1.15
                    detected_color{end+1} = [channel_names{dominant_idx} ' color cast'];
                end
                
                % 色彩問題診斷 - 色彩飽和度
                % 診斷方法: 飽和度反映色彩的純度，過高或過低都會影響視覺效果
                % 為什麼這樣診斷: 飽和度可通過RGB的最大最小值差異來近似計算
                max_rgb = max(max(r, g), b);    % 計算每個像素的最大RGB值
                min_rgb = min(min(r, g), b);    % 計算每個像素的最小RGB值  
                % 計算近似飽和度: (max-min)/(max+eps)
                % 飽和度定義為色彩純度，max-min反映色彩強度差異
                saturation_approx = (max_rgb - min_rgb) ./ (max_rgb + eps);
                % 計算飽和度的統計特徵
                avg_sat = mean(saturation_approx(:));   % 平均飽和度
                std_sat = std(saturation_approx(:));    % 飽和度標準差
                % 低飽和度判斷: 平均飽和度<0.2表示色彩較灰暗(不足)
                if avg_sat < 0.2
                    detected_color{end+1} = 'Low saturation';
                % 高飽和度表示色彩變化大，標準差避免誤判整體高飽和度但均勻的正常圖像
                elseif avg_sat > 0.75 && std_sat > 0.2
                    detected_color{end+1} = 'High saturation';
                end

                % 色彩問題診斷 - 診斷結果
                if isempty(detected_color)
                    color_summary = sprintf('Detected 0 types. No obvious color problems detected.\n');
                else
                    color_summary = sprintf('Detected %d types:\n', length(detected_color));
                    for j = 1:length(detected_color)
                        color_summary = [color_summary, sprintf('   %d. %s\n', j, detected_color{j})];
                    end
                end
            else
                color_summary = sprintf('Not applicable (Grayscale image).\n');
            end

            % GUI文件頁面輸出紀錄
            gui_title = sprintf('(%d)%s:\n   Color type:%s\n   Problem analysis:\n    ', i, temp.images_name{i}, color_type);
            all_problems = [detected_noises, detected_blur, lighting_issues, detected_color];
            if i == 1
                gui_summary = [gui_title, strjoin(all_problems, ', '), sprintf('\n\n')];
            else
                gui_summary = [gui_summary, gui_title, strjoin(all_problems, ', '), sprintf('\n\n')];
            end

            if i == length(temp.images_name)
                set(doc, 'String', gui_summary, 'FontSize', 12);
            end
    
            % 圖像特性分析模塊 + 問題診斷儲存報告
            report_name = ['S11059003' char(i + 64) '.txt'];
            fid = fopen(report_name, 'w');
            fprintf(fid, 'Image analysis report - %s\n\n', temp.images_name{i});
            
            fprintf(fid, '=== Image Characteristics ===\n');
            fprintf(fid, ' - Type: %s\n', color_type);
            fprintf(fid, ' - Resolution: %d x %d\n', resolution(1), resolution(2));
            fprintf(fid, ' - Bit Depth: %s-bit\n', num2str(bit_depth));
            fprintf(fid, ' - Michelson Contrast(ratio) Analysis: %.2f. %s\n', m_contrast, contrast_result);
            fprintf(fid, ' - Sharpness Analysis:\n');
            for j = 1:length(sharpness_names)
                fprintf(fid, '   %d. %s: %.2f (%s)\n', j, sharpness_names{j}, sharpness_values{j}, sharpness_results{j});
            end
            
            fprintf(fid, '\n=== Image Problem Detection ===\n');
            fprintf(fid, ' - Noise Detection: %s\n', noise_summary(1:end-1));
            fprintf(fid, ' - Blur Detection: %s\n', blur_summary(1:end-1));
            fprintf(fid, ' - Lighting Issues: %s\n', lighting_summary(1:end-1));
            fprintf(fid, ' - Color Issues: %s\n', color_summary(1:end-1));

            % 處理說明
            fprintf(fid, '\n=== Image Problem Solutions ===\n');
            result = double(img);
            count = 0;

            % 處理方法測試工具
            % detected_noises = {};
            % detected_blur = {};
            % lighting_issues = {};
            % detected_color = {};
            % 
            % detected_noises{end+1} = 'Gaussian Noise';
            % detected_noises{end+1} = 'Poisson Noise';
            % detected_noises{end+1} = 'Salt & Pepper Noise';
            % detected_noises{end+1} = 'Speckle Noise';
            % detected_noises{end+1} = 'Localvar Noise';
            % 
            % detected_blur{end+1} = 'Laplacian-based blur';
            % detected_blur{end+1} = 'Edge-based blur';
            % detected_blur{end+1} = 'Motion blur';
            % 
            % lighting_issues{end+1} = 'Over exposure';
            % lighting_issues{end+1} = 'Under exposure';
            % lighting_issues{end+1} = 'Low contrast';
            % lighting_issues{end+1} = 'Non-uniform lighting';
            % 
            % detected_color{end+1} = 'Low color variation';
            % detected_color{end+1} = 'Red color cast';
            % detected_color{end+1} = 'Low saturation';
            % detected_color{end+1} = 'High saturation';
            
            % 判斷圖片背景類型(白底或暗底)
            % 計算背景亮度特徵
            background_brightness = mean(gray(:));  % 整體平均亮度
            bg_std = std(double(gray(:)));          % 亮度標準差

            % 白底判斷條件:
            % 1. 平均亮度>160 (較亮)
            % 2. 標準差<60 (變化不大，背景相對均勻)  
            % 3. 亮像素(>200)比例>30% (大部分區域較亮)
            is_white_background = background_brightness > 160 && bg_std < 60 && sum(gray(:) > 200) > numel(gray) * 0.3;
            
            % 文字區域檢測 - 識別圖像中的文字區域，用於保護文字不被過度處理
            if is_white_background
                % 白底情況: 檢測黑色文字區域，確保只選取明顯暗於背景的像素
                text_mask = gray < (background_brightness * 0.4);
            else
                % 暗底情況: 檢測亮色文字區域，確保只選取明顯亮於背景的像素
                text_mask = gray > (background_brightness * 1.8);
            end
            % 計算文字區域占圖像的比例，判斷圖像中文字的密度，決定處理策略的保守程度
            text_area_ratio = sum(text_mask(:)) / numel(text_mask);

            % 處理說明 - 高斯躁聲
            % 處理方法: 高斯濾波器
            % 為什麼這樣處理: 高斯濾波器能有效去除高斯噪聲，保持邊緣相對清晰
            if ismember('Gaussian Noise', detected_noises)
                kernel = 3;
                if is_white_background && text_area_ratio > 0.05
                    % 白底有文字：使用極保守的高斯濾波，避免破壞文字
                    sigma = 0.2;
                elseif ~is_white_background && text_area_ratio > 0.02
                    % 暗底有文字：使用更保守的參數
                    sigma = 0.15;
                else
                    % 無明顯文字：可以使用稍強的去噪
                    sigma = 1.2;
                end
                result = filtering("imfilter", result, fspecial('gaussian', [kernel kernel], sigma), 'replicate');
                count = count + 1;
                fprintf(fid, "%d.處理方法: Gaussian Filter - 去除高斯噪聲\n", count);
                fprintf(fid, "  函式: imfilter(A, fspecial('gaussian', [m n], sigma), 'replicate')\n");
                fprintf(fid, "  參數: A = 輸入影像, [m n] = 濾波視窗大小, sigma = 標準差\n");
            end
            
            % 處理說明 - 松柏躁聲 + 斑點躁聲 + Localvar躁聲
            % 處理方法: 高斯濾波器/中值濾波器
            % 為什麼這樣處理: 這三種噪聲都是訊號相關噪聲，處理方法相似
            noise_types = {'Poisson Noise', 'Speckle Noise', 'Localvar Noise'};
            noise_show = {'去除松柏躁聲', '去除斑點噪聲', '去除Localvar局部變異噪聲'};
            for j = 1:length(noise_types)
                if ismember(noise_types{j}, detected_noises)
                    kernel = 3;
                    sigma = 0.1;
                    if is_white_background && text_area_ratio > 0.05
                        % 白底文字: 僅在非文字區域輕微處理
                        % 分通道處理，保護文字區域
                        for k = 1:size(result, 3)
                            non_text_mask = ~text_mask;  % 非文字區域遮罩
                            if sum(non_text_mask(:)) > 0
                                % 只對非文字區域應用高斯濾波
                                temp_result = filtering("imfilter", result(:,:,k), fspecial('gaussian', [kernel kernel], sigma), 'replicate');
                                % 合併處理結果: 文字區域保持原樣，非文字區域使用濾波後的結果
                                result(:,:,k) = result(:,:,k) .* double(text_mask) + temp_result .* double(non_text_mask);
                            end
                        end
                    elseif ~is_white_background
                        % 暗底: 使用極保守的中值濾波，保護邊緣
                        result = filtering("medfilt2", result, [kernel kernel], '');
                    end
                    count = count + 1;
                    fprintf(fid, "%d.處理方法: Gaussian Filter/Median filter - %s\n", count, noise_show{j});
                    fprintf(fid, "  函式: imfilter(A, fspecial('gaussian', [m n], sigma), 'replicate')/medfilt2(A, kernel)\n");
                    fprintf(fid, "  參數: A = 輸入影像, [m n]/kernel = 濾波視窗大小, sigma = 標準差\n");
                end
            end
            
            % 處理說明 - 椒鹽躁聲
            % 處理方法: 形態學方法
            % 為什麼這樣處理: 椒鹽噪聲是脈衝噪聲，需要識別並移除孤立的噪聲點
            if ismember('Salt & Pepper Noise', detected_noises)
                se = strel('disk', 1);    % 創建小圓盤結構元素
                se_check = strel('disk', 2);  % 檢查用的較大結構元素
                if is_white_background
                    % 白底: 僅處理明顯的黑色噪聲點，避免誤判文字  
                    for j = 1:size(result,3)
                        % 檢測極黑像素(幾乎全黑)
                        very_dark_mask = result(:,:,j) < 8;
                        % Erode檢查周圍環境是否為白色(>180)，確認為孤立噪聲點
                        surrounding_white = filtering("imerode", double(result(:,:,j) > 180), se_check, '');
                        % 只有在周圍是白色的極黑點才認為是噪聲，避免將正常的黑色文字誤判為噪聲
                        isolated_noise = very_dark_mask & surrounding_white;
                        if sum(isolated_noise(:)) > 0
                            % 使用Open去除小的黑色噪聲點，能去除小於結構元素的物體
                            opened = filtering("imopen", result(:,:,j), se, '');
                            % 選擇性替換: 只有噪聲點位置使用Open結果
                            result(:,:,j) = result(:,:,j).*double(~isolated_noise) + opened.*double(isolated_noise);
                        end
                    end
                else
                    % 暗底: 處理明顯的白色噪聲點
                    for j = 1:size(result,3)
                        % 檢測極亮像素(幾乎全白)
                        very_bright_mask = result(:,:,j) > 250;
                        % 檢查周圍是否為暗色
                        surrounding_dark = filtering("imerode", double(result(:,:,j) < 100), se_check, '');
                        % 只有在暗色背景中的極亮點才認為是噪聲
                        isolated_noise = very_bright_mask & surrounding_dark;
                        if sum(isolated_noise(:)) > 0
                            % 使用Close填補小的白色噪聲點，能填補小於結構元素的孔洞
                            closed = filtering("imclose", result(:,:,j), se, '');
                            % 選擇性替換: 只有噪聲點位置使用Close結果
                            result(:,:,j) = result(:,:,j).*double(~isolated_noise) + closed.*double(isolated_noise);
                        end
                    end
                end
                result = ensure_image_range(result);
                count = count + 1;
                fprintf(fid, "%d.處理方法: Morphological Operations - 去除椒鹽躁聲\n", count);
                fprintf(fid, "  函式: imopen(A, se), imclose(A, se), imerode(A, se)\n");
                fprintf(fid, "  參數: A = 輸入影像, se = 結構元素\n");
            end
            
            % 處理說明 - Laplacian-based blur
            % 處理方法: 形態學方法(銳化)
            % 為什麼這樣處理: 拉普拉斯模糊通常由對焦不準造成，需要輕微銳化
            if ismember('Laplacian-based blur', detected_blur)
                if is_white_background && text_area_ratio > 0.05
                    % 白底文字: 輕微連接斷裂的文字筆畫
                    se_h = strel('line', 2, 0);     % 水平線結構元素
                    se_v = strel('line', 2, 90);    % 垂直線結構元素
                    for j = 1:size(result,3)
                        text_region = double(text_mask); % 文字區域遮罩
                        if sum(text_region(:)) > 0
                            % 分別進行水平和垂直方向的Close
                            closed_h = filtering("imclose", result(:,:,j), se_h, '');
                            closed_v = filtering("imclose", result(:,:,j), se_v, '');
                            % 取較保守的結果(較小值)，避免過度處理
                            closed = min(closed_h, closed_v);
                            % 極低混合比例: 90%原圖 + 10%處理結果，避免破壞文字的原始形狀
                            result(:,:,j) = 0.9*result(:,:,j) + 0.1*closed;
                        end
                    end
                    % 暗底或無文字: 不進行處理，避免破壞
                end
                result = ensure_image_range(result);
                count = count + 1;
                fprintf(fid, "%d.處理方法: Morphological Closing - 去除Laplacian模糊\n", count);
                fprintf(fid, "  函式: imclose(A, se)\n");
                fprintf(fid, "  參數: A = 輸入影像, se = 結構元素\n");
            end
            
            % 處理說明 - Edge-based blur
            % 處理方法: Sobel+形態學方法
            % 為什麼這樣處理: 邊緣模糊影響文字清晰度，需要增強真正的文字邊緣
            if ismember('Edge-based blur', detected_blur)
                se = strel('disk', 1);  % 小圓盤結構元素
                if is_white_background && text_area_ratio > 0.05
                    % 白底文字: 僅增強真正的文字邊緣
                    for j = 1:size(result,3)
                        % 在文字區域內檢測邊緣，避免背景干擾，使用Sobel取得邊緣
                        text_edges = edge(uint8(result(:,:,j) .* double(text_mask)), 'sobel', 0.15);
                        if sum(text_edges(:)) > 0
                            % 對檢測到的文字邊緣進行輕微增強
                            closed = filtering("imclose", result(:,:,j), se, '');
                            % 將邊緣區域稍微擴展，用於混合處理
                            edge_mask = filtering("imdilate", double(text_edges), strel('disk', 1), '');
                            % 在邊緣區域輕微混合: 90%原圖 + 10%Close結果
                            result(:,:,j) = result(:,:,j) .* (1 - 0.1*edge_mask) + closed .* (0.1*edge_mask);
                        end
                    end
                else
                    % 暗底: 極保守處理
                    for j = 1:size(result,3)
                        if text_area_ratio > 0.02  % 有少量文字時才處理
                            % 使用Open去除細小雜點
                            opened = filtering("imopen", result(:,:,j), se, '');
                            % 98%原圖 + 2%開運算結果
                            result(:,:,j) = 0.98*result(:,:,j) + 0.02*opened;
                        end
                    end
                end
                result = ensure_image_range(result);
                count = count + 1;
                fprintf(fid, "%d.處理方法: Edge Enhancement - 去除邊緣模糊\n", count);
                fprintf(fid, "  函式: imclose(A, se), imopen(A, se), imdilate(A, se)\n");
                fprintf(fid, "  參數: A = 輸入影像, se = 結構元素\n");
            end
            
            % 處理說明 - Motion blur
            % 處理方法: Sobel+形態學方法
            % 為什麼這樣處理: 運動模糊有方向性，需要針對主要方向進行處理
            if ismember('Motion blur', detected_blur)
                % 重新計算當前圖像的邊緣特性(因為前面可能已經處理過)
                gray_check = mean(result, 3);  % 將彩色圖像轉為灰階以便邊緣檢測
                % 分別檢測水平和垂直邊緣
                % 水平邊緣檢測：檢測垂直方向的灰度變化(如水平線條)
                h_edges = edge(uint8(gray_check), 'sobel', 0.1, 'horizontal');
                % 垂直邊緣檢測：檢測水平方向的灰度變化(如垂直線條)
                v_edges = edge(uint8(gray_check), 'sobel', 0.1, 'vertical');
                % 統計兩個方向的邊緣點數量
                h_count = sum(h_edges(:));  % 水平邊緣總數
                v_count = sum(v_edges(:));  % 垂直邊緣總數
                % 計算邊緣比例以判定運動模糊方向
                % 如果某個方向的邊緣明顯較多，表示在該垂直方向上有運動模糊
                edge_ratio = max(h_count, v_count) / (min(h_count, v_count) + eps);
                % 只有在明顯方向性模糊且有文字時才處理
                % edge_ratio > 2.5：確保有明顯的方向性差異，避免誤判
                % text_area_ratio > 0.03：確保圖像中有足夠的文字內容值得處理
                if edge_ratio > 2.5 && text_area_ratio > 0.03
                    % 根據邊緣統計結果決定處理的主要方向
                    if h_count > v_count
                        % 水平邊緣較多，表示垂直方向有模糊，使用水平線型結構元素
                        se = strel('line', 2, 0);  % 長度2，角度0度(水平)
                    else
                        % 垂直邊緣較多，表示水平方向有模糊，使用垂直線型結構元素
                        se = strel('line', 2, 90); % 長度2，角度90度(垂直)
                    end
                    % 對每個顏色通道進行處理
                    for j = 1:size(result,3)
                        if is_white_background
                            % 白底圖像，需要連接斷裂的黑色文字筆畫
                            % 使用Close連接同方向的斷裂筆畫，可以填補小的間隔
                            closed = filtering("imclose", result(:,:,j), se, '');
                            % 計算文字區域遮罩(黑色區域為文字)
                            text_region_mask = double(text_mask);
                            
                            % 混合原圖和處理後的圖像，15%的處理結果，85%原圖
                            % 在非文字區域保持原樣，避免影響背景
                            result(:,:,j) = result(:,:,j).*(1-0.15*text_region_mask) + ...
                                           closed.*(0.15*text_region_mask);
                        else
                            % 暗底圖像，需要清理亮色文字周圍的拖影
                            % 使用Open清除細小的拖影和噪點，可以去除細小的突出部分
                            opened = filtering("imopen", result(:,:,j), se, '');
                            % 極保守的混合比例，95%原圖，5%處理結果
                            % 避免過度處理造成文字變細或消失
                            result(:,:,j) = 0.95*result(:,:,j) + 0.05*opened;
                        end
                    end
                end
                result = ensure_image_range(result);
                count = count + 1;
                fprintf(fid, "%d.處理方法: Directional Morphological Operations - 去除運動模糊\n", count);
                fprintf(fid, "  函式: imclose(A, se), imopen(A, se)\n");
                fprintf(fid, "  參數: A = 輸入影像, se = 結構元素\n");
            end
            
            % 處理說明 - Over exposure
            % 處理方法: 控制顏色通道值(類imadjust)
            % 為什麼這樣處理: 過度曝光會導致圖像細節丟失，特別是高亮區域變成純白(細節丟失)
            if ismember('Over exposure', lighting_issues)
                % 對每個顏色通道進行過曝控制
                for j = 1:size(result,3)
                    if is_white_background
                        % 白底圖像本身就應該是高亮的，只需要控制極端過曝
                        % 檢測極端過曝區域在顯示時通常沒有差別，都是純白
                        extreme_overexp = result(:,:,j) > 253;
                        % 如果存在極端過曝像素，將其限制，可以保留一些層次感
                        if sum(extreme_overexp(:)) > 0
                            result(result(:,:,j) > 253) = 250;
                        end
                    else
                        % 暗底圖像中的高亮區域可能是重要的文字或內容，檢測過曝區域
                        overexp_mask = result(:,:,j) > 240;
                        % 避免對正常的小面積高光進行不必要的處理
                        if sum(overexp_mask(:)) > numel(overexp_mask) * 0.01
                            % 保留更多層次
                            result(result(:,:,j) > 245) = 240;
                        end
                    end
                end
                result = ensure_image_range(result);
                count = count + 1;
                fprintf(fid, "%d.處理方法: Pixel Value Control - 去除過度曝光\n", count);
                fprintf(fid, "  函式: 像素值限制控制\n");
                fprintf(fid, "  參數: A = 輸入影像\n");
            end
            
            % 處理說明 - Under exposure
            % 處理方法: 控制顏色通道值(類imadjust)
            % 為什麼這樣處理: 暗底中過度的暗區(細節丟失)可能是欠曝，需要適度提升
            if ismember('Under exposure', lighting_issues)
                % 對每個顏色通道進行欠曝控制
                for j = 1:size(result,3)
                    if is_white_background
                        % 白底圖像不進行任何處理，黑色=字，保護文字的完整性
                    else
                        % 暗底圖像中過度的暗區可能影響內容的可見性
                        % 檢測極暗區域(在顯示時幾乎看不到任何細節)
                        extreme_dark = result(:,:,j) < 3;
                        % 避免對正常的小面積陰影進行不必要的處理
                        if sum(extreme_dark(:)) > numel(extreme_dark) * 0.01
                            % 極暗像素增加最低可見度
                            result(result(:,:,j) < 3) = 5;
                        end
                    end
                end
                result = ensure_image_range(result);
                count = count + 1;
                fprintf(fid, "%d.處理方法: Pixel Value Enhancement - 去除曝光不足\n", count);
                fprintf(fid, "  函式: 像素值提升控制\n");
                fprintf(fid, "  參數: A = 輸入影像\n");
            end
            
            % 處理說明 - Low contrast
            % 處理方法: 形態學方法
            % 為什麼這樣處理: 強邊緣訊息，提升文字清晰度(邊緣模糊)，根據文字區域調整增強強度
            if ismember('Low contrast', lighting_issues)
                if text_area_ratio > 0.03  % 檢查是否有足夠的文字內容
                    % 有文字，使用極保守的形態學梯度增強
                    % 小結構元素可以增強細節而不會產生明顯的處理痕跡
                    se = strel('disk', 1);
                    % 對每個顏色通道進行對比度增強
                    for j = 1:size(result,3)
                        % Dilate擴展亮區域，強化亮邊緣
                        dilated = filtering("imdilate", result(:,:,j), se, '');
                        % Erode擴展暗區域，強化暗邊緣
                        eroded = filtering("imerode", result(:,:,j), se, '');
                        % 形態學梯度：Dilate-Erode，得到邊緣
                        gradient = dilated - eroded;
                        % 根據背景類型調整增強策略
                        if is_white_background
                            % 白底圖像，文字區域需要更強的增強
                            text_region_mask = double(text_mask);
                            % 文字區域使用8%的梯度增強，背景區域使用3%
                            result(:,:,j) = result(:,:,j) + 0.08*gradient.*text_region_mask + ...
                                           0.03*gradient.*(1-text_region_mask);
                        else
                            % 暗底圖像，統一使用保守的2%增強
                            result(:,:,j) = result(:,:,j) + 0.02*gradient;
                        end
                    end
                else
                    % 無明顯文字，可以使用稍強的增強
                    % 使用稍大的結構元素進行一般性對比度增強
                    se = strel('disk', 2);
                    for j = 1:size(result,3)
                        % 計算形態學梯度
                        dilated = filtering("imdilate", result(:,:,j), se, '');
                        eroded = filtering("imerode", result(:,:,j), se, '');
                        gradient = dilated - eroded;
                        % 使用5%的梯度增強
                        result(:,:,j) = result(:,:,j) + 0.05*gradient;
                    end
                end
                result = ensure_image_range(result);
                count = count + 1;
                fprintf(fid, "%d.處理方法: Morphological Gradient - 增強低對比度\n", count);
                fprintf(fid, "  函式: imdilate(A, se), imerode(A, se)\n");
                fprintf(fid, "  參數: A = 輸入影像, se = 結構元素\n");
            end
            
            % 處理說明 - Non-uniform lighting
            % 處理方法: 形態學方法
            % 為什麼這樣處理: 通過估計背景/前景變化來計算校正量是有效的方法
            if ismember('Non-uniform lighting', lighting_issues)
                % 估計光照變化，不會過度平滑細節
                se = strel('disk', 5);
                % 對每個顏色通道進行光照校正
                for j = 1:size(result,3)
                    if is_white_background
                        % 白底圖像，估計背景亮度變化，避免影響黑色文字
                        % 使用Open估計背景亮度分布，去除小的暗色區域，保留背景變化
                        background_est = filtering("imopen", result(:,:,j), se, '');
                        % 計算平均背景亮度作為參考
                        mean_bg = mean(background_est(:));
                        % 計算校正量，目標是讓背景亮度趨於平均值，確保校正效果溫和
                        correction = 0.05*(mean_bg - double(background_est));
                        % 在非文字區域進行較強校正，文字區域極保守
                        non_text_mask = double(~text_mask);  % 非文字區域遮罩
                        % 非文字區域使用80%校正強度，文字區域只用10%
                        result(:,:,j) = result(:,:,j) + correction.*non_text_mask*0.8 + ...
                                       correction.*double(text_mask)*0.1;
                    else
                        % 暗底圖像，估計文字亮度變化，保守校正
                        % 使用Close估計前景亮度分布，填補小的暗色區域，連接亮色文字
                        foreground_est = filtering("imclose", result(:,:,j), se, '');
                        % 計算平均前景亮度
                        mean_fg = mean(foreground_est(:));
                        % 計算校正量
                        correction = 0.02*(double(foreground_est) - mean_fg);
                        % 統一應用校正
                        result(:,:,j) = result(:,:,j) + correction;
                    end
                end
                result = ensure_image_range(result);
                count = count + 1;
                fprintf(fid, "%d.處理方法: Background Estimation Correction - 校正不均勻光照\n", count);
                fprintf(fid, "  函式: imopen(A, se), imclose(A, se)\n");
                fprintf(fid, "  參數: A = 輸入影像, se = 結構元素\n");
            end
            
            % 處理說明 - 色彩單調
            % 處理方法: 形態學方法
            % 為什麼這樣處理: 形態學梯度可以增強色彩邊界，提升色彩層次感
            if ismember('Low color variation', detected_color)
                if size(result, 3) == 3
                    if text_area_ratio > 0.03  % 檢查是否有足夠的文字內容
                        % 有文字，極保守增強，避免破壞文字顏色
                        % 使用小型結構元素進行精細的色彩增強
                        se = strel('disk', 1);
                        % 對RGB三個通道分別處理
                        for j = 1:size(result, 3)  
                            % 計算形態學梯度以增強色彩邊界
                            dilated = filtering("imdilate", result(:,:,j), se, '');
                            eroded = filtering("imerode", result(:,:,j), se, '');
                            gradient = dilated - eroded;
                            % 在非文字區域稍強增強，文字區域極保守
                            non_text_mask = double(~text_mask);  % 非文字區域遮罩
                            % 非文字區域使用12%增強，文字區域只用3%
                            result(:,:,j) = result(:,:,j) + 0.12*gradient.*non_text_mask + ...
                                           0.03*gradient.*double(text_mask);
                        end
                    else
                        % 無文字，可以使用稍強的增強
                        se = strel('disk', 2);
                        for j = 1:3
                            % 計算形態學梯度
                            dilated = filtering("imdilate", result(:,:,j), se, '');
                            eroded = filtering("imerode", result(:,:,j), se, '');
                            gradient = dilated - eroded;
                            % 使用8%的統一增強
                            result(:,:,j) = result(:,:,j) + 0.08*gradient;
                        end
                    end
                end
                result = ensure_image_range(result);
                count = count + 1;
                fprintf(fid, "%d.處理方法: Morphological Color Enhancement - 校正色彩單調\n", count);
                fprintf(fid, "  函式: imdilate(A, se), imerode(A, se)\n");
                fprintf(fid, "  參數: A = 輸入影像, se = 結構元素\n");
            end
            
            % 處理說明 - 色偏
            % 處理方法: 形態學方法
            % 為什麼這樣處理: 通過估計背景色彩分布來計算校正係數是可靠的方法
            if any(contains(detected_color, 'color cast'))
                % 創建較大的結構元素用於估計整體色彩分布
                se = strel('disk', 3);
                if size(result, 3) == 3
                    % 使用Open估計各通道的背景色彩分布，去除文字等小的暗色區域，保留背景色彩訊息
                    r_bg = filtering("imopen", result(:,:,1), se, '');  % 紅色通道背景
                    g_bg = filtering("imopen", result(:,:,2), se, '');  % 綠色通道背景
                    b_bg = filtering("imopen", result(:,:,3), se, '');  % 藍色通道背景
                    % 計算各通道的平均背景亮度
                    avg_r = mean(r_bg(:));
                    avg_g = mean(g_bg(:));
                    avg_b = mean(b_bg(:));
                    avg_gray = (avg_r + avg_g + avg_b) / 3;  % 灰度平均值
                    % 計算極保守的校正係數，限制範圍，確保校正溫和
                    r_factor = min(1.02, max(0.98, avg_gray / (avg_r + eps)));
                    g_factor = min(1.02, max(0.98, avg_gray / (avg_g + eps)));  
                    b_factor = min(1.02, max(0.98, avg_gray / (avg_b + eps)));
                    % 根據是否有文字決定校正策略
                    if text_area_ratio > 0.03
                        % 有文字，在非文字區域進行較強校正
                        non_text_mask = double(~text_mask);     % 非文字區域遮罩
                        text_region_mask = double(text_mask);   % 文字區域遮罩
                        % 文字區域保持原色彩(係數=1)，非文字區域應用校正係數
                        result(:,:,1) = result(:,:,1) .* (text_region_mask + non_text_mask * r_factor);
                        result(:,:,2) = result(:,:,2) .* (text_region_mask + non_text_mask * g_factor);
                        result(:,:,3) = result(:,:,3) .* (text_region_mask + non_text_mask * b_factor);
                    else
                        % 無文字的情況：統一應用校正係數
                        result(:,:,1) = result(:,:,1) * r_factor;
                        result(:,:,2) = result(:,:,2) * g_factor;
                        result(:,:,3) = result(:,:,3) * b_factor;
                    end
                end
                result = ensure_image_range(result);
                count = count + 1;
                fprintf(fid, "%d.處理方法: Color Balance Correction - 校正色偏\n", count);
                fprintf(fid, "  函式: imopen(A, se)\n");
                fprintf(fid, "  參數: A = 輸入影像, se = 結構元素\n");
            end
            
            % 處理說明 - 低飽和度
            % 處理方法: 增強色度(類Adjust Contrast)
            % 為什麼這樣處理: 通過增強色度(chroma)可以提升飽和度而不改變亮度
            if ismember('Low saturation', detected_color)
                if size(result, 3) == 3
                    % 計算亮度luminance，使用標準的權重比例
                    luminance = 0.299*result(:,:,1) + 0.587*result(:,:,2) + 0.114*result(:,:,3);
                    % 對每個顏色通道進行飽和度增強
                    for j = 1:size(result, 3)
                        % 計算色度：顏色通道值減去亮度，表示色彩的純度，不包含亮度訊息
                        chroma = result(:,:,j) - luminance;
                        if text_area_ratio > 0.03
                            % 有文字的情況：在非文字區域較強增強，文字區域極保守
                            non_text_mask = double(~text_mask);     % 非文字區域遮罩
                            text_region_mask = double(text_mask);   % 文字區域遮罩
                            % 文字區域色度增強0.5%，非文字區域增強3%
                            enhanced_chroma = chroma .* (text_region_mask * 1.005 + non_text_mask * 1.03);
                            % 重新組合亮度和增強後的色度
                            result(:,:,j) = luminance + enhanced_chroma;
                        else
                            % 無文字的情況：統一增強2%
                            result(:,:,j) = luminance + 1.02*chroma;
                        end
                    end
                end
                result = ensure_image_range(result);
                count = count + 1;
                fprintf(fid, "%d.處理方法: Chroma Enhancement - 增強低飽和度\n", count);
                fprintf(fid, "  函式: 色度增強計算\n");
                fprintf(fid, "  參數: A = 輸入影像\n");
            end
            
            % 處理說明 - 高飽和度
            % 處理方法: 增強色度(類Adjust Contrast)
            % 為什麼這樣處理: 通過增強色度(chroma)可以降低飽和度而不改變亮度
            if ismember('High saturation', detected_color)
                if size(result, 3) == 3
                    % 計算亮度luminance，使用標準的權重比例
                    luminance = 0.299*result(:,:,1) + 0.587*result(:,:,2) + 0.114*result(:,:,3);
                    % 對每個顏色通道進行飽和度增強
                    for j = 1:size(result, 3)
                        % 計算色度：顏色通道值減去亮度，表示色彩的純度，不包含亮度訊息
                        chroma = result(:,:,j) - luminance;
                        if text_area_ratio > 0.03
                            % 有文字，保護文字色彩，僅控制背景高飽和度
                            non_text_mask = double(~text_mask);     % 非文字區域遮罩
                            text_region_mask = double(text_mask);   % 文字區域遮罩
                            % 文字區域色度降低0%，非文字區域降低8%
                            controlled_chroma = chroma .* (text_region_mask * 1.0 + non_text_mask * 0.92);
                            result(:,:,j) = luminance + controlled_chroma;
                        else
                            % 無文字的情況：統一降低4%
                            result(:,:,j) = luminance + 0.96*chroma;
                        end
                    end
                end
                result = ensure_image_range(result);
                count = count + 1;
                fprintf(fid, "%d.處理方法: Chroma Control - 控制高飽和度\n", count);
                fprintf(fid, "  函式: 色度控制計算\n");
                fprintf(fid, "  參數: A = 輸入影像\n");
            end

            % 更新影像到輸出區
            result = uint8(result);
            axes(axes_output(i));
            imshow(result);
            title(axes_output(i), "Output" + num2str(i), 'FontSize', main_tx_size);
            fclose(fid);
            imwrite(result, ['S11059003' char(i + 64) '.png']);
        end
    end

    function img = filtering(filter, in, kernel, mode)
        % filter是過濾器名稱；in是輸入圖片；kernel是濾波器視窗大小/strel()；mode是特定濾波器特殊參數
        times = size(in, 3);
        if filter == "medfilt2"
            for j = 1:times
                img(:,:,j) = medfilt2(in(:,:,j), kernel);
            end
        elseif filter == "imfilter"
            for j = 1:times
                img(:,:,j) = imfilter(in(:,:,j), kernel, mode);
            end
        elseif filter == "conv2"
            for j = 1:times
                img(:,:,j) = conv2(in(:,:,j), kernel, mode);
            end
        elseif filter == "imdilate"
            for j = 1:times
                img(:,:,j) = imdilate(in(:,:,j), kernel);
            end
        elseif filter == "imerode"
            for j = 1:times
                img(:,:,j) = imerode(in(:,:,j), kernel);
            end
        elseif filter == "imopen"
            for j = 1:times
                img(:,:,j) = imopen(in(:,:,j), kernel);
            end
        elseif filter == "imclose"
            for j = 1:times
                img(:,:,j) = imclose(in(:,:,j), kernel);
            end
        end
        img = ensure_image_range(img);
    end

    function img = ensure_image_range(in)
        img = abs(in);
        img = min(255, max(0, img));
    end
end

App();