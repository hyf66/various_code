function mainControlWindow() 
    % 检查是否已经存在总控窗口
    existingFig = findobj('Type', 'figure', 'Name', '总控窗口');
    if ~isempty(existingFig)
        % 如果总控窗口已经存在，则聚焦到该窗口并返回
        figure(existingFig);
        return;
    end

    % 创建总控窗口
    fig = uifigure('Name', '总控窗口', 'Position', [100, 100, 400, 400]);

    % 按钮1：一阶系统正弦信号输入
    btn1 = uibutton(fig, 'push', 'Text', '绘制一阶系统', 'Position', [50, 320, 105, 30], ...
        'ButtonPushedFcn', @(btn, event) toggleWindow1());

    % 按钮2：二阶系统阶跃响应
    btn2 = uibutton(fig, 'push', 'Text', '绘制二阶系统', 'Position', [50, 270, 105, 30], ...
        'ButtonPushedFcn', @(btn, event) toggleWindow2());

    % 按钮3：二阶系统分析与仿真
    btn3 = uibutton(fig, 'push', 'Text', '绘制二阶系统仿真', 'Position', [50, 220, 105, 30], ...
        'ButtonPushedFcn', @(btn, event) toggleWindow3());

    % 按钮4：单位斜坡响应
    btn4 = uibutton(fig, 'push', 'Text', '绘制单位斜坡响应', 'Position', [50, 170, 105, 30], ...
        'ButtonPushedFcn', @(btn, event) toggleWindow4());

    % 按钮5：系统根轨迹
    btn5 = uibutton(fig, 'push', 'Text', '绘制根轨迹', 'Position', [50, 120, 105, 30], ...
        'ButtonPushedFcn', @(btn, event) toggleWindow5());

    % 子窗口状态保存
    windowHandles = struct('Window1', [], 'Window2', [], 'Window3', [], 'Window4', [], 'Window5', []);

    % 按钮的回调函数：绘制或关闭不同的窗口
    function toggleWindow1()
        toggleWindow(@createWindow1, 'Window1');
    end

    function toggleWindow2()
        toggleWindow(@createWindow2, 'Window2');
    end

    function toggleWindow3()
        toggleWindow(@createWindow3, 'Window3');
    end

    function toggleWindow4()
        toggleWindow(@createWindow4, 'Window4');
    end

    function toggleWindow5()
        toggleWindow(@createWindow5, 'Window5');
    end

    % 通用切换窗口逻辑
    function toggleWindow(createFunc, windowName)
        % 检查子窗口是否已经存在
        if isempty(windowHandles.(windowName)) || ~isvalid(windowHandles.(windowName))
            % 如果窗口不存在或无效，创建窗口
            windowHandles.(windowName) = createFunc();
        else
            % 如果窗口已存在，关闭窗口
            delete(windowHandles.(windowName));
            windowHandles.(windowName) = [];
        end
    end
end

function fig1 = createWindow1()
    % 窗口1：一阶系统正弦信号输入与响应
    fig1 = uifigure('Name', '一阶系统正弦信号输入', 'Position', [100, 100, 600, 400]);

    % 创建UI轴用于绘图
    ax = uiaxes(fig1, 'Position', [50, 100, 500, 250]);
    ax.XLabel.String = '时间 (s)';
    ax.YLabel.String = '幅值';
    ax.Title.String = '一阶系统正弦信号输入与响应';
    grid(ax, 'on');

    % 创建按钮
    btnPause = uibutton(fig1, 'push', 'Text', '暂停', 'Position', [150, 50, 100, 30], ...
        'ButtonPushedFcn', @(btn, event) pauseAnimation());
    btnReset = uibutton(fig1, 'push', 'Text', '重绘', 'Position', [300, 50, 100, 30], ...
        'ButtonPushedFcn', @(btn, event) resetAnimation());
    btnSaveGIF = uibutton(fig1, 'push', 'Text', '保存 GIF', 'Position', [450, 50, 100, 30], ...
        'ButtonPushedFcn', @(btn, event) saveGIFAnimation());

    % 动画参数
    t = 0:0.01:10;  % 时间向量
    u = sin(t);      % 输入信号
    sys1 = tf(1, [1 1]); % 一阶系统
    [y, ~] = lsim(sys1, u, t); % 系统响应
    isPaused = false; % 动画是否暂停
    gifFrames = []; % 用于存储 GIF 帧

    % 动画绘制
    inputLine = plot(ax, NaN, NaN, 'b--', 'LineWidth', 1.5); % 输入信号
    hold(ax, 'on');
    responseLine = plot(ax, NaN, NaN, 'r-', 'LineWidth', 1.5); % 系统响应
    hold(ax, 'off');
    legend(ax, {'输入信号 (sin(t))', '系统响应'});

    % 定时器对象
timerObj = timer('ExecutionMode', 'fixedRate', 'Period', 0.1, ...
                 'TimerFcn', @(~, ~) updateAnimation(), ...
                 'StopFcn', @(~, ~) delete(timerObj)); % 定时器停止时删除自身

    start(timerObj); % 启动定时器

% 定时器回调函数，用于更新动画
function updateAnimation()
    if isPaused
        return;
    end

    % 获取当前的x轴范围
    xDataInput = inputLine.XData;

    if isempty(xDataInput)
        % 初始化数据
        newIndex = 1;
    else
        % 更新索引
        newIndex = length(xDataInput) + 30; % 固定步长为10
    end

    if newIndex > length(t)
        % 动画完成后停止
        stop(timerObj);
        return;
    end

    % 更新绘图数据
    inputLine.XData = t(1:newIndex);
    inputLine.YData = u(1:newIndex);
    responseLine.XData = t(1:newIndex);
    responseLine.YData = y(1:newIndex);

    % 捕获当前帧并存储为 GIF
    frame = getframe(fig1); % 捕获整个窗口内容，包括坐标轴
    gifFrames = [gifFrames, frame]; % 累积帧


