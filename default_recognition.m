function output_data = default_recognition(input_data, params)
% DEFAULT_RECOGNITION 默认识别算法
%
% 对复数数据进行简单的识别（基于幅度聚类）
%
% 参数定义：
% PARAM: num_classes, int, 3
% PARAM: method, string, kmeans

    % 获取参数
    num_classes = getParam(params, 'num_classes', 3);
    method = getParam(params, 'method', 'kmeans');

    % 确保输入为复数矩阵
    if ~isnumeric(input_data)
        error('输入数据必须是数值类型');
    end

    % 转换为double类型
    input_data = double(input_data);

    % 计算幅度
    magnitude = abs(input_data);
    magnitude_db = 20 * log10(magnitude + eps);

    % 简单聚类识别
    [rows, cols] = size(magnitude_db);
    features = magnitude_db(:);

    % 简单的阈值分类（代替kmeans，避免依赖统计工具箱）
    max_val = max(features);
    min_val = min(features);
    range = max_val - min_val;

    % 按幅度均匀分割
    labels = ones(size(features));
    for i = 1:num_classes
        threshold = min_val + (i / num_classes) * range;
        labels(features >= threshold) = i;
    end

    % 重塑为矩阵形状
    label_matrix = reshape(labels, rows, cols);

    % 创建输出结构体
    output_data = struct();
    output_data.complex_matrix = input_data;  % 保持原始复数数据
    output_data.labels = label_matrix;
    output_data.num_classes = num_classes;
    output_data.method = method;
    output_data.name = '识别';  % 重要：设置name字段
    output_data.timestamp = datetime('now');

    % 统计每个类别的数量
    class_counts = zeros(num_classes, 1);
    for i = 1:num_classes
        class_counts(i) = sum(label_matrix(:) == i);
    end
    output_data.class_counts = class_counts;

    % 创建figure并缓存
    try
        fig = figure('Visible', 'off');

        % 创建2个子图
        subplot(1, 2, 1);
        imagesc(20*log10(abs(input_data) + eps));
        axis on;
        colorbar;
        title('原始幅度(dB)');
        xlabel('距离单元');
        ylabel('多普勒单元');

        subplot(1, 2, 2);
        imagesc(label_matrix);
        axis on;
        colorbar;
        title(sprintf('识别结果 - %d类', num_classes));
        xlabel('距离单元');
        ylabel('多普勒单元');

        % 添加整体标题
        sgtitle(sprintf('识别分析 - 方法:%s', method));

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
