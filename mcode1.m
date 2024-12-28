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

    % 定义二阶系统传递函数
    s = tf('s');
    sys3 = 10 / (s^2 + s + 10); % 二阶系统传递函数
    disp('二阶系统传递函数:');
    sys3 % 命令窗口打印传递函数

    % 获取系统的零极点增益
    [z, p, k] = zpkdata(sys3);
    p = p{1}; % 提取极点
    omega_n = sqrt(10); % 无阻尼自然频率
    zeta = 1 / (2 * sqrt(10)); % 阻尼比

    % 打印分析结果
    disp('系统分析结果：');
    disp(['系统极点: ', num2str(p.')]);
    disp(['无阻尼自然频率 (omega_n): ', num2str(omega_n)]);
    disp(['阻尼比 (zeta): ', num2str(zeta)]);

    % 获取系统性能指标
    info = stepinfo(sys3); % 仿真性能指标
    Tp_theory = pi / (omega_n * sqrt(1 - zeta^2)); % 理论峰值时间
    Mp_theory = exp(-zeta * pi / sqrt(1 - zeta^2)) / sqrt(1 - zeta^2); % 理论峰值
    Ts_theory = 4 / (zeta * omega_n); % 理论过渡时间
    Ts_theory_pm2 = Ts_theory / sqrt(log(100)^2 / log(98)^2); % 理论 ±2%的过渡时间
    info.SettlingTime_pm2 = info.SettlingTime / sqrt(log(100)^2 / log(98)^2); % 仿真 ±2%的过渡时间

    % 打印理论值与实际值
    disp('理论计算值与仿真结果比较：');
    disp(['理论峰值 (Mp): ', num2str(Mp_theory)]);
    disp(['仿真峰值 (Mp): ', num2str(info.Peak)]);
    disp(['理论峰值时间 (Tp): ', num2str(Tp_theory), ' s']);
    disp(['仿真峰值时间 (Tp): ', num2str(info.PeakTime), ' s']);
    disp(['理论过渡时间 (Ts, ±5%): ', num2str(Ts_theory), ' s']);
    disp(['仿真过渡时间 (Ts, ±5%): ', num2str(info.SettlingTime), ' s']);
    disp(['理论过渡时间 (Ts, ±2%): ', num2str(Ts_theory_pm2), ' s']);
    disp(['仿真过渡时间 (Ts, ±2%): ', num2str(info.SettlingTime_pm2), ' s']);

    % 创建表格数据
    data = {
        '峰值', Mp_theory, info.Peak;
        '峰值时间', Tp_theory, info.PeakTime;
        '过渡时间 ±5%', Ts_theory, info.SettlingTime;
        '过渡时间 ±2%', Ts_theory_pm2, info.SettlingTime_pm2
    };
    columnNames = {' ', '理论值', '实际值'};
    T = cell2table(data, 'VariableNames', columnNames);

    % 将表格写入Excel文件
    filename = '理论值与仿真结果比较.xlsx';
    writetable(T, filename);
    disp(['数据已保存到 ', filename]);

    % 动画参数
    [y, t] = step(sys3, 0:0.01:10); % 系统阶跃响应数据
    isPaused = false; % 动画是否暂停
    currentIndex = 1; % 当前动画绘制的索引
    gifFrames = []; % 用于存储 GIF 帧

    % 动画绘制
    responseLine = plot(ax, NaN, NaN, 'b-', 'LineWidth', 1.5);
    hold(ax, 'on');
    ax.YLim = [0, max(y) * 1.2];
    legend(ax, '系统阶跃响应');
    hold(ax, 'off');

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

        currentIndex = currentIndex + 30; % 步长，控制动画速度
        if currentIndex > length(t)
            stop(timerObj); % 动画完成后停止
            return;
        end

        % 更新绘图数据
        responseLine.XData = t(1:currentIndex);
        responseLine.YData = y(1:currentIndex);

        % 捕获当前帧并存储为 GIF
        frame = getframe(fig3); % 捕获整个窗口内容
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
            uialert(fig3, '没有动画帧可保存，请先运行动画！', '提示');
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

        uialert(fig3, ['动画已保存为 GIF 文件：', gifFile], '保存成功');
    end

    % 窗口关闭时释放资源
    fig3.CloseRequestFcn = @(~, ~) onClose();
    function onClose()
        stop(timerObj); % 停止定时器
        delete(timerObj); % 删除定时器
        delete(fig3); % 删除窗口
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

    % 计算并显示系统的增益范围及目标特性
    criticalGain = abs(min(real(zero(sys)))); % 示例：通过根轨迹图分析计算增益范围
    disp(['通过根轨迹图，系统稳定的 k 值范围大约在 k > ', num2str(criticalGain)]);

    % 查找阻尼比为0.5时的k值和特征根
    zeta = 0.5; % 阻尼比
    wn = sqrt(20); % 固有频率
    sigma = zeta * wn; % 实部
    wd = wn * sqrt(1 - zeta^2); % 虚部
    desired_pole = -sigma + 1i * wd; % 目标极点
    try
        [k_value, poles_at_zeta] = rlocfind(sys, desired_pole);
        disp(['阻尼比为0.5时的k值: ', num2str(k_value)]);
        disp('对应的特征根:');
        disp(poles_at_zeta);
    catch
        disp('无法找到满足阻尼比为 0.5 的增益 k 值，可能目标极点不在根轨迹上。');
    end

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




% % 实验3.4代码实现%窗口5
% 
% % 定义传递函数
% s = tf('s');
% k = 1; % 引入增益参数
% sys = k * (s + 1) / (s * (s - 1) * (s^2 + 4*s + 20));
% sys
% % 1. 绘制根轨迹
% figure;
% rlocus(sys); % 绘制根轨迹
% title('系统的根轨迹');
% 
% % 2. 确定系统稳定的k值范围
% % 系统稳定时，所有闭环极点应在左半平面。
% % 使用根轨迹图手动观察。
% 
% % 3. 确定阻尼比为0.5时的k值和特征根
% zeta = 0.5; % 阻尼比
% wn = sqrt(20); % 固有频率
% sigma = zeta * wn; % 实部
% wd = wn * sqrt(1 - zeta^2); % 虚部
% desired_pole = -sigma + 1i*wd; % 目标极点
% 
% [k_value, poles] = rlocfind(sys, desired_pole); % 查找k值
% disp(['阻尼比为0.5时的k值: ', num2str(k_value)]);
% disp('对应的特征根:');
% disp(poles);






% Z = [-1];
% P = [0 1 -2+4*j -2-4*j];
% K = 1;
% sys = zpk(Z, P, K);
% rlocus(sys);
% [k, r] = rlocfind(sys);