end



    % 暂停按钮的回调
    function pauseAnimation()
        isPaused = ~isPaused; % 切换暂停状态
        if isPaused
            btnPause.Text = '继续';
        else
            btnPause.Text = '暂停';
        end
    end

    % 重绘按钮的回调
    function resetAnimation()
        stop(timerObj); % 停止定时器
        inputLine.XData = NaN; % 清空输入信号
        inputLine.YData = NaN;
        responseLine.XData = NaN; % 清空系统响应
        responseLine.YData = NaN;
        isPaused = false; % 重置暂停状态
        gifFrames = []; % 清空帧数据
        btnPause.Text = '暂停'; % 重置按钮文本
        start(timerObj); % 重新启动定时器
    end

    % 保存 GIF 的回调
    function saveGIFAnimation()
        if isempty(gifFrames)
            uialert(fig1, '没有动画帧可保存，请先运行动画！', '提示');
            return;
        end

        % 弹出对话框选择保存路径
        [file, path] = uiputfile('*.gif', '保存 GIF 文件');
        if isequal(file, 0) || isequal(path, 0)
            return; % 用户取消
        end

        gifFile = fullfile(path, file);

        % 保存 GIF 动画
        for i = 1:length(gifFrames)
            [imind, cm] = rgb2ind(gifFrames(i).cdata, 256);
            if i == 1
                imwrite(imind, cm, gifFile, 'gif', 'Loopcount', inf, 'DelayTime', 0.1);
            else
                imwrite(imind, cm, gifFile, 'gif', 'WriteMode', 'append', 'DelayTime', 0.1);
            end
        end

        uialert(fig1, ['动画已保存为 GIF 文件：', gifFile], '保存成功');
    end
% 窗口关闭时停止定时器并清理资源
function onClose()
    if isvalid(timerObj)
        stop(timerObj); % 停止定时器
        delete(timerObj); % 删除定时器
    end
    delete(fig1); % 删除窗口
end

end


function fig2 = createWindow2()
    % 窗口2：二阶系统阶跃响应（不同阻尼比）
    fig2 = uifigure('Name', '二阶系统阶跃响应', 'Position', [100, 100, 800, 400]); % 调整窗口宽度以容纳图例

    % 创建UI轴用于绘图
    ax = uiaxes(fig2, 'Position', [50, 100, 600, 250]); % 调整轴的位置和大小
    ax.XLabel.String = '时间 (秒)';
    ax.YLabel.String = '输出';
    ax.Title.String = '二阶系统阶跃响应（不同阻尼比）';
    grid(ax, 'on');

    % 创建按钮
    btnPause = uibutton(fig2, 'push', 'Text', '暂停', 'Position', [150, 50, 100, 30], 'ButtonPushedFcn', @(btn, event) pauseAnimation());
    btnReset = uibutton(fig2, 'push', 'Text', '重绘', 'Position', [300, 50, 100, 30], 'ButtonPushedFcn', @(btn, event) resetAnimation());
    btnSaveGIF = uibutton(fig2, 'push', 'Text', '保存 GIF', 'Position', [450, 50, 100, 30], 'ButtonPushedFcn', @(btn, event) saveGIFAnimation());

    % 参数设置
    zeta_values = 0.1:0.1:1; % 阻尼比数组
    omega_n = 1; % 自然频率
    t = 0:0.01:60; % 时间向量
    responses = cell(length(zeta_values), 1); % 存储各阻尼比的系统响应

    % 计算每个阻尼比对应的阶跃响应
    for i = 1:length(zeta_values)
        zeta = zeta_values(i);
        sys2 = tf(omega_n^2, [1, 2 * zeta * omega_n, omega_n^2]);
        [y, ~] = step(sys2, t);
        responses{i} = y; % 将响应存储
    end

    % 动画参数
    isPaused = false; % 动画是否暂停
    currentIndex = 1; % 当前动画绘制的索引
    gifFrames = []; % 用于存储 GIF 帧

    % 绘制曲线初始化
    plots = gobjects(length(zeta_values), 1);
    for i = 1:length(zeta_values)
        plots(i) = plot(ax, NaN, NaN, 'LineWidth', 1.5); % 占位曲线
        hold(ax, 'on');
    end
    hold(ax, 'off');

    % 创建图例并设置位置（自定义位置到右侧）
    lgd = legend(ax, ...
        arrayfun(@(zeta) sprintf('\\zeta = %.1f', zeta), zeta_values, 'UniformOutput', false), ...
        'Location', 'none'); % 禁用默认位置
    lgd.Position = [0.7, 0.4, 0.2, 0.2]; % 自定义图例的位置 [x, y, width, height]（在右侧）

    % 定时器对象
    timerObj = timer('ExecutionMode', 'fixedRate', 'Period', 0.01, ...
                     'TimerFcn', @(~, ~) updateAnimation(), ...
                     'StopFcn', @(~, ~) delete(timerObj)); % 定时器停止时删除自身

    start(timerObj); % 启动定时器

    % 定时器回调函数：更新动画
    function updateAnimation()
        if isPaused
            return;
        end
       stepSize = 50; % 调整步长值，例如 5 表示更快的更新速度
