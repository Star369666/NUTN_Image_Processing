clc;
clear all;
close all;

function App
    process_names = {'Histogram Equalization', 'Adjust Brightness', 'Adjust Contrast', ...
                     'Binary Threshold', 'Negative Image', 'Power Law Transformation', ...
                     'Log Transformation', 'Contrast Stretching Transformation'};
    one_text_tags = {'contrast', 'threshold', 'log_c'};
    three_text_tags = {'brightness_r', 'brightness_g', 'brightness_b'};
    six_text_tags = {'gamma_c', 'gamma_gamma', 'gamma_low', 'gamma_low_value', ...
                     'gamma_high', 'gamma_high_value'};
    
    % 創建應用程式畫面
    fig = figure('Name', 'S11059003_ImageEnhancement_Project', 'Position', ...
                 [270, 180, 900, 500]);

    % 全域資料(輸入、輸出、副檔名)
    data = struct('original_image', [], 'processed_image', [], 'file_extension', "");
    setappdata(fig, 'appData', data);

    % ========== [初始頁面] ==========
    panel_main = uipanel('Parent', fig, 'Units', 'normalized', ...
                         'Position', [0, 0, 1, 1], 'Title', 'Main Panel');

    % 初始頁面 - Upload Image按鈕
    main_x = 0.1;
    main_y = 0.85;
    main_weight = 0.24;
    main_hight = 0.1;
    main_interval = 0.04;
    
    button_upload = uicontrol('Parent', panel_main, 'Style', 'pushbutton', ...
                          'String', 'Upload Image', 'Units', 'normalized', ...
                          'Position', [main_x, main_y, main_weight, main_hight], ...
                          'Callback', @Upload_Image);

    % 初始頁面 - Processes按鈕
    main_x = main_x + main_weight + main_interval;
    button_process = uicontrol('Parent', panel_main, 'Style', 'pushbutton', ...
                           'String', 'Processes', 'Units', 'normalized', ...
                           'Position', [main_x, main_y, main_weight, main_hight], ...
                           'Callback', @Show_Process_Panel);

    % 初始頁面 - Download Image按鈕
    main_x = main_x + main_weight + main_interval;
    button_download = uicontrol('Parent', panel_main, 'Style', 'pushbutton', ...
                            'String', 'Download Image', 'Units', 'normalized', ...
                            'Position', [main_x, main_y, main_weight, main_hight], ...
                            'Callback', @Download_Image);

    % 初始頁面 - Original Image顯示區
    original_axes = axes('Parent', panel_main, 'Units', 'normalized', ...
                        'Position', [0.1, 0.15, 0.35, 0.6]);
    title(original_axes, 'Original Image');

    % 初始頁面 - Processed Image顯示區
    processed_axes = axes('Parent', panel_main, 'Units', 'normalized', ...
                         'Position', [0.55, 0.15, 0.35, 0.6]);
    title(processed_axes, 'Processed Image');

    % ========== [處理功能頁面] ==========
    panel_process = uipanel('Parent', fig, 'Units', 'normalized', 'Position', [0, 0, 1, 1], ...
                            'Visible', 'off', 'Title', 'Process Panel');

    % 處理功能頁面 - 處理功能按鈕集合
    square = 3;
    process_x = 0.1;
    process_start_y = 0.7;
    process_weight = 0.24;
    process_hight = 0.24;
    process_interval = 0.04;
    
    for i = 1:square
        process_x = process_x + (i > 1) * (process_weight + process_interval);
        for j = 1:square
            process_y = process_start_y - (j-1) * (process_hight+process_interval);
            if i == square && j == square
                break;
            end
            
            process_names_index = 3 * i - 3 + j;
            uicontrol('Parent', panel_process, 'Style', 'pushbutton', ...
                      'String', process_names{process_names_index}, 'Units', 'normalized', ...
                      'Position', [process_x, process_y, process_weight, process_hight], ...
                      'Callback', @(src, event) ...
                      Show_Parameter_Panel(process_names{process_names_index}));
        end
    end

    % 處理功能頁面 - 返回主畫面按鈕
    button_back = uicontrol('Parent', panel_process, 'Style', 'pushbutton', ...
                        'String', 'Back to the Main Panel', 'Units', 'normalized', ...
                        'Position', [process_x, process_y, process_weight, process_hight], ...
                        'Callback', @Show_Main_Panel);

    % ========== [參數頁面] ==========
    panel_parameter = uipanel('Parent', fig, 'Units', 'normalized', 'Position', [0, 0, 1, 1], ...
                              'Visible', 'off', 'Title', 'Parameter Panel');

    % ========== [函數區域] ==========
    % 上傳影像
    function Upload_Image(~, ~)
        [filename, pathname] = uigetfile({'*.jpg;*.jpeg;*.png;*.tif;*.bmp', '影像檔案'}, ...
                                          'Choose an image');
        if isequal(filename, 0) || isequal(pathname, 0)
            return;
        end

        fullPath = fullfile(pathname, filename);
        img = imread(fullPath);
        img_extension = extractAfter(fullPath, ".");
        img_extension = "." + img_extension;
        
        data.original_image = img;
        data.file_extension = img_extension;
        data.processed_image = [];
        setappdata(fig, 'appData', data);

        axes(original_axes);
        imshow(img);
        title(original_axes, 'Original Image');

        cla(processed_axes);
        title(processed_axes, 'Processed Image');
    end

    % 切換到初始頁面
    function Show_Main_Panel(~, ~)
        set(panel_process, 'Visible', 'off');
        set(panel_main, 'Visible', 'on');
    end

    % 切換到處理功能頁面
    function Show_Process_Panel(~, ~)
        set(panel_main, 'Visible', 'off');
        set(panel_parameter, 'Visible', 'off');
        set(panel_process, 'Visible', 'on');
    end

    % 切換到參數頁面
    function Show_Parameter_Panel(process_type)
        set(panel_process, 'Visible', 'off');
        set(panel_parameter, 'Visible', 'on');
        
        % 清除舊的 UI 元件
        delete(allchild(panel_parameter));
        
        % 設定當前選擇的處理功能
        set(panel_parameter, 'UserData', process_type);

        para_tx_w = 0.6;
        para_tx_x = (1 - para_tx_w) / 2;
        para_tx_y = 0.75;
        para_tx_h = 0.1;
        para_tx_size = 14;

        para_btn_x = 0.35;
        para_btn_y = 0.3;
        para_btn_w = 0.3;
        para_btn_h = 0.1;
        para_btn_t = 0.15;

        para_center_y = (para_tx_y + para_btn_y) / 2;
        para_center2_y = (para_center_y + para_tx_y) / 2;

        para_brightness_interval = (para_tx_y - para_tx_h - para_btn_y) / 5;
        para_brightness_y = para_tx_y - para_brightness_interval;
        para_brightness_h = 0.06;

        para_gamma_interval_left = (para_tx_y - para_tx_h - para_btn_y) / 4.5;
        para_gamma_interval_right = (para_tx_y - para_tx_h - para_btn_y) / 6;
        para_gamma_y1 = para_tx_y - para_gamma_interval_left;
        para_gamma_y2 = para_gamma_y1 - para_gamma_interval_left;
        para_gamma_h1 = 0.06;
        para_gamma_h2 = 0.05;
        para_gamma_w = para_tx_w / 2;
        para_gamma_x1 = (1 - para_gamma_w) / 4;
        para_gamma_x2 = (1 - para_gamma_w) / 1.5 + 0.05;
        
        % 設定標題
        uicontrol('Parent', panel_parameter, 'Style', 'text', ...
                  'String', ['Set Parameters for ', process_type], ...
                  'Units', 'normalized', ...
                  'Position', [para_tx_x, para_tx_y, para_tx_w, para_tx_h], ...
                  'FontSize', para_tx_size, 'FontWeight', 'bold', ...
                  'HorizontalAlignment', 'center');
        
        % 動態添加參數輸入框
        switch process_type
            % 無需參數
            % 參數頁面 - 直方圖均衡化
            case 'Histogram Equalization'
                uicontrol('Parent', panel_parameter, 'Style', 'text', ...
                          'String', 'No parameters needed', ...
                          'Units', 'normalized', ...
                          'Position', [para_tx_x, para_center_y, para_tx_w, para_tx_h], ...
                          'FontSize', para_tx_size, 'HorizontalAlignment', 'center');

            % 參數頁面 - 負片
            case 'Negative Image'
                uicontrol('Parent', panel_parameter, 'Style', 'text', ...
                          'String', 'No parameters needed', 'Units', 'normalized', ...
                          'Position', [para_tx_x, para_center_y, para_tx_w, para_tx_h], ...
                          'FontSize', para_tx_size, 'HorizontalAlignment', 'center');

            % 參數頁面 - 對比度拉伸
            case 'Contrast Stretching Transformation'
                uicontrol('Parent', panel_parameter, 'Style', 'text', ...
                          'String', 'No parameters needed(Adjustive)', ...
                          'Units', 'normalized', ...
                          'Position', [para_tx_x, para_center_y, para_tx_w, para_tx_h], ...
                          'FontSize', para_tx_size, 'HorizontalAlignment', 'center');

            % 僅有一個輸入框
            % 參數頁面 - 調整對比度
             case 'Adjust Contrast'
                uicontrol('Parent', panel_parameter, 'Style', 'text', ...
                          'String', 'Contrast Stretch Limit(>0):', 'Units', 'normalized', ...
                          'Position', [para_tx_x, para_center2_y, para_tx_w, para_tx_h], ...
                          'FontSize', para_tx_size);
                uicontrol('Parent', panel_parameter, 'Style', 'edit', ...
                          'Units', 'normalized', 'Tag', one_text_tags{1}, ...
                          'Position', [para_tx_x, para_center_y, para_tx_w, para_tx_h]);

            % 參數頁面 - 二值化閾值
            case 'Binary Threshold'
                uicontrol('Parent', panel_parameter, 'Style', 'text', ...
                          'String', 'Threshold Value(0-255):', 'Units', 'normalized', ...
                          'Position', [para_tx_x, para_center2_y, para_tx_w, para_tx_h], ...
                          'FontSize', para_tx_size);
                uicontrol('Parent', panel_parameter, 'Style', 'edit', ...
                          'Units', 'normalized', 'Tag', one_text_tags{2}, ...
                          'Position', [para_tx_x, para_center_y, para_tx_w, para_tx_h]);

            % 參數頁面 - 對數轉換
            case 'Log Transformation'
                uicontrol('Parent', panel_parameter, 'Style', 'text', ...
                          'String', 'c * log(1+r), c =', 'Units', 'normalized', ...
                          'Position', [para_tx_x, para_center2_y, para_tx_w, para_tx_h], ...
                          'FontSize', para_tx_size);
                uicontrol('Parent', panel_parameter, 'Style', 'edit', ...
                          'Units', 'normalized', 'Tag', one_text_tags{3}, ...
                          'Position', [para_tx_x, para_center_y, para_tx_w, para_tx_h]);
                
            % 三個輸入框
            % 參數頁面 - 調整亮度
            case 'Adjust Brightness'
                uicontrol('Parent', panel_parameter, 'Style', 'text', ...
                          'String', 'Brightness Factors R, G, B =', 'Units', 'normalized', ...
                          'Position', [para_tx_x, para_brightness_y, para_tx_w, para_tx_h], ...
                          'FontSize', para_tx_size, 'HorizontalAlignment', 'center');
                for i = 1:length(three_text_tags)
                    uicontrol('Parent', panel_parameter, 'Style', 'edit', ...
                              'Units', 'normalized', 'Tag', three_text_tags{i}, ...
                              'Position', [para_tx_x, ...
                              para_brightness_y - i*para_brightness_interval, ...
                              para_tx_w, para_brightness_h]);
                end
                
            % 六個輸入框 + 一個開關按鈕
            % 參數頁面 - 冪律轉換(伽瑪校正)
            case 'Power Law Transformation'
                uicontrol('Parent', panel_parameter, 'Style', 'text', ...
                          'String', 'Method 1: c * r^gamma, Method 2: Adjustive gamma value(Low bound, Low bound gamma value, high bound, high bound gamma value)', ...
                          'Units', 'normalized', ...
                          'Position', [para_tx_x, para_gamma_y1, para_tx_w, para_tx_h], ...
                          'FontSize', para_tx_size, 'HorizontalAlignment', 'center');
                for i = 1:3
                    if i == 3
                        uicontrol('Parent', panel_parameter, 'Style', 'togglebutton', ... 
                                  'String', 'Current is Method 1', 'Units', 'normalized', ...
                                  'Position', [para_gamma_x1, ...
                                  para_gamma_y1 - i*para_gamma_interval_left, ...
                                  para_gamma_w, para_gamma_h1], 'Tag', 'switch', ...
                                  'Callback', @Switch_State, 'Enable','on');
                    else
                        uicontrol('Parent', panel_parameter, 'Style', 'edit', ...
                                  'Units', 'normalized', 'Tag', six_text_tags{i}, ...
                                  'Position', [para_gamma_x1, ...
                                  para_gamma_y1 - i*para_gamma_interval_left, ...
                                  para_gamma_w, para_gamma_h1]);
                    end
                end

                for j = i:length(six_text_tags)
                    uicontrol('Parent', panel_parameter, 'Style', 'edit', ...
                                  'Units', 'normalized', 'Tag', six_text_tags{j}, ...
                                  'Position', [para_gamma_x2, ...
                                  para_gamma_y2 - (j-3)*para_gamma_interval_right, ...
                                  para_gamma_w, para_gamma_h2]);
                end
        end
    
        % 參數畫面 - 使用該處理按鈕
        uicontrol('Parent', panel_parameter, 'Style', 'pushbutton', ...
                  'String', 'Apply', 'Units', 'normalized', ...
                  'Position', [para_btn_x, para_btn_y, para_btn_w, para_btn_h], ...
                  'Callback', @(src, event) Apply_Processing_With_Parameters(process_type));
        

        % 參數畫面 - 返回處理功能頁面按鈕
        uicontrol('Parent', panel_parameter, 'Style', 'pushbutton', ...
                  'String', 'Back', 'Units', 'normalized', ...
                  'Position', [para_btn_x, para_btn_y-para_btn_t, para_btn_w, para_btn_h], ...
                  'Callback', @Show_Process_Panel);
    end

    function Switch_State(object, ~)
        current_value = get(object, 'Value');
        if current_value == 0
            set(object, 'String', 'Current is Method 1');
        else
            set(object, 'String', 'Current is Method 2');
        end
    end

    % 參數畫面 - 處理功能實作區
    function Apply_Processing_With_Parameters(process_type)
        % 檢查輸入存在，拿出欲處理圖片
        temp = getappdata(fig, 'appData');
        if isempty(temp.original_image)
            msgbox('No image to process!', 'ERROR', 'error');
            return;
        elseif isempty(temp.processed_image)
            img = temp.original_image;
        else
            % 可以接受上傳新圖片重新處理
            check = size(temp.processed_image) == size(temp.original_image);
            if check(1) == 1 && check(2) == 1
                img = temp.processed_image;
            else
                img = temp.original_image;
            end
        end

        % 取得使用處理的資料(輸入框和開關)
        all_controls = findall(panel_parameter, 'Style', 'edit');
        param_values = struct();
        
        for i = 1:numel(all_controls)
            tag_name = get(all_controls(i), 'Tag');   % 取得該輸入框的 Tag (識別名稱)
            param_values.(tag_name) = str2double(get(all_controls(i), 'String'));  % 存入數值
        end
        
        % 根據處理類別執行處理
        switch process_type
            % 無需參數 - 直方圖均衡化
            case 'Histogram Equalization'
                result = histeq(img);

            % 無需參數 - 負片
            case 'Negative Image'
                result = 255 - img;

            % 無需參數 - 對比度拉伸
            case 'Contrast Stretching Transformation'
                img2 = im2double(img);
                str = stretchlim(img2);
                result = (img2 - str(1)) / (str(2) - str(1));

            % 僅有一個輸入框 - 調整對比度
            case 'Adjust Contrast'
                contrast = param_values.(one_text_tags{1});
                if isnan(contrast) || contrast <= 0
                    msgbox('Invalid contrast factor!', 'ERROR', 'error');
                    return;
                end
                result = uint8(min(255, max(0, im2double(img) * contrast)));
                
            % 僅有一個輸入框 - 二值化閾值
            case 'Binary Threshold'
                threshold = param_values.(one_text_tags{2});
                if isnan(threshold) || threshold < 0 || threshold > 255
                    msgbox('Invalid threshold factor!', 'ERROR', 'error');
                    return;
                end
                if size(img, 3) == 3
                    result = rgb2gray(img) >= threshold;
                else
                    result = img >= threshold;
                end

            % 僅有一個輸入框 - 對數轉換
            case 'Log Transformation'
                 c = param_values.(one_text_tags{3});
                 if isnan(c) || c < 0
                    msgbox('Invalid constant c!', 'ERROR', 'error');
                    return;
                end
                 result = c * log(1 + im2double(img));
    
            % 三個輸入框 - 調整亮度
            case 'Adjust Brightness'
                rgb = cell(1,3);
                rgb_new = cell(1,3);
                for i = 1:length(three_text_tags)
                   rgb{i} = param_values.(three_text_tags{i});
                   if isnan(rgb{i}) || rgb{i} < 0 || rgb{i} > 255
                        msgbox('Invalid brightness factors!', 'ERROR', 'error');
                        return;
                   end
                   rgb_new{i} = uint8(min(255, max(0, double(img(:,:,i)) + rgb{i})));
                end
                result = cat(3, rgb_new{1}, rgb_new{2}, rgb_new{3});
    
            % 六個輸入框+一個開關按鈕 - 冪律轉換(伽瑪校正)
            case 'Power Law Transformation'
                method = get(findall(panel_parameter, 'Tag', 'switch'), 'Value');
                gamma_factors = cell(1,5);
                img2 = im2double(img);
                gamma_factors{1} = param_values.(six_text_tags{1});
                if isnan(gamma_factors{1}) || gamma_factors{1} < 0
                        msgbox('Invalid power law factors!', 'ERROR', 'error');
                        return;
                end

                % Method 1: c * r^gamma
                if method == 0
                    gamma_factors{2} = param_values.(six_text_tags{2});
                    if isnan(gamma_factors{2}) || gamma_factors{2} < 0
                        msgbox('Invalid power law factors!', 'ERROR', 'error');
                        return;
                    end
                    result = gamma_factors{1} * img2 .^ gamma_factors{2};

                % Method 2: Adjust gamma values based on image intensity
                else
                    for i = 3:length(six_text_tags)
                        gamma_factors{i-1} = param_values.(six_text_tags{i});
                        if isnan(gamma_factors{i-1}) || gamma_factors{i-1} < 0
                            msgbox('Invalid power law factors!', 'ERROR', 'error');
                            return;
                        end
                    end

                    if gamma_factors{2} > gamma_factors{4}
                        msgbox('Invalid power law factors!', 'ERROR', 'error');
                        return;
                    end

                    mean_intensity = mean(img2(:));  % Average intensity of the image
                    if mean_intensity < gamma_factors{2}
                        result = gamma_factors{1} * img2 .^ gamma_factors{3}; 
                    elseif mean_intensity > gamma_factors{4}
                        result = gamma_factors{1} * img2 .^ gamma_factors{5};
                    else
                        result = gamma_factors{1} * img2 .^ 1;  % Apply upper bound gamma
                    end
                end
        end
    
        % 儲存處理後影像，避免gamma < 0產生的複數(complex)
        result = real(result);
        data.processed_image = result;
        setappdata(fig, 'appData', data);
    
        % 顯示影像
        axes(processed_axes);
        imshow(data.processed_image);
        title(processed_axes, "Processed Image");

        Calculate();
    end

    % 計算SSIM和PSNR分數
    function Calculate()
        temp_img = data.original_image;
        if isfloat(data.processed_image)
            temp_img = im2double(temp_img);
        end
        if size(data.processed_image, 3) == 1 && size(temp_img, 3) == 3
            temp_img = rgb2gray(temp_img);
        end
        % 避免二值化閾值無法計算(logical image)
        if islogical(data.processed_image)
            data.processed_image = im2double(data.processed_image);
            temp_img = im2double(temp_img);
        end
    
        [s_val, ssim_map] = ssim(data.processed_image, temp_img);
        p_val = psnr(data.processed_image, temp_img);
    
        % 顯示結果(測試用)
        disp(['SSIM: ', num2str(s_val)]);
        disp(['PSNR: ', num2str(p_val)]);
        disp('----------------------------------')
    end

    % 下載影像
    function Download_Image(~, ~)
        data = getappdata(fig, 'appData');
        if isempty(data.processed_image)
            msgbox('No processed image exist!', 'ERROR', 'error');
            return;
        end

        [file, path] = uiputfile('output'+data.file_extension, 'Saving image');
        if file ~= 0
            imwrite(data.processed_image, fullfile(path, file));
            msgbox('Image saved!', 'Succeeded');
        end
    end
end

App();