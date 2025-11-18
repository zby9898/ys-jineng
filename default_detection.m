function output_data = default_detection(input_data, params)
% DEFAULT_DETECTION 默认检测算法
%
% 对复数数据进行简单的幅度阈值检测
%
% 参数定义：
% PARAM: threshold_db, double, -10.0
% PARAM: apply_morphology, bool, true
% PARAM: min_area, int, 5

    % 获取参数
    threshold_db = getParam(params, 'threshold_db', -10.0);
    apply_morphology = getParam(params, 'apply_morphology', true);
    min_area = getParam(params, 'min_area', 5);

    % 确保输入为复数矩阵
    if ~isnumeric(input_data)
        error('输入数据必须是数值类型');
    end

    % 转换为double类型
    input_data = double(input_data);

    % 计算幅度并转换为dB
    magnitude = abs(input_data);
    magnitude_db = 20 * log10(magnitude + eps);

    % 简单阈值检测
    detection_mask = magnitude_db > threshold_db;

    % 形态学处理（去除小目标）
    if apply_morphology && min_area > 0
        % 连通区域分析
        cc = bwconncomp(detection_mask);
        stats = regionprops(cc, 'Area');

        % 移除小于最小面积的区域
        for i = 1:cc.NumObjects
            if stats(i).Area < min_area
                detection_mask(cc.PixelIdxList{i}) = 0;
            end
        end
    end

    % 创建输出结构体
    output_data = struct();
    output_data.complex_matrix = input_data .* detection_mask;
    output_data.detection_mask = detection_mask;
    output_data.threshold_db = threshold_db;
    output_data.num_detections = sum(detection_mask(:));
    output_data.name = '检测';  % 重要：设置name字段
    output_data.timestamp = datetime('now');

    % 创建figure并缓存
    try
        fig = figure('Visible', 'off');
        ax = axes('Parent', fig);

        % 显示检测结果（原图+检测标记）
        imagesc(ax, 20*log10(abs(input_data) + eps));
        hold(ax, 'on');

        % 在检测点上叠加标记
        [row, col] = find(detection_mask);
        if ~isempty(row)
            plot(ax, col, row, 'r.', 'MarkerSize', 8);
        end

        hold(ax, 'off');
        axis(ax, 'on');
        colorbar(ax);
        title(ax, sprintf('检测结果 - 阈值:%.1fdB, 检测数:%d', threshold_db, output_data.num_detections));
        xlabel(ax, '距离单元');
        ylabel(ax, '多普勒单元');

        output_data.cached_figure = fig;
    catch ME
        warning('创建figure失败：%s', ME.message);
    end

end

function value = getParam(params, name, default_value)
    % 辅助函数：从params结构体中获取参数值
    if isfield(params, name)
        value = params.(name);
    else
        value = default_value;
    end
end