currentIndex = currentIndex + stepSize;

        if currentIndex > length(t)
            stop(timerObj); % 动画完成后停止
            return;
        end

        % 更新每条曲线的数据
        for i = 1:length(zeta_values)
            plots(i).XData = t(1:currentIndex);
            plots(i).YData = responses{i}(1:currentIndex);
        end

        % 捕获当前帧并存储为 GIF
        frame = getframe(fig2); % 捕获整个窗口内容，包括坐标轴
        gifFrames = [gifFrames, frame]; % 累积帧
    end

    % 暂停按钮的回调
    function pauseAnimation()
        isPaused = ~isPaused; % 切换暂停状态
        if isPaused
            btnPause.Text = '继续';
        else
            btnPause.Text = '暂停';
        end
    end

    % 重绘按钮的回调
    function resetAnimation()
        stop(timerObj); % 停止定时器
        currentIndex = 1; % 重置动画索引
        isPaused = false; % 重置暂停状态
        btnPause.Text = '暂停';
        gifFrames = []; % 清空帧数据
        % 清空曲线数据
        for i = 1:length(plots)
            plots(i).XData = NaN;
            plots(i).YData = NaN;
        end
        start(timerObj); % 重新启动定时器
    end

    % 保存 GIF 的回调
    function saveGIFAnimation()
        if isempty(gifFrames)
            uialert(fig2, '没有动画帧可保存，请先运行动画！', '提示');
            return;
        end

        % 弹出对话框选择保存路径
        [file, path] = uiputfile('*.gif', '保存 GIF 文件');
        if isequal(file, 0) || isequal(path, 0)
            return; % 用户取消
        end

        gifFile = fullfile(path, file);

        % 保存 GIF 动画
        for i = 1:length(gifFrames)
            [imind, cm] = rgb2ind(gifFrames(i).cdata, 256);
            if i == 1
                imwrite(imind, cm, gifFile, 'gif', 'Loopcount', inf, 'DelayTime', 0.1);
            else
                imwrite(imind, cm, gifFile, 'gif', 'WriteMode', 'append', 'DelayTime', 0.1);
            end
        end

        uialert(fig2, ['动画已保存为 GIF 文件：', gifFile], '保存成功');
    end

    % 窗口关闭时释放资源
    fig2.CloseRequestFcn = @(~, ~) onClose();
    function onClose()
        stop(timerObj); % 停止定时器
        delete(timerObj); % 删除定时器
        delete(fig2); % 删除窗口
    end
end


function fig3 = createWindow3()
    % 窗口3：二阶系统分析与仿真
    fig3 = uifigure('Name', '二阶系统分析与仿真', 'Position', [100, 100, 700, 500]);

    % 创建UI轴用于绘图
    ax = uiaxes(fig3, 'Position', [50, 150, 600, 300]);
    ax.XLabel.String = '时间 (s)';
    ax.YLabel.String = '幅值';
    ax.Title.String = '二阶系统阶跃响应';
    grid(ax, 'on');

    % 创建按钮
    btnPause = uibutton(fig3, 'push', 'Text', '暂停', 'Position', [100, 50, 100, 30], 'ButtonPushedFcn', @(btn, event) pauseAnimation());
    btnReset = uibutton(fig3, 'push', 'Text', '重绘', 'Position', [250, 50, 100, 30], 'ButtonPushedFcn', @(btn, event) resetAnimation());
    btnSaveGIF = uibutton(fig3, 'push', 'Text', '保存 GIF', 'Position', [400, 50, 100, 30], 'ButtonPushedFcn', @(btn, event) saveGIFAnimation());

    % 定义传递函数
    numerator = 10;
    denominator = [1, 2, 10];
    sys = tf(numerator, denominator);

    % 计算系统分析数据
    poles = roots(denominator);
    omega_n = sqrt(denominator(3));
    zeta = denominator(2) / (2 * omega_n);
    omega_d = omega_n * sqrt(1 - zeta^2);
    Mp_theory = exp(-zeta * pi / sqrt(1 - zeta^2));
    tp_theory = pi / omega_d;
    ts_theory_5 = 3 / (zeta * omega_n);
    ts_theory_2 = 4 / (zeta * omega_n);

    % 仿真计算
    [y, t] = step(sys, 0:0.01:10); % 仿真到10秒
    peak_value_sim = max(y);
    [~, peak_index] = max(y);
    tp_sim = t(peak_index);

    y_final = 1;
    tolerance_5 = 0.05 * y_final;
    tolerance_2 = 0.02 * y_final;

    index_5 = find(abs(y - y_final) > tolerance_5);
    if isempty(index_5)
        ts_sim_5 = NaN;
    else
        ts_sim_5 = t(index_5(end) + 1);
    end

    index_2 = find(abs(y - y_final) > tolerance_2);
    if isempty(index_2)
        ts_sim_2 = NaN;
    else
        ts_sim_2 = t(index_2(end) + 1);
    end

    % 打印结果到命令行
    disp('系统的根:');
    disp(poles);
    disp(['自然频率 (ω_n): ', num2str(omega_n)]);
    disp(['阻尼比 (ζ): ', num2str(zeta)]);
    disp(['理论峰值 (M_p): ', num2str(Mp_theory)]);
    disp(['理论峰值时间 (t_p): ', num2str(tp_theory)]);
    disp(['理论过渡时间 (±5%, t_s): ', num2str(ts_theory_5)]);
    disp(['理论过渡时间 (±2%, t_s): ', num2str(ts_theory_2)]);
    disp(['仿真峰值 (M_p): ', num2str(peak_value_sim)]);
    disp(['仿真峰值时间 (t_p): ', num2str(tp_sim)]);
    disp(['仿真过渡时间 (±5%, t_s): ', num2str(ts_sim_5)]);
    disp(['仿真过渡时间 (±2%, t_s): ', num2str(ts_sim_2)]);

    % 保存数据到Excel
    data = {
        '峰值', Mp_theory, peak_value_sim;
        '峰值时间', tp_theory, tp_sim;
        '过渡时间 ±5%', ts_theory_5, ts_sim_5;
        '过渡时间 ±2%', ts_theory_2, ts_sim_2
    };
    columnNames = {'指标', '理论值', '仿真值'};
    T = cell2table(data, 'VariableNames', columnNames);
    filename = '系统分析结果.xlsx';
    writetable(T, filename);
    disp(['数据已保存到 ', filename]);

    % 动画相关
    isPaused = false;
    currentIndex = 1;
    gifFrames = [];
    responseLine = plot(ax, NaN, NaN, 'b-', 'LineWidth', 1.5, 'DisplayName', '系统阶跃响应');
    hold(ax, 'on');

    % 绘制峰值点和容差带
    peakMarker = plot(ax, NaN, NaN, 'ro', 'MarkerSize', 8, 'DisplayName', '峰值点');
    tol5Line1 = yline(ax, y_final + tolerance_5, '--r', 'DisplayName', '±5% 容差带');
    tol5Line2 = yline(ax, y_final - tolerance_5, '--r', 'HandleVisibility', 'off');
    tol2Line1 = yline(ax, y_final + tolerance_2, '--g', 'DisplayName', '±2% 容差带');
    tol2Line2 = yline(ax, y_final - tolerance_2, '--g', 'HandleVisibility', 'off');
    ax.YLim = [0, max(y) * 1.2];
    legend(ax, 'show', 'Location', 'northeast');
    hold(ax, 'off');

    % 定时器
    timerObj = timer('ExecutionMode', 'fixedRate', 'Period', 0.1, ...
                     'TimerFcn', @(~, ~) updateAnimation(), ...
                     'StopFcn', @(~, ~) delete(timerObj));
    start(timerObj);

    % 动画更新函数
    function updateAnimation()
        if isPaused
            return;
        end
        currentIndex = currentIndex + 30;
        if currentIndex > length(t)
            stop(timerObj);
            return;
        end
        responseLine.XData = t(1:currentIndex);
        responseLine.YData = y(1:currentIndex);

        % 更新峰值点
        peakMarker.XData = t(peak_index);
        peakMarker.YData = peak_value_sim;

        % 捕获当前帧用于保存 GIF
        frame = getframe(fig3);
        gifFrames = [gifFrames, frame];
    end

    % 暂停按钮回调
    function pauseAnimation()
        isPaused = ~isPaused;
        if isPaused
            btnPause.Text = '继续';
        else
            btnPause.Text = '暂停';
        end
    end

    % 重绘按钮回调
    function resetAnimation()
        stop(timerObj);
        responseLine.XData = NaN;
        responseLine.YData = NaN;
        peakMarker.XData = NaN;
        peakMarker.YData = NaN;
        isPaused = false;
        currentIndex = 1;
        btnPause.Text = '暂停';
        gifFrames = [];
        start(timerObj);
    end

    % 保存GIF按钮回调
    function saveGIFAnimation()
        if isempty(gifFrames)
            uialert(fig3, '没有动画帧可保存，请先运行动画！', '提示');
            return;
        end
        [file, path] = uiputfile('*.gif', '保存 GIF 文件');
        if isequal(file, 0) || isequal(path, 0)
            return;
        end
        gifFile = fullfile(path, file);
        for i = 1:length(gifFrames)
            [imind, cm] = rgb2ind(gifFrames(i).cdata, 256);
            if i == 1
                imwrite(imind, cm, gifFile, 'gif', 'Loopcount', inf, 'DelayTime', 0.1);
            else
                imwrite(imind, cm, gifFile, 'gif', 'WriteMode', 'append', 'DelayTime', 0.1);
            end
        end
        uialert(fig3, ['动画已保存为 GIF 文件：', gifFile], '保存成功');
    end

    % 窗口关闭回调
    fig3.CloseRequestFcn = @(~, ~) onClose();
    function onClose()
        stop(timerObj);
        delete(timerObj);
        delete(fig3);
    end
