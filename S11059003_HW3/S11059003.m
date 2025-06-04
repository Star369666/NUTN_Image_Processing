clc;
clear all;
close all;

function App
    % 創建應用程式畫面
    fig = figure('Name', 'S11059003_Midterm_Project', ...
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
    main_btn_w = (1 - 4*main_interval_y) / 2;
    main_btn_h = 3*main_interval_y;
    main_btn_x = main_interval;
    main_btn_y = 1 - 4*main_interval_y - 2*main_axes_h - main_btn_h;
    main_btn_tx_size = 12;

    uicontrol('Parent', panel_main, 'Style', 'pushbutton', 'Units', 'normalized', ...
              'Position', [main_btn_x, main_btn_y, main_btn_w, main_btn_h], ...
              'String', 'Upload', 'FontSize', main_btn_tx_size, 'FontWeight', 'bold', ...
              'ForegroundColor', 'k', 'BackgroundColor', 'w', 'Callback', @Upload_Image);

    uicontrol('Parent', panel_main, 'Style', 'pushbutton', 'Units', 'normalized', ...
              'Position', [1-main_btn_x-main_btn_w, main_btn_y, main_btn_w, main_btn_h], ...
              'String', 'Process', 'FontSize', main_btn_tx_size, 'FontWeight', 'bold', ...
              'ForegroundColor', 'k', 'BackgroundColor', 'w', 'Callback', @Process_Images);

    % ========== [函數區域] ==========
    % 上傳影像
    function Upload_Image(~, ~)
        [filenames, pathname] = uigetfile({'*.jpg', '影像檔案'}, 'Choose 3 images', ...
                                            'MultiSelect', 'on');
        % 阻擋關掉選擇框 + 不等於3個圖片的選擇
        if isequal(filenames, 0) || isequal(pathname, 0) || length(filenames) ~= 3
            return;
        end

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

    % 處理影像
    function Process_Images(~, ~)
        temp = getappdata(fig, 'appData');
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
                    color_type = 'Color(RGB)';
                    gray = rgb2gray(img);
                case 'grayscale'
                    color_type = 'Grayscale';
                    gray = img;
                otherwise
                    color_type = 'Unknown(Invalid type in this program)';
                    gray = img;
            end

            % 圖像特性分析模塊 - 分辨率
            resolution = [info.Width, info.Height];
    
            % 圖像特性分析模塊 - 色彩深度(bit depth)
            bit_depth = info.BitDepth;
    
            % 圖像特性分析模塊 - 對比度
            contrast_results = {};
            contrast_values = {};
            contrast_names = {'General Contrast', 'Luminance contrast', 'Simple contrast', 'Michelson Contrast'};
            img_max = double(max(gray(:)));
            img_min = double(min(gray(:)));
            if img_min < eps
                img_min_safe = eps;
            else
                img_min_safe = img_min;
            end

            % 對比度 - General Contrast 
            g_contrast = img_max - img_min;
            contrast_values{end+1} = g_contrast;
            if g_contrast >= 200
                contrast_results{end+1} = 'General Contrast is very high; the image has extreme differences between light and dark regions.';
            elseif g_contrast >= 150
                contrast_results{end+1} = 'General Contrast is high; the image has noticeable differences between light and dark areas.';
            elseif g_contrast >= 100
                contrast_results{end+1} = 'General Contrast is moderate; the image has a reasonable difference between light and dark regions.';
            elseif g_contrast >= 50
                contrast_results{end+1} = 'General Contrast is low; differences between bright and dark areas are not obvious.';
            else
                contrast_results{end+1} = 'General Contrast is very low; the image has minimal brightness variation.';
            end

            % 對比度 - Luminance Contrast 
            l_contrast = (img_max - img_min) / (img_min_safe);
            contrast_values{end+1} = l_contrast;
            if l_contrast >= 10
                contrast_results{end+1} = 'Luminance contrast is extremely high; very large differences between dark and bright regions.';
            elseif l_contrast >= 5
                contrast_results{end+1} = 'Luminance contrast is high; clear differences between dark and bright regions.';
            elseif l_contrast >= 2
                contrast_results{end+1} = 'Luminance contrast is moderate; some differences between dark and bright regions.';
            elseif l_contrast >= 1
                contrast_results{end+1} = 'Luminance contrast is normal; moderate differences between dark and bright regions.';
            else
                contrast_results{end+1} = 'Luminance contrast is low; image has mostly uniform brightness.';
            end

            % 對比度 - Simple Contrast 
            s_contrast = img_max / img_min_safe;
            contrast_values{end+1} = s_contrast;
            if s_contrast >= 50
                contrast_results{end+1} = 'Simple contrast is extremely high; the brightest and darkest regions differ greatly.';
            elseif s_contrast >= 20
                contrast_results{end+1} = 'Simple contrast is high; brightest regions are clearly brighter than the darkest regions.';
            elseif s_contrast >= 10
                contrast_results{end+1} = 'Simple contrast is moderate; noticeable difference between brightest and darkest regions.';
            elseif s_contrast >= 5
                contrast_results{end+1} = 'Simple contrast is normal; appropriate difference between brightest and darkest regions.';
            else
                contrast_results{end+1} = 'Simple contrast is low; minimal difference between brightest and darkest regions.';
            end

            % 對比度 - Michelson Contrast
            m_contrast = (img_max - img_min) / (img_max + img_min + eps);
            contrast_values{end+1} = m_contrast;
            if m_contrast >= 0.9
                contrast_results{end+1} = 'Michelson contrast is extremely high; suitable for high-contrast display.';
            elseif m_contrast >= 0.7
                contrast_results{end+1} = 'Michelson contrast is high; the image has a vivid visual appearance.';
            elseif m_contrast >= 0.5
                contrast_results{end+1} = 'Michelson contrast is moderate; overall image contrast is good.';
            elseif m_contrast >= 0.3
                contrast_results{end+1} = 'Michelson contrast is normal; overall image contrast is acceptable.';
            else sharpness_results
                contrast_results{end+1} = 'Michelson contrast is low; overall image contrast is insufficient.';
            end

            % 圖像特性分析模塊 - 清晰度
            sharpness_results = {};
            sharpness_values = {};
            sharpness_names = {'Laplacian Variance', 'Edge Detection'};

            % 清晰度 - Laplacian Variance
            sharpness_lap = filtering("imfilter", double(gray), fspecial('laplacian'), 'replicate');
            sharpness = var(sharpness_lap(:));
            sharpness_values{end+1} = sharpness;
            if sharpness >= 500
                sharpness_results{end+1} = 'The image is extremely sharp with rich details and crisp edges.';
            elseif sharpness >= 300
                sharpness_results{end+1} = 'The image has high sharpness; details are clearly visible.';
            elseif sharpness >= 150
                sharpness_results{end+1} = 'The image has moderate sharpness; details are fairly clear.';
            elseif sharpness >= 50
                sharpness_results{end+1} = 'The image has average sharpness; main details are recognizable.';
            else
                sharpness_results{end+1} = 'The image has low sharpness; may appear blurry or noisy.';
            end

            % 清晰度 - 邊緣檢測法
            edges = edge(gray, 'sobel');
            edge_density = sum(edges(:)) / numel(edges);
            sharpness_values{end+1} = edge_density;
            if edge_density >= 0.1
                sharpness_results{end+1} = 'Edge density is very high; the image contains many edges and fine details.';
            elseif edge_density >= 0.05
                sharpness_results{end+1} = 'Edge density is high; the image contains rich edge information.';
            elseif edge_density >= 0.02
                sharpness_results{end+1} = 'Edge density is moderate; edges are clearly visible in the image.';
            elseif edge_density >= 0.01
                sharpness_results{end+1} = 'Edge density is normal; major edges in the image are recognizable.';
            else
                sharpness_results{end+1} = 'Edge density is low; few or unclear edges are present in the image.';
            end

            % 問題診斷
            % 問題診斷 - 直方圖分析
            [counts, ~] = imhist(gray, 256);
            counts = counts / sum(counts);
            total_pixels = numel(gray);
            mean_intensity = mean(gray(:));
            std_intensity = std(double(gray(:)));

            % 問題診斷 - 噪聲診斷
            detected_noises = {};

            % 噪聲診斷 - 高斯躁聲
            if std_intensity > 10
                % 計算局部區域的方差分布
                local_var = stdfilt(double(gray), ones(5));
                local_var_mean = mean(local_var(:));
                local_var_std = std(local_var(:));
                
                % 高斯噪聲通常有較高的局部方差均值且分佈均勻
                % 改進：降低閾值，檢查方差分佈的一致性
                if local_var_mean > 10 && local_var_std / local_var_mean < 1.0
                    detected_noises{end+1} = 'Gaussian Noise';
                end
            end

            % 噪聲診斷 - 松柏躁聲(Poisson Noise)
            hist_diff = counts - mean(counts);
            intensity_ratio = sum(gray(:)) / (total_pixels * 255);
            intensity_var = var(double(gray(:)));
            
            % 松柏噪聲的特性：強度依賴噪聲，噪聲大小與信號強度成正比
            if intensity_ratio < 0.6 && intensity_var > 5
                % 分析暗區和亮區的噪聲分佈特性
                dark_region = gray < mean_intensity * 0.7;
                bright_region = gray > mean_intensity * 1.3;
                
                if sum(dark_region(:)) > total_pixels * 0.1 && sum(bright_region(:)) > total_pixels * 0.1
                    dark_var = var(double(gray(dark_region)));
                    bright_var = var(double(gray(bright_region)));
                    dark_mean = mean(double(gray(dark_region)));
                    bright_mean = mean(double(gray(bright_region)));
                    
                    % 松柏噪聲的方差與平均值成正比
                    dark_ratio = dark_var / (dark_mean + eps);
                    bright_ratio = bright_var / (bright_mean + eps);
                    
                    % 檢查暗區和亮區的方差/均值比率是否接近
                    if abs(dark_ratio - bright_ratio) < 0.5 && dark_ratio > 0.1
                        detected_noises{end+1} = 'Poisson Noise';
                    end
                end
            end

            % 噪聲診斷 - 椒鹽躁聲
            % 改進：更精確地檢測極值像素
            very_dark = sum(gray(:) < 5) / total_pixels;
            very_bright = sum(gray(:) > 250) / total_pixels;
            extreme_pixel_ratio = very_dark + very_bright;
            
            if extreme_pixel_ratio > 0.003
                % 使用中值濾波器對比檢測突變點
                med_filtered = medfilt2(gray, [3 3]);
                diff_img = abs(double(gray) - double(med_filtered));
                significant_diffs = sum(diff_img(:) > 40) / total_pixels;
                
                % 椒鹽噪聲在中值濾波後有明顯區別
                if significant_diffs > 0.005 && significant_diffs < 0.2
                    detected_noises{end+1} = 'Salt & Pepper Noise';
                end
            end

            % 噪聲診斷 - 斑點躁聲
            if std_intensity > 15
                % 計算不同強度區域的局部方差比例
                % 斑點噪聲是乘法噪聲，與像素強度相關
                dark_areas = gray < mean_intensity * 0.7;
                mid_areas = gray >= mean_intensity * 0.7 & gray <= mean_intensity * 1.3;
                bright_areas = gray > mean_intensity * 1.3;
                
                if sum(mid_areas(:)) > total_pixels * 0.1 && sum(bright_areas(:)) > total_pixels * 0.1
                    mid_var = var(double(gray(mid_areas)));
                    bright_var = var(double(gray(bright_areas)));
                    mid_mean = mean(double(gray(mid_areas)));
                    bright_mean = mean(double(gray(bright_areas)));
                    
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
            block_std = stdfilt(double(gray), ones(5));
            block_std_mean = mean(block_std(:));
            
            % 將圖像分為多個強度區間
            intensity_levels = 4;
            level_var = zeros(intensity_levels, 1);
            level_count = zeros(intensity_levels, 1);
            
            for level = 1:intensity_levels
                lower = (level-1) * 255/intensity_levels;
                upper = level * 255/intensity_levels;
                level_mask = gray >= lower & gray < upper;
                
                if sum(level_mask(:)) > total_pixels * 0.05
                    level_var(level) = mean(block_std(level_mask));
                    level_count(level) = sum(level_mask(:));
                end
            end
            
            % 計算有效強度級別間的方差比例
            valid_levels = level_count > 0;
            if sum(valid_levels) >= 2
                valid_vars = level_var(valid_levels);
                max_var_ratio = max(valid_vars) / (min(valid_vars) + eps);
                
                % Localvar噪聲的特點是噪聲強度與信號強度高度相關
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
    
            % 問題診斷 - 模糊檢測
            detected_blur = {};

            % 模糊檢測 - Laplacian Variance
            if sharpness < 100
                blur_level = '';
                if sharpness < 30
                    blur_level = 'severe';
                elseif sharpness < 70
                    blur_level = 'moderate';
                else
                    blur_level = 'slight';
                end
                detected_blur{end+1} = ['Laplacian-based blur detection (' blur_level ')'];
            end

            % 模糊檢測 - 邊緣密度
            if edge_density < 0.015
                blur_level = '';
                if edge_density < 0.005
                    blur_level = 'severe';
                elseif edge_density < 0.01
                    blur_level = 'moderate';
                else
                    blur_level = 'slight';
                end
                detected_blur{end+1} = ['Edge-based blur detection (' blur_level ')'];
            end

            % 模糊檢測 - 運動模糊檢測
            if sharpness > 20 && edge_density > 0.01
                % 使用不同方向的Sobel算子
                h_edges = edge(gray, 'sobel', [], 'horizontal');
                v_edges = edge(gray, 'sobel', [], 'vertical');
                
                h_count = sum(h_edges(:));
                v_count = sum(v_edges(:));
                
                % 如果某一方向的邊緣顯著多於另一方向，可能是運動模糊
                edge_ratio = max(h_count, v_count) / (min(h_count, v_count) + eps);
                if edge_ratio > 2.5
                    if h_count > v_count
                        direction = 'vertical motion';
                    else
                        direction = 'horizontal motion';
                    end

                    detected_blur{end+1} = ['Motion blur detected (' direction ')'];
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
    
            % 問題診斷 - 光線問題診斷
            lighting_issues = {};

            % 光線問題診斷 - 過度曝光
            over_exp_ratio = sum(counts(230:end));
            if over_exp_ratio > 0.2 || (over_exp_ratio > 0.1 && mean_intensity > 200)
                severity = '';
                if over_exp_ratio > 0.4
                    severity = 'severe';
                elseif over_exp_ratio > 0.25
                    severity = 'moderate';
                else
                    severity = 'slight';
                end
                lighting_issues{end+1} = ['Over exposure(' severity ', ' num2str(over_exp_ratio*100,'%.1f') '% bright pixels)'];
            end

            % 光線問題診斷 - 曝光不足
            under_exp_ratio = sum(counts(1:25));
            if under_exp_ratio > 0.2 || (under_exp_ratio > 0.1 && mean_intensity < 50)
                severity = '';
                if under_exp_ratio > 0.4
                    severity = 'severe';
                elseif under_exp_ratio > 0.25
                    severity = 'moderate';
                else
                    severity = 'slight';
                end
                lighting_issues{end+1} = ['Under exposure(' severity ', ' num2str(under_exp_ratio*100,'%.1f') '% dark pixels)'];
            end

            % 光線問題診斷 - 對比度不足
            if g_contrast < 100 && m_contrast < 0.4
                lighting_issues{end+1} = 'Low contrast';
            end

            % 光線問題診斷 - 光照不均
            % 分析光照均勻性通過比較區域亮度
            blocks_h = 4; 
            blocks_w = 4;
            block_height = floor(size(gray, 1) / blocks_h);
            block_width = floor(size(gray, 2) / blocks_w);
            
            block_means = zeros(blocks_h, blocks_w);
            for y = 0:blocks_h-1
                for x = 0:blocks_w-1
                    block = gray(y*block_height+1:min((y+1)*block_height, size(gray, 1)), ...
                                 x*block_width+1:min((x+1)*block_width, size(gray, 2)));
                    block_means(y+1, x+1) = mean(block(:));
                end
            end
            
            % 計算區塊間亮度差異
            block_var = var(block_means(:));
            block_range = max(block_means(:)) - min(block_means(:));
            block_rel_range = block_range / (mean(block_means(:)) + eps);
            
            % 考慮相對範圍和標準差
            if (block_range > 60 && block_rel_range > 0.4) || block_var > 400
                % 檢查是否是自然場景中的正常光照變化
                % 計算相鄰區塊的平均差異
                adjacent_diffs = 0;
                count_diffs = 0;
                
                for y = 1:blocks_h
                    for x = 1:blocks_w
                        if x < blocks_w
                            adjacent_diffs = adjacent_diffs + abs(block_means(y,x) - block_means(y,x+1));
                            count_diffs = count_diffs + 1;
                        end
                        if y < blocks_h
                            adjacent_diffs = adjacent_diffs + abs(block_means(y,x) - block_means(y+1,x));
                            count_diffs = count_diffs + 1;
                        end
                    end
                end
                
                avg_adjacent_diff = adjacent_diffs / count_diffs;
                
                % 若相鄰區塊差異大，可能是不均勻光照；而不是自然場景的正常過渡
                if avg_adjacent_diff > 25 || block_var > 800
                    if block_range > 100
                        lighting_issues{end+1} = 'Severe non-uniform lighting';
                    else
                        lighting_issues{end+1} = 'Moderate non-uniform lighting';
                    end
                end
            end

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
        
            if isequal(color_type, 'Color(RGB)')
                r = double(img(:,:,1));
                g = double(img(:,:,2));
                b = double(img(:,:,3));
                
                % 計算各通道統計
                avg_r = mean(r(:));
                avg_g = mean(g(:));
                avg_b = mean(b(:));
                
                std_r = std(r(:));
                std_g = std(g(:));
                std_b = std(b(:));
                
                color_std = [std_r, std_g, std_b];
                color_avg = [avg_r, avg_g, avg_b];
                
                % 色彩問題診斷 - 色彩單調(各通道變異小)
                if all(color_std < 30) && mean(color_std) < 20
                    detected_color{end+1} = 'Low color variation (flat colors)';
                end
                
                % 色彩問題診斷 - 色偏
                % 計算通道之間的相對差異
                max_channel_diff = max([abs(avg_r - avg_g), abs(avg_r - avg_b), abs(avg_g - avg_b)]);
                [~, dominant_idx] = max(color_avg);
                channel_names = {'Red', 'Green', 'Blue'};
                
                % 計算色彩偏差程度
                channel_ratios = zeros(1,3);
                avg_all = mean(color_avg);
                for c = 1:3
                    channel_ratios(c) = color_avg(c) / (avg_all + eps);
                end
                
                max_ratio = max(channel_ratios);
                
                % 檢查色彩偏差
                if max_channel_diff > 15 && max_ratio > 1.15
                    severity = '';
                    if max_ratio > 1.4
                        severity = 'severe';
                    elseif max_ratio > 1.25
                        severity = 'moderate';
                    else
                        severity = 'slight';
                    end
                    detected_color{end+1} = [channel_names{dominant_idx} ' color cast (' severity ')'];
                end
                
                % 色彩問題診斷 - 色彩飽和度
                max_rgb = max(max(r, g), b);
                min_rgb = min(min(r, g), b);
                saturation_approx = (max_rgb - min_rgb) ./ (max_rgb + eps);
                avg_sat = mean(saturation_approx(:));
                std_sat = std(saturation_approx(:));

                if avg_sat < 0.25
                    severity = '';
                    if avg_sat < 0.1
                        severity = 'severe';
                    elseif avg_sat < 0.2
                        severity = 'moderate';
                    else
                        severity = 'slight';
                    end
                    detected_color{end+1} = ['Low saturation (' severity ', ' num2str(avg_sat,'%.2f') ')'];
                elseif avg_sat > 0.6 && std_sat > 0.15
                    severity = '';
                    if avg_sat > 0.8
                        severity = 'severe';
                    elseif avg_sat > 0.7
                        severity = 'moderate';
                    else
                        severity = 'slight';
                    end
                    detected_color{end+1} = ['High saturation (' severity ', ' num2str(avg_sat,'%.2f') ')'];
                end
                
                % 色彩問題診斷 - 色噪聲
                % 計算各通道噪聲相關性
                if all(color_std > 8)
                    % 計算鄰近像素的色彩差異
                    color_noise_level = 0;
                    sample_size = min(50000, total_pixels); % 限制採樣量提高效率
                    
                    for c = 1:3
                        channel = img(:,:,c);
                        channel_double = double(channel);
                        med_filtered = medfilt2(channel_double, [3 3]);
                        diff_noise = abs(channel_double - med_filtered);
                        color_noise_level = color_noise_level + mean(diff_noise(:));
                    end
                    
                    color_noise_level = color_noise_level / 3;
                    
                    if color_noise_level > 8
                        severity = '';
                        if color_noise_level > 15
                            severity = 'severe';
                        elseif color_noise_level > 10
                            severity = 'moderate';
                        else
                            severity = 'slight';
                        end
                        detected_color{end+1} = ['Color noise detected (' severity ')'];
                    end
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
    
            % 圖像特性分析模塊 + 問題診斷儲存報告
            report_name = ['A0' num2str(i) '.txt'];
            fid = fopen(report_name, 'w');
            fprintf(fid, 'Image analysis report - %s\n\n', temp.images_name{i});
            
            fprintf(fid, '=== Image Characteristics ===\n');
            fprintf(fid, ' - Type: %s\n', color_type);
            fprintf(fid, ' - Resolution: %d x %d\n', resolution(1), resolution(2));
            fprintf(fid, ' - Bit Depth: %s-bit\n', num2str(bit_depth));
            fprintf(fid, ' - Contrast(ratio) Analysis:\n');
            for j = 1:length(contrast_names)
                fprintf(fid, '   %d. %s: %.2f (%s)\n', j, contrast_names{j}, contrast_values{j}, contrast_results{j});
            end
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
            result = img;
            result = double(result);
            count = 0;

            % 處理說明 - 高斯躁聲
            if ismember('Gaussian Noise', detected_noises)
                % 使用高斯濾波器代替簡單均值濾波
                kernel = 5;
                sigma = 2;
                result = filtering("imfilter", result, fspecial('gaussian', [kernel kernel], sigma), 'replicate');

                % 確保像素值在正確範圍內
                result = abs(result);
                result = min(255, max(0, result));

                count = count + 1;
                fprintf(fid, "%d.處理方法: Gaussian Filter - 去除高斯噪聲\n", count);
                fprintf(fid, "  函式: imfilter(A, fspecial('gaussian', [m n], sigma), 'replicate')\n");
                fprintf(fid, "  參數: A = 輸入影像, [m n] = 濾波視窗大小, sigma = 標準差\n");
            end

            % 處理說明 - 松柏躁聲 + 斑點躁聲 + Localvar躁聲
            noise_types = {'Poisson Noise', 'Speckle Noise', 'Localvar Noise'};
            noise_show = {'去除松柏躁聲', '去除斑點噪聲', '去除Localvar局部變異噪聲'};
            sigma_map = containers.Map(noise_types, [1.2, 1.8, 1.5]);
            m_kernel = 3;
            g_kernel = 5;
            for j = 1:length(noise_types)
                if ismember(noise_types{j}, detected_noises)
                    sigma = sigma_map(noise_types{j});
                    % 斑點噪聲處理 - 混合濾波策略
                    result = filtering("medfilt2", result, [m_kernel m_kernel], '');
                    result = filtering("imfilter", result, fspecial('gaussian', [g_kernel g_kernel], sigma), 'replicate');

                    % 確保像素值在正確範圍內
                    result = min(255, max(0, result));

                    count = count + 1;
                    fprintf(fid, "%d.處理方法: Combined Median and Gaussian Filter - %s\n", count, noise_show{j});
                    fprintf(fid, "  函式: medfilt2(A, [m n]) 和 imfilter(A, fspecial('gaussian', [m n], sigma), 'replicate')\n");
                    fprintf(fid, "  參數: A = 輸入影像, [m n] = 濾波視窗大小, sigma = 標準差 (高斯濾波)\n");
                end
            end

            % 處理說明 - 椒鹽躁聲
            if ismember('Salt & Pepper Noise', detected_noises)
                % 針對彩色或灰階圖像的處理
                kernel = 5;
                kernel2 = 3;
                limit = 0.001;
                if size(result, 3) == 3
                    for j = 1:3
                        % 中值濾波是處理椒鹽噪聲的最佳方法
                        result = filtering("medfilt2", result, [kernel kernel], '');
                        
                        % 對於嚴重的椒鹽噪聲，需要二次中值濾波
                        % 檢查極值像素比例
                        channel = double(result(:,:,j));
                        very_dark = sum(channel(:) < 5) / numel(channel);
                        very_bright = sum(channel(:) > 250) / numel(channel);
                        if (very_dark + very_bright) > limit
                            result = filtering("medfilt2", result, [kernel2 kernel2], '');
                        end
                    end
                else
                    result = medfilt2(result, [3 3]);
                    % 檢查是否需要二次濾波
                    very_dark = sum(double(result(:)) < 5) / numel(result);
                    very_bright = sum(double(result(:)) > 250) / numel(result);
                    if (very_dark + very_bright) > limit
                        result = medfilt2(result, [3 3]);
                    end
                end

                % 確保像素值在正確範圍內
                result = abs(result);
                result = min(255, max(0, result));

                count = count + 1;
                fprintf(fid, "%d.處理方法: Adaptive Median Filter - 去除椒鹽噪聲\n", count);
                fprintf(fid, "  函式: medfilt2(A, [m n])\n");
                fprintf(fid, "  參數: A = 輸入影像, [m n] = 濾波視窗大小\n");
            end

            % 處理說明 - Laplacian Variance
            if ismember('Laplacian-based blur detection (severe)', detected_blur) || ismember('Laplacian-based blur detection (moderate)', detected_blur)
                t1 = double(result);
                % 對嚴重和中度模糊使用較強的銳化參數
                kernel = [
                    -1, -1, -1;
                    -1,  8, -1;
                    -1, -1, -1
                ];
                t1 = filtering("imfilter", result, kernel, 'replicate');
                result = min(255, max(0, result + 0.5 * t1));

                % 記錄處理方法
                count = count + 1;
                fprintf(fid, "%d.處理方法: High Boost Filter - 大幅增強邊緣細節\n", count);
                fprintf(fid, "  函式: imfilter(A, kernel, 'replicate')\n");
                fprintf(fid, "  參數: A = 輸入影像, kernel = 濾波視窗大小\n");
            elseif ismember('Laplacian-based blur detection (slight)', detected_blur)
                % 對輕微模糊使用溫和的銳化
                kernel = [0, -1, 0; -1, 5, -1; 0, -1, 0]; % 銳化濾波器
                result = filtering("conv2", t1, kernel, 'same');

                % 確保像素值在有效範圍內
                result = min(255, max(0, result));

                % 記錄處理方法
                count = count + 1;
                fprintf(fid, "%d.處理方法: Laplacian Filter - 增加局部細節\n", count);
                fprintf(fid, " 函式: conv2(A, kernel, 'same')\n");
                fprintf(fid, " 參數: A = 輸入影像, kernel = 濾波視窗大小\n");
            end
            
            % 處理說明 - 邊緣密度
            if ismember('Edge-based blur detection (severe)', detected_blur) || ismember('Edge-based blur detection (moderate)', detected_blur)
                t1 = double(result);
                % 對嚴重和中度邊緣模糊使用Sobel濾波強化
                sobel_x = [-1 0 1; -2 0 2; -1 0 1];
                sobel_y = [-1 -2 -1; 0 0 0; 1 2 1];
                gradient_x = filtering("imfilter", t1, sobel_x, 'replicate');
                gradient_y = filtering("imfilter", t1, sobel_y, 'replicate');
                gradient_magnitude = sqrt(gradient_x.^2 + gradient_y.^2);
                alpha = 0.5;
                
                % 正規化處理
                normalized_gradient = gradient_magnitude / max(gradient_magnitude(:));
                
                % 根據模糊程度調整alpha參數
                if ismember('Edge-based blur detection (moderate)', detected_blur)
                    alpha = 0.3; 
                end
                
                enhanced = t1 + alpha * t1 .* normalized_gradient;
                result = max(0, min(255, enhanced));
                
                % 記錄處理方法
                count = count + 1;
                fprintf(fid, "%d.處理方法: Gradient-based Edge Enhancement - 強化邊緣結構\n", count);
                fprintf(fid, "  函式: Sobel濾波 + 梯度增強\n");
                fprintf(fid, "  參數: t1 = 輸入影像, alpha = 增強強度\n");
            elseif ismember('Edge-based blur detection (slight)', detected_blur)
                % 對輕微邊緣模糊使用高提升濾波
                kernel = [
                    -1, -1, -1;
                    -1,  8, -1;
                    -1, -1, -1
                ];
                edge_enhance = filtering("imfilter", t1, kernel, 'replicate');
                edge_enhance = edge_enhance / max(abs(edge_enhance(:))) * 50;  % 正規化和降低強度
                result = t1 + edge_enhance;
                result = max(0, min(255, result));
                
                % 記錄處理方法
                count = count + 1;
                fprintf(fid, "%d.處理方法: High Boost Filtering - 輕微提升邊緣\n", count);
                fprintf(fid, "  函式: imfilter(A, kernel, 'replicate')\n");
                fprintf(fid, "  參數: A = 輸入影像, kernel = 濾波視窗大小\n");
            end
            
            % 處理說明 - 運動模糊檢測
            if ismember('Motion blur detected (horizontal motion)', detected_blur)
                t1 = double(result);
                % 處理水平運動模糊
                % 針對水平運動模糊，使用垂直方向的銳化濾波器
                motion_kernel = [
                    -1, -1, -1;
                     2,  2,  2;
                    -1, -1, -1
                ];
                motion_enhance = filtering("imfilter", t1, motion_kernel, 'replicate');
                motion_enhance = motion_enhance / max(abs(motion_enhance(:))) * 40;
                result = t1 + motion_enhance;
                result = max(0, min(255, result));
                
                % 記錄處理方法
                count = count + 1;
                fprintf(fid, "%d.處理方法: Directional Sharpening - 針對水平運動模糊\n", count);
                fprintf(fid, "  函式: imfilter(A, kernel, 'replicate')\n");
                fprintf(fid, "  參數: A = 輸入影像, kernel = 濾波視窗大小\n");
            elseif ismember('Motion blur detected (vertical motion)', detected_blur)
                % 處理垂直運動模糊
                % 針對垂直運動模糊，使用水平方向的銳化濾波器
                motion_kernel = [
                    -1, 2, -1;
                    -1, 2, -1;
                    -1, 2, -1
                ];
                motion_enhance = filtering("imfilter", t1, motion_kernel, 'replicate');
                motion_enhance = motion_enhance / max(abs(motion_enhance(:))) * 40;
                result = t1 + motion_enhance;
                result = max(0, min(255, result));
                
                % 記錄處理方法
                count = count + 1;
                fprintf(fid, "%d.處理方法: Directional Sharpening - 針對垂直運動模糊\n", count);
                fprintf(fid, "  函式: imfilter(A, kernel, 'replicate')\n");
                fprintf(fid, "  參數: A = 輸入影像, kernel = 濾波視窗大小\n");
            end

            % 處理說明 - 過度曝光、光照不均
            if any(contains(lighting_issues, 'Over exposure')) || any(contains(lighting_issues, 'non-uniform lighting'))
                t1 = double(result) / 255;
                for j = 1:size(result,3)
                    c = result(:,:,j);
                    meanL = mean(c(:));
                    gamma = 1;
                    if meanL > 200 % 偵測過曝
                        gamma = 1.5; % 增加對比
                    elseif meanL < 80
                        gamma = 0.7; % 亮度過低，提升亮度
                    end

                    % 使用 Gamma 調整
                    t1(:,:,j) = c .^ gamma;
                end
                result = normalize(t1);

                count = count + 1;
                if any(contains(lighting_issues, 'Over exposure'))
                    fprintf(fid, "%d.處理方法: Power Law Transformation - 修正過度曝光\n", count);
                elseif any(contains(lighting_issues, 'non-uniform lighting'))
                    fprintf(fid, "%d.處理方法: Power Law Transformation - 修正光照不均\n", count);
                end
                fprintf(fid, "  函式: A .^ gamma\n");
                fprintf(fid, "  參數: A = 輸入影像, gamma = power law factor\n");
            end

            % 處理說明 - 曝光不足
            if any(contains(lighting_issues, 'Under exposure'))
                t1 = double(result);
                c = 1.2;
                if any(contains(lighting_issues, 'Under exposure(severe'))
                    c = 2;
                elseif any(contains(lighting_issues, 'Under exposure(moderate'))
                    c = 1.5;
                end

                % 使用對數轉換增強暗部區域
                result = c * log(1 + t1 / 255.0);
                result = normalize(result);
               
                count = count + 1;
                fprintf(fid, "%d.處理方法: Log Transformation - 增強曝光不足區域\n", count);
                fprintf(fid, "  函式: c * log(1 + A)\n");
                fprintf(fid, "  參數: A = 正規化輸入影像(0~1範圍), c = 增強係數\n");
            end

            % 處理說明 - 對比度不足
            if ismember('Low contrast', lighting_issues)
                t1 = double(result);
                % 若為彩色圖像，分別處理每個通道
                p = 0.02;
                for j = 1:size(result, 3)
                    val = stretchlim(double(img), [p, 1-p]);
                    if val(2) > val(1)
                        result(:,:,j) = (t1(:,:,j) - val(1)) / (val(2) - val(1));
                    end
                end
                
                count = count + 1;
                fprintf(fid, "%d.處理方法: Contrast Stretching - 增強對比度不足\n", count);
                fprintf(fid, "  函式: (A - min) / (max - min)\n");
                fprintf(fid, "  參數: A = 輸入影像, min, max = 每個通道的最小和最大值\n");
            end

            % 色彩問題診斷 - 色彩單調(各通道變異小)
            if ismember('Low color variation (flat colors)', detected_color)
                % 增強對比度以改善色彩單調的問題
                contrast = 1.3; % 調整對比度參數，適用於色彩單調的圖像
                result = min(255, max(0, result * contrast));

                count = count + 1;
                fprintf(fid, "%d.處理方法: 對比度調整 - 改善色彩單調問題\n", count);
                fprintf(fid, "  函式: A * contrast\n");
                fprintf(fid, "  參數: A = 輸入影像, contrast = 對比度\n");
            end
            
            % 色彩問題診斷 - 色偏
            if any(contains(detected_color, {'Red color cast', 'Green color cast', 'Blue color cast'}))
                % 使用Gray World白平衡校正色偏
                % 實現Gray World方法
                size1 = size(result, 3);
                channel = cell(1, size1);
                avg_channel = cell(1, size1);
                avg_gray = 0;

                for j = 1:size1
                    channel{j} = result(:,:,j);
                    avg_channel{j} = mean(channel{j});
                    avg_gray = avg_gray + avg_channel{j};
                end

                avg_gray = avg_gray / size1;
                max_ratio = 1.5;
                min_ratio = 0.6;
                ratio = cell(1, size1);
                t1 = cell(1, 3);

                for j = 1:size1
                    ratio{j} = avg_gray / avg_channel{j};
                    ratio{j} = min(max_ratio, max(min_ratio, ratio{j}));
                    t1{j} = min(255, max(0, channel{j} * ratio{j}));
                end

                result = cat(3, t1{1}, t1{2}, t1{3});
                
                count = count + 1;
                fprintf(fid, "%d.處理方法: Channel-Based Color Balancing - 校正色偏\n", count);
                fprintf(fid, "  函式: 根據各通道平均值自動平衡色彩偏差\n");
                fprintf(fid, "  參數: ratios(by channel(s)) = ");
                for j = 1:size1
                    if j == size1
                        fprintf(fid, "%.2f\n", ratio{j});
                    else
                        fprintf(fid, "%.2f, ", ratio{j});
                    end
                end
            end
            
            % 色彩問題診斷 - 色彩飽和度
            if any(contains(detected_color, 'Low saturation'))
                % 增強低飽和度的圖像 - 使用色彩強化的方式
                % 透過增加對比度並適度強化色彩差異
                r = double(result(:,:,1));
                g = double(result(:,:,2));
                b = double(result(:,:,3));
                
                % 計算亮度
                luminance = 0.299 * r + 0.587 * g + 0.114 * b;
                
                % 確定增強係數 - 根據飽和度程度調整
                enhancement = 1.5;
                if avg_sat < 0.1
                    enhancement = 2.0; % 嚴重低飽和度情況
                elseif avg_sat < 0.2
                    enhancement = 1.7; % 中度低飽和度
                end
                
                % 計算色差並強化
                r_diff = r - luminance;
                g_diff = g - luminance;
                b_diff = b - luminance;
                
                % 增強色差並添加回亮度
                r_new = luminance + r_diff * enhancement;
                g_new = luminance + g_diff * enhancement;
                b_new = luminance + b_diff * enhancement;
                
                % 確保值在合理範圍內
                rgb_new = cell(1,3);
                rgb_new{1} = min(255, max(0, r_new));
                rgb_new{2} = min(255, max(0, g_new));
                rgb_new{3} = min(255, max(0, b_new));
                
                result = cat(3, rgb_new{1}, rgb_new{2}, rgb_new{3});
                
                count = count + 1;
                fprintf(fid, "%d.處理方法: 色差強化 - 提高色彩飽和度\n", count);
                fprintf(fid, "  函式: 亮度與色差分離增強法\n");
                fprintf(fid, "  參數: enhancement = 色差增強係數\n");
            elseif any(contains(detected_color, 'High saturation'))
                % 降低過高的飽和度 - 通過減弱色彩差異
                r = double(img(:,:,1));
                g = double(img(:,:,2));
                b = double(img(:,:,3));
                
                % 計算亮度
                luminance = 0.299 * r + 0.587 * g + 0.114 * b;
                
                % 確定減弱係數 - 根據飽和度程度調整
                reduction = 0.7;
                if avg_sat > 0.8
                    reduction = 0.5; % 嚴重高飽和度情況
                elseif avg_sat > 0.7
                    reduction = 0.6; % 中度高飽和度
                end
                
                % 計算色差並減弱
                r_diff = r - luminance;
                g_diff = g - luminance;
                b_diff = b - luminance;
                
                % 減弱色差並添加回亮度
                r_new = luminance + r_diff * reduction;
                g_new = luminance + g_diff * reduction;
                b_new = luminance + b_diff * reduction;
                
                % 確保值在合理範圍內
                rgb_new = cell(1,3);
                rgb_new{1} = min(255, max(0, r_new));
                rgb_new{2} = min(255, max(0, g_new));
                rgb_new{3} = min(255, max(0, b_new));
                
                result = cat(3, rgb_new{1}, rgb_new{2}, rgb_new{3});
                
                count = count + 1;
                fprintf(fid, "%d.處理方法: 色差減弱 - 降低過高色彩飽和度\n", count);
                fprintf(fid, "  函式: 亮度與色差分離減弱法\n");
                fprintf(fid, "  參數: reduction = 色差減弱係數\n");
            end
            
            % 色彩問題診斷 - 色噪聲
            if any(contains(detected_color, 'Color noise'))
                % 使用高斯濾波減少色噪聲，對每個通道分別處理，保留顏色
                kernel_size = [5 5]; % 濾波器尺寸
                sigma = 1.2; % 標準差
                
                % 根據噪聲嚴重程度調整參數
                if contains(detected_color{end}, 'severe')
                    kernel_size = [7 7];
                    sigma = 1.8;
                elseif contains(detected_color{end}, 'moderate')
                    kernel_size = [5 5];
                    sigma = 1.5;
                end

                result = filtering("imfilter", result, fspecial('gaussian', kernel_size, sigma), 'replicate');
                
                count = count + 1;
                fprintf(fid, "%d.處理方法: 高斯濾波 - 降低色彩噪聲\n", count);
                fprintf(fid, "  函式: imfilter(channel, fspecial('gaussian', kernel_size, sigma), 'replicate')\n");
                fprintf(fid, "  參數: kernel_size = [%d %d], sigma = %.1f\n", kernel_size(1), kernel_size(2), sigma);
            end

            % 更新影像到輸出區（這邊可以加你後續的增強處理）
            result = uint8(result);
            axes(axes_output(i));
            imshow(result);
            title(axes_output(i), "Output" + num2str(i), 'FontSize', main_tx_size);
            fclose(fid);
            imwrite(result, ['A0' num2str(i) '.jpg']);
        end
    end

    function img = filtering(filter, in, kernel, mode)
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
        end
    end

    function img = normalize(in)
        img = abs(in);
        img = img / max(img(:)) * 255;
    end
end

App();
