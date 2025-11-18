function output_data = default_coherent_integration(input_data, params)
% DEFAULT_COHERENT_INTEGRATION 默认相参积累预处理
%
% 对复数数据进行相参积累（保留相位信息）
%
% 参数定义：
% PARAM: integration_length, int, 4
% PARAM: apply_normalization, bool, true

    % 获取参数
    integration_length = getParam(params, 'integration_length', 4);
    apply_normalization = getParam(params, 'apply_normalization', true);

    % 确保输入为复数矩阵
    if ~isnumeric(input_data)
        error('输入数据必须是数值类型');
    end

    % 转换为double类型
    input_data = double(input_data);

    % 获取数据大小
    [rows, cols] = size(input_data);

    % 相参积累处理（保留相位）
    if integration_length > 1
        % 计算积累后的行数
        new_rows = floor(rows / integration_length);
        output = zeros(new_rows, cols);

        for col = 1:cols
            for i = 1:new_rows
                % 提取待积累的数据段
                start_idx = (i-1) * integration_length + 1;
                end_idx = i * integration_length;
                segment = input_data(start_idx:end_idx, col);

                % 相参积累（复数求和）
                output(i, col) = sum(segment);
            end
        end

        % 归一化
        if apply_normalization
            output = output / integration_length;
        end
    else
        output = input_data;
    end

    % 创建输出结构体
    output_data = struct();
    output_data.complex_matrix = output;
    output_data.integration_length = integration_length;
    output_data.apply_normalization = apply_normalization;
    output_data.original_size = [rows, cols];
    output_data.output_size = size(output);
    output_data.name = '相参积累';  % 重要：设置name字段
    output_data.timestamp = datetime('now');

    % 创建figure并缓存
    try
        fig = figure('Visible', 'off');
        ax = axes('Parent', fig);
        imagesc(ax, 20*log10(abs(output_data.complex_matrix) + eps));
        axis(ax, 'on');
        colorbar(ax);
        title(ax, sprintf('相参积累结果 - 积累长度:%d', integration_length));
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