end



function fig4 = createWindow4()
    % 窗口4：单位斜坡响应输入仿真
    fig4 = uifigure('Name', '单位斜坡响应', 'Position', [100, 100, 700, 500]);

    % 创建UI轴用于绘图
    ax = uiaxes(fig4, 'Position', [50, 150, 600, 300]);
    ax.XLabel.String = '时间 (s)';
    ax.YLabel.String = '响应';
    ax.Title.String = '单位斜坡响应';
    grid(ax, 'on');

    % 创建按钮
    btnPause = uibutton(fig4, 'push', 'Text', '暂停', 'Position', [100, 50, 100, 30], 'ButtonPushedFcn', @(btn, event) pauseAnimation());
    btnReset = uibutton(fig4, 'push', 'Text', '重绘', 'Position', [250, 50, 100, 30], 'ButtonPushedFcn', @(btn, event) resetAnimation());
    btnSaveGIF = uibutton(fig4, 'push', 'Text', '保存 GIF', 'Position', [400, 50, 100, 30], 'ButtonPushedFcn', @(btn, event) saveGIFAnimation());

    % 参数设置
    s = tf('s');
    sys4 = 10 / (s^2 + s + 10); % 二阶系统传递函数
    t = 0:0.01:10; % 时间范围
    [y, ~] = lsim(sys4, t, t); % 计算单位斜坡响应
    isPaused = false; % 动画是否暂停
    currentIndex = 1; % 当前动画绘制的索引
    gifFrames = []; % 用于存储 GIF 帧

    % 动画绘制
    inputLine = plot(ax, NaN, NaN, 'b-', 'LineWidth', 1.5); % 输入信号
    hold(ax, 'on');
    responseLine = plot(ax, NaN, NaN, 'r--', 'LineWidth', 1.5); % 输出响应
    hold(ax, 'off');
    legend(ax, {'输入 (单位斜坡)', '输出 (系统响应)'});

    % 定时器对象
    timerObj = timer('ExecutionMode', 'fixedRate', 'Period', 0.1, ...
                     'TimerFcn', @(~, ~) updateAnimation(), ...
                     'StopFcn', @(~, ~) delete(timerObj)); % 定时器停止时删除自身

    start(timerObj); % 启动定时器

    % 定时器回调函数：更新动画
    function updateAnimation()
        if isPaused
            return;
        end

        currentIndex = currentIndex + 30; % 更新步长
        if currentIndex > length(t)
            stop(timerObj); % 动画完成后停止
            return;
        end

        % 更新绘图数据
        inputLine.XData = t(1:currentIndex);
        inputLine.YData = t(1:currentIndex); % 输入为单位斜坡
        responseLine.XData = t(1:currentIndex);
        responseLine.YData = y(1:currentIndex); % 输出响应

        % 捕获当前帧并存储为 GIF
        frame = getframe(fig4); % 捕获整个窗口内容
        gifFrames = [gifFrames, frame];
    end

    % 暂停按钮的回调
    function pauseAnimation()
        isPaused = ~isPaused; % 切换暂停状态
        if isPaused
            btnPause.Text = '继续';
        else
            btnPause.Text = '暂停';
        end
    end

    % 重绘按钮的回调
    function resetAnimation()
        stop(timerObj); % 停止定时器
        inputLine.XData = NaN;
        inputLine.YData = NaN;
        responseLine.XData = NaN;
        responseLine.YData = NaN;
        isPaused = false; % 重置暂停状态
        currentIndex = 1; % 重置动画索引
        btnPause.Text = '暂停';
        gifFrames = []; % 清空帧数据
        start(timerObj); % 重新启动定时器
    end

    % 保存 GIF 的回调
    function saveGIFAnimation()
        if isempty(gifFrames)
            uialert(fig4, '没有动画帧可保存，请先运行动画！', '提示');
            return;
        end

        % 弹出对话框选择保存路径
        [file, path] = uiputfile('*.gif', '保存 GIF 文件');
        if isequal(file, 0) || isequal(path, 0)
            return; % 用户取消
        end

        gifFile = fullfile(path, file);

        % 保存 GIF 动画
        for i = 1:length(gifFrames)
            [imind, cm] = rgb2ind(gifFrames(i).cdata, 256);
            if i == 1
                imwrite(imind, cm, gifFile, 'gif', 'Loopcount', inf, 'DelayTime', 0.1);
            else
                imwrite(imind, cm, gifFile, 'gif', 'WriteMode', 'append', 'DelayTime', 0.1);
            end
        end

        uialert(fig4, ['动画已保存为 GIF 文件：', gifFile], '保存成功');
    end

    % 窗口关闭时释放资源
    fig4.CloseRequestFcn = @(~, ~) onClose();
    function onClose()
        stop(timerObj); % 停止定时器
        delete(timerObj); % 删除定时器
        delete(fig4); % 删除窗口
    end
end

function fig5 = createWindow5()
    % 窗口5：系统的根轨迹与交互
    fig5 = uifigure('Name', '系统的根轨迹', 'Position', [100, 100, 600, 400]);

    % 创建UI轴用于绘图
    ax = uiaxes(fig5, 'Position', [50, 100, 500, 250]);
    ax.Title.String = '系统的根轨迹';
    grid(ax, 'on');

    % 创建按钮
    btnPause = uibutton(fig5, 'push', 'Text', '暂停', 'Position', [100, 30, 100, 30], 'ButtonPushedFcn', @(btn, event) pauseAnimation());
    btnReset = uibutton(fig5, 'push', 'Text', '重绘', 'Position', [250, 30, 100, 30], 'ButtonPushedFcn', @(btn, event) resetAnimation());
    btnSaveGIF = uibutton(fig5, 'push', 'Text', '保存 GIF', 'Position', [400, 30, 100, 30], 'ButtonPushedFcn', @(btn, event) saveGIFAnimation());

    % 定义传递函数
    s = tf('s');
    k = 1; % 引入增益参数
    sys = k * (s + 1) / (s * (s - 1) * (s^2 + 4 * s + 20));

    % 动画参数
    poles = rlocus(sys); % 计算根轨迹
    isPaused = false; % 动画是否暂停
    index = 1; % 当前动画位置索引
    maxIndex = length(poles); % 最大索引
    gifFrames = []; % 用于存储 GIF 帧

    % 初始绘制根轨迹
    rlocus(ax, sys);
    hold(ax, 'on');
    polePlot = plot(ax, real(poles(:,1)), imag(poles(:,1)), 'rx', 'LineWidth', 2, 'MarkerSize', 8);
    hold(ax, 'off');

    % 问题 2：确定系统稳定的 k 值范围 
disp('问题 2：确定系统稳定的 k 值范围');

syms k s;

% 定义闭环特征方程
char_eqn = s^4 + 3*s^3 + 16*s^2 + (k - 20)*s + k;

% 构建 Routh-Hurwitz 表的各行
% s^4 行
s4 = [1, 16, k];

% s^3 行
s3 = [3, k - 20, 0];

% s^2 行
s2_1 = (3*16 - 1*(k - 20))/3;  % (a*c - b*d)/a
s2_2 = k;
s2 = [s2_1, s2_2, 0];

% s^1 行
% 计算 [s2_1 * (k - 20) - s3(1)*s2_2] / s2_1
numerator = s2_1 * (k - 20) - 3 * k;
s1_1 = numerator / s2_1;
s1 = [s1_1, 0, 0];

% s^0 行
s0 = [k, 0, 0];

% Routh-Hurwitz 条件：
% 所有第一列的元素必须为正
% 因此，我们需要满足以下不等式：
% 1. s4 行: 1 > 0 (总是满足)
% 2. s3 行: 3 > 0 (总是满足)
% 3. s3 行: k - 20 > 0 => k > 20
% 4. s2 行: (68 - k)/3 > 0 => k < 68
% 5. s1 行: (-k^2 + 79*k - 1360) / (68 - k) > 0

% 由于 k < 68，因此分母 (68 - k) > 0
% 因此，需要分子 (-k^2 + 79*k - 1360) > 0
% 即 k^2 - 79*k + 1360 < 0

% 求解二次方程 k^2 - 79*k + 1360 = 0 的根
eq = k^2 - 79*k + 1360 == 0;
sol = solve(eq, k);

% 转换为数值
k1 = double(sol(1));
k2 = double(sol(2));

% 确定 k 的范围
k_min = min(k1, k2);
k_max = max(k1, k2);

% 显示结果
disp(['使系统稳定的 k 值范围：', num2str(k_min, '%.4f'), ' < k < ', num2str(k_max, '%.4f')]);

% 问题 3：阻尼比为 0.5 时的 k 值和闭环特征根
disp('问题 3：阻尼比为 0.5 时的 k 值和闭环特征根');
zeta = 0.5; % 阻尼比

% 假设系统的主导极点满足标准二阶系统的形式
% 极点为 -zeta*wn ± wn*sqrt(zeta^2 -1)
% 由于阻尼比为 0.5，极点为 -0.5*wn ± j*(wn*sqrt(1 - zeta^2))

% 为了匹配特征方程，通常需要更复杂的方法来确定 wn 和 k
% 这里我们使用数值方法求解

% 定义方程 wn^3 -8 wn^2 +8 wn +10=0
f = @(wn) wn^3 - 8*wn^2 + 8*wn + 10;

% 使用 fsolve 进行数值求解
initial_guess = 2; % 初始猜测
options = optimoptions('fsolve','Display','none');
wn_solution = fsolve(f, initial_guess, options);

% 计算 k
k_value = wn_solution^2 * (16 - 3 * wn_solution);

disp(['阻尼比为 0.5 时的 wn 值：', num2str(wn_solution, '%.4f')]);
disp(['对应的 k 值：', num2str(k_value, '%.4f')]);

% 计算闭环特征根
% 重新定义闭环特征方程
coeffs_num = [1, 3, 16, (k_value - 20), k_value];
roots_closed_loop = roots(coeffs_num);

disp('闭环特征根为：');
disp(roots_closed_loop);


    % 定时器对象
    timerObj = timer('ExecutionMode', 'fixedRate', 'Period', 0.1, ...
                     'TimerFcn', @(~, ~) updateAnimation());
    start(timerObj); % 启动定时器

    % 定时器回调函数，用于更新动画
    function updateAnimation()
        if isPaused
            return;
        end

        index = index + 1; % 更新索引
        if index > maxIndex
            index = maxIndex; % 防止超出范围
            stop(timerObj); % 停止动画
            return;
        end

        % 更新标记位置
        set(polePlot, 'XData', real(poles(:, index)), 'YData', imag(poles(:, index)));

        % 捕获当前帧并存储为 GIF
        frame = getframe(fig5);
        gifFrames = [gifFrames, frame];
    end

    % 暂停按钮的回调
    function pauseAnimation()
        isPaused = ~isPaused; % 切换暂停状态
        if isPaused
            btnPause.Text = '继续';
        else
            btnPause.Text = '暂停';
        end
    end

    % 重绘按钮的回调
    function resetAnimation()
        stop(timerObj); % 停止定时器
        index = 1; % 重置索引
        isPaused = false; % 重置暂停状态
        btnPause.Text = '暂停';
        set(polePlot, 'XData', real(poles(:, 1)), 'YData', imag(poles(:, 1))); % 重置标记
        gifFrames = []; % 清空帧数据
        start(timerObj); % 重新启动定时器
    end

    % 保存 GIF 的回调
    function saveGIFAnimation()
        if isempty(gifFrames)
            uialert(fig5, '没有动画帧可保存，请先运行动画！', '提示');
            return;
        end

        % 弹出对话框选择保存路径
        [file, path] = uiputfile('*.gif', '保存 GIF 文件');
        if isequal(file, 0) || isequal(path, 0)
            return; % 用户取消
        end

        gifFile = fullfile(path, file);

        % 保存 GIF 动画
        for i = 1:length(gifFrames)
            [imind, cm] = rgb2ind(gifFrames(i).cdata, 256);
            if i == 1
                imwrite(imind, cm, gifFile, 'gif', 'Loopcount', inf, 'DelayTime', 0.1);
            else
                imwrite(imind, cm, gifFile, 'gif', 'WriteMode', 'append', 'DelayTime', 0.1);
            end
        end

        uialert(fig5, ['动画已保存为 GIF 文件：', gifFile], '保存成功');
    end

    % 窗口关闭时停止定时器并清理资源
    fig5.CloseRequestFcn = @(~, ~) onClose();
    function onClose()
        stop(timerObj); % 停止定时器
        delete(timerObj); % 删除定时器对象
        delete(fig5); % 关闭窗口
    end
end







% %窗口5具体解决方法
% % 问题 2：确定系统稳定的 k 值范围 
% disp('问题 2：确定系统稳定的 k 值范围');
% 
% syms k s;
% 
% % 定义闭环特征方程
% char_eqn = s^4 + 3*s^3 + 16*s^2 + (k - 20)*s + k;
% 
% % 构建 Routh-Hurwitz 表的各行
% % s^4 行
% s4 = [1, 16, k];
% 
% % s^3 行
% s3 = [3, k - 20, 0];
% 
% % s^2 行
% s2_1 = (3*16 - 1*(k - 20))/3;  % (a*c - b*d)/a
% s2_2 = k;
% s2 = [s2_1, s2_2, 0];
% 
% % s^1 行
% % 计算 [s2_1 * (k - 20) - s3(1)*s2_2] / s2_1
% numerator = s2_1 * (k - 20) - 3 * k;
% s1_1 = numerator / s2_1;
% s1 = [s1_1, 0, 0];
% 
% % s^0 行
% s0 = [k, 0, 0];
% 
% % Routh-Hurwitz 条件：
% % 所有第一列的元素必须为正
% % 因此，我们需要满足以下不等式：
% % 1. s4 行: 1 > 0 (总是满足)
% % 2. s3 行: 3 > 0 (总是满足)
% % 3. s3 行: k - 20 > 0 => k > 20
% % 4. s2 行: (68 - k)/3 > 0 => k < 68
% % 5. s1 行: (-k^2 + 79*k - 1360) / (68 - k) > 0
% 
% % 由于 k < 68，因此分母 (68 - k) > 0
% % 因此，需要分子 (-k^2 + 79*k - 1360) > 0
% % 即 k^2 - 79*k + 1360 < 0
% 
% % 求解二次方程 k^2 - 79*k + 1360 = 0 的根
% eq = k^2 - 79*k + 1360 == 0;
% sol = solve(eq, k);
% 
% % 转换为数值
% k1 = double(sol(1));
% k2 = double(sol(2));
% 
% % 确定 k 的范围
% k_min = min(k1, k2);
% k_max = max(k1, k2);
% 
% % 显示结果
% disp(['使系统稳定的 k 值范围：', num2str(k_min, '%.4f'), ' < k < ', num2str(k_max, '%.4f')]);
% 
% % 问题 3：阻尼比为 0.5 时的 k 值和闭环特征根
% disp('问题 3：阻尼比为 0.5 时的 k 值和闭环特征根');
% zeta = 0.5; % 阻尼比
% 
% % 假设系统的主导极点满足标准二阶系统的形式
% % 极点为 -zeta*wn ± wn*sqrt(zeta^2 -1)
% % 由于阻尼比为 0.5，极点为 -0.5*wn ± j*(wn*sqrt(1 - zeta^2))
% 
% % 为了匹配特征方程，通常需要更复杂的方法来确定 wn 和 k
% % 这里我们使用数值方法求解
% 
% % 定义方程 wn^3 -8 wn^2 +8 wn +10=0
% f = @(wn) wn^3 - 8*wn^2 + 8*wn + 10;
% 
% % 使用 fsolve 进行数值求解
% initial_guess = 2; % 初始猜测
% options = optimoptions('fsolve','Display','none');
% wn_solution = fsolve(f, initial_guess, options);
% 
% % 计算 k
% k_value = wn_solution^2 * (16 - 3 * wn_solution);
% 
% disp(['阻尼比为 0.5 时的 wn 值：', num2str(wn_solution, '%.4f')]);
% disp(['对应的 k 值：', num2str(k_value, '%.4f')]);
% 
% % 计算闭环特征根
% % 重新定义闭环特征方程
% coeffs_num = [1, 3, 16, (k_value - 20), k_value];
% roots_closed_loop = roots(coeffs_num);
% 
% disp('闭环特征根为：');
% disp(roots_closed_loop);
% %窗口三解决方法一
% clc;
% clear;
% close all;
% 
% % 定义传递函数 ϕ(s) = 10 / (s^2 + 2s + 10)
% numerator = 10;
% denominator = [1, 2, 10]; % s^2 + 2s + 10
% sys = tf(numerator, denominator);
% 
% % **计算系统的根**
% poles = roots(denominator);  % 求解特征方程的根
% disp('系统的根:');
% disp(poles);
% 
% % **计算阻尼比和无阻尼震荡频率**
% omega_n = sqrt(10);  % 自然频率
% zeta = 2 / (2 * omega_n);  % 阻尼比
% disp(['自然频率 (ω_n): ', num2str(omega_n)]);
% disp(['阻尼比 (ζ): ', num2str(zeta)]);
% 
% % **理论公式计算**
% omega_d = omega_n * sqrt(1 - zeta^2);  % 阻尼振荡频率
% 
% % 计算理论峰值
% Mp_theory = exp(-zeta * pi / sqrt(1 - zeta^2));
% disp(['理论峰值 (M_p): ', num2str(Mp_theory)]);
% 
% % 计算理论峰值时间
% tp_theory = pi / omega_d;
% disp(['理论峰值时间 (t_p): ', num2str(tp_theory)]);
% 
% % 计算理论过渡时间 (±5% 和 ±2%)
% ts_theory_5 = 3 / (zeta * omega_n);  % ±5%
% ts_theory_2 = 4 / (zeta * omega_n);  % ±2%
% disp(['理论过渡时间 (±5%, t_s): ', num2str(ts_theory_5)]);
% disp(['理论过渡时间 (±2%, t_s): ', num2str(ts_theory_2)]);
% 
% % **仿真计算**
% % 使用 step() 获取阶跃响应数据
% [y, t] = step(sys);
% peak_value_sim = max(y);  % 仿真峰值
% 
% % 找到仿真峰值时间
% [~, peak_index] = max(y);
% tp_sim = t(peak_index);
% 
% % 找到仿真过渡时间 (±5% 和 ±2%)
% y_final = 1;  % 单位阶跃响应最终值为 1
% tolerance_5 = 0.05 * y_final;  % 5% 容差
% tolerance_2 = 0.02 * y_final;  % 2% 容差
% 
% % 找到进入 ±5% 容差带后不再出容差带的时间
% index_5 = find(abs(y - y_final) <= tolerance_5, 1, 'first');
% for i = index_5:length(y)
%     if any(abs(y(i:end) - y_final) > tolerance_5)
%         continue; % 容差带后有离开容差带的情况，继续寻找
%     else
%         ts_sim_5 = t(i); % 找到满足条件的时间
%         break;
%     end
% end
% 
% % 找到进入 ±2% 容差带后不再出容差带的时间
% index_2 = find(abs(y - y_final) <= tolerance_2, 1, 'first');
% for i = index_2:length(y)
%     if any(abs(y(i:end) - y_final) > tolerance_2)
%         continue; % 容差带后有离开容差带的情况，继续寻找
%     else
%         ts_sim_2 = t(i); % 找到满足条件的时间
%         break;
%     end
% end
% 
% % **输出仿真结果**
% disp(['仿真峰值 (M_p): ', num2str(peak_value_sim)]);
% disp(['仿真峰值时间 (t_p): ', num2str(tp_sim)]);
% disp(['仿真过渡时间 (±5%, t_s): ', num2str(ts_sim_5)]);
% disp(['仿真过渡时间 (±2%, t_s): ', num2str(ts_sim_2)]);
% 
% % **比较理论值和仿真值**
% disp('比较结果:');
% disp(['峰值 - 理论: ', num2str(Mp_theory), ', 仿真: ', num2str(peak_value_sim)]);
% disp(['峰值时间 - 理论: ', num2str(tp_theory), ', 仿真: ', num2str(tp_sim)]);
% disp(['过渡时间 (±5%) - 理论: ', num2str(ts_theory_5), ', 仿真: ', num2str(ts_sim_5)]);
% disp(['过渡时间 (±2%) - 理论: ', num2str(ts_theory_2), ', 仿真: ', num2str(ts_sim_2)]);
% 
% % **绘制响应曲线**
% figure;
% step(sys);
% hold on;
% plot(t(peak_index), peak_value_sim, 'ro', 'MarkerSize', 8, 'DisplayName', '峰值');
% yline(1 + tolerance_5, '--r', 'DisplayName', '±5% 容差带');
% yline(1 - tolerance_5, '--r', 'HandleVisibility', 'off');
% yline(1 + tolerance_2, '--g', 'DisplayName', '±2% 容差带');
% yline(1 - tolerance_2, '--g', 'HandleVisibility', 'off');
% legend show;
% title('系统阶跃响应');
% xlabel('时间 (s)');
% ylabel('输出');
% grid on;
% 
% %% 窗口三解决方法二
% % % clc; 
% % % clear;
% % % close all;
% % % 
% % % % 定义传递函数 ϕ(s) = 10 / (s^2 + 2s + 10)
% % % numerator = 10;
% % % denominator = [1, 2, 10]; % s^2 + 2s + 10
% % % sys = tf(numerator, denominator);
% % % 
% % % % **计算系统的根**
% % % poles = roots(denominator);  % 求解特征方程的根
% % % disp('系统的根:');
% % % disp(poles);
% % % 
% % % % **计算阻尼比和无阻尼震荡频率**
% % % omega_n = sqrt(10);  % 自然频率
% % % zeta = 2 / (2 * omega_n);  % 阻尼比
% % % disp(['自然频率 (ω_n): ', num2str(omega_n)]);
% % % disp(['阻尼比 (ζ): ', num2str(zeta)]);
% % % 
% % % % **理论公式计算**
% % % omega_d = omega_n * sqrt(1 - zeta^2);  % 阻尼振荡频率
% % % 
% % % % 计算理论峰值
% % % Mp_theory = exp(-zeta * pi / sqrt(1 - zeta^2));
% % % disp(['理论峰值 (M_p): ', num2str(Mp_theory)]);
% % % 
% % % % 计算理论峰值时间
% % % tp_theory = pi / omega_d;
% % % disp(['理论峰值时间 (t_p): ', num2str(tp_theory)]);
% % % 
% % % % 计算理论过渡时间 (±5% 和 ±2%)
% % % ts_theory_5 = 3 / (zeta * omega_n);  % ±5%
% % % ts_theory_2 = 4 / (zeta * omega_n);  % ±2%
% % % disp(['理论过渡时间 (±5%, t_s): ', num2str(ts_theory_5)]);
% % % disp(['理论过渡时间 (±2%, t_s): ', num2str(ts_theory_2)]);
% % % 
% % % % **仿真计算**
% % % % 使用 step() 获取阶跃响应数据
% % % [y, t] = step(sys);
% % % peak_value_sim = max(y);  % 仿真峰值
% % % 
% % % % 找到仿真峰值时间
% % % [~, peak_index] = max(y);
% % % tp_sim = t(peak_index);
% % % 
% % % % 找到仿真过渡时间 (±5% 和 ±2%)
% % % y_final = 1;  % 单位阶跃响应最终值为 1
% % % tolerance_5 = 0.05 * y_final;  % 5% 容差
% % % tolerance_2 = 0.02 * y_final;  % 2% 容差
% % % 
% % % % 找到进入 ±5% 容差带并保持的时间
% % % index_5 = find(abs(y - y_final) > tolerance_5);  % 超出 ±5% 容差带的索引
% % % if isempty(index_5)
% % %     ts_sim_5 = NaN; % 如果从未超出容差带
% % % else
% % %     ts_sim_5 = t(index_5(end) + 1); % 最后一次超出后进入的时间
% % % end
% % % 
% % % % 找到进入 ±2% 容差带并保持的时间
% % % index_2 = find(abs(y - y_final) > tolerance_2);  % 超出 ±2% 容差带的索引
% % % if isempty(index_2)
% % %     ts_sim_2 = NaN; % 如果从未超出容差带
% % % else
% % %     ts_sim_2 = t(index_2(end) + 1); % 最后一次超出后进入的时间
% % % end
% % % 
% % % % **输出仿真结果**
% % % disp(['仿真峰值 (M_p): ', num2str(peak_value_sim)]);
% % % disp(['仿真峰值时间 (t_p): ', num2str(tp_sim)]);
% % % disp(['仿真过渡时间 (±5%, t_s): ', num2str(ts_sim_5)]);
% % % disp(['仿真过渡时间 (±2%, t_s): ', num2str(ts_sim_2)]);
% % % 
% % % % **比较理论值和仿真值**
% % % disp('比较结果:');
% % % disp(['峰值 - 理论: ', num2str(Mp_theory), ', 仿真: ', num2str(peak_value_sim)]);
% % % disp(['峰值时间 - 理论: ', num2str(tp_theory), ', 仿真: ', num2str(tp_sim)]);
% % % disp(['过渡时间 (±5%) - 理论: ', num2str(ts_theory_5), ', 仿真: ', num2str(ts_sim_5)]);
% % % disp(['过渡时间 (±2%) - 理论: ', num2str(ts_theory_2), ', 仿真: ', num2str(ts_sim_2)]);
% % % 
% % % % **绘制响应曲线**
% % % figure;
% % % step(sys);
% % % hold on;
% % % plot(t(peak_index), peak_value_sim, 'ro', 'MarkerSize', 8, 'DisplayName', '峰值');
% % % yline(1 + tolerance_5, '--r', 'DisplayName', '±5% 容差带');
% % % yline(1 - tolerance_5, '--r', 'HandleVisibility', 'off');
% % % yline(1 + tolerance_2, '--g', 'DisplayName', '±2% 容差带');
% % % yline(1 - tolerance_2, '--g', 'HandleVisibility', 'off');
% % % legend show;
% % % title('系统阶跃响应');
% % % xlabel('时间 (s)');
% % % ylabel('输出');
% % % grid on;
