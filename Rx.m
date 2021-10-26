clear

%% 基于用户输入
%sdrdev('Pluto');
%configurePlutoRadio('AD9364')

%%从命令行写入参数
%userInput = helperFMUserInput;
%%计算系统参数
%[fmRxParams,sigSrc] = helperFMConfig(userInput);

%% 配置参数及初始化
fmRxParams.FrontEndFrameTime=0.0168;    %0.0193
fmRxParams.FrontEndSampleRate=228e3;    %取5倍音频采样率

%初始化SDR接收端
sigSrc=comm.SDRRxPluto(...
        'CenterFrequency',98.8e6,...%意向频道 (Hz)
        'GainSource','Manual',...
        'Gain',50,...                      %音量增益
        'ChannelMapping',1,...
        'BasebandSampleRate',fmRxParams.FrontEndSampleRate,...
        'OutputDataType','single',...
        'SamplesPerFrame',4410);

% 初始化FM解调端
fmBroadcastDemod = comm.FMBroadcastDemodulator(...
        'SampleRate', fmRxParams.FrontEndSampleRate, ...
        'FrequencyDeviation', 75e3, ...
        'FilterTimeConstant', 7.5e-5, ...
        'AudioSampleRate', 45600, ...
        'Stereo', true);

% 初始化音频播放
player = audioDeviceWriter('SampleRate',45600);
%info(player)

% 初始化播放时间
radioTime = 0;
totalLost = 0;
lost_frame = single(zeros(4410, 1));
m = 1;

%% 接收与播放
if ~isempty(findPlutoRadio)
        %while radioTime < userInput.Duration   %设置播放时间（秒）
        %while 1
        while radioTime  < 3
                %接收
                [rcv, lost, late] = sigSrc();
                %rcv = sigSrc();
                %lost = 0;
                %late = 1;
                lost_frame(m)=lost;
                m=m+1;

                % 解调FM广播信号并播放解码的音频
                audioSig = fmBroadcastDemod(rcv);
                player(audioSig);

                % 更新播放时间。添加可能丢失的样本帧时
                radioTime = radioTime + fmRxParams.FrontEndFrameTime + ...
                            double(lost)/fmRxParams.FrontEndSampleRate;
                totalLost = totalLost + lost;
        end
else
        warning('PlutoRadioNotFound')
end
fprintf('Total samples lost: %d (%d frames) \n ', totalLost, totalLost / 4410)
%% 时域和频域分析

%rx_signal 即收到的信号
%datavalid 指示数据是否合法
%overflow指示数据是否溢出
[rx_signal,datavalid,overflow] = sigSrc();
rt = real(rx_signal(:,1));
t1 = (0: length(rt)-1)./45600;

%st = demod(real(rx_signal)',fc,fs,'fm');
st = audioSig(:, 1);
t = (0: length(st)-1)./45600;
Wn = 8000*2/45600;
[B, A] = butter(8, Wn, 'low'); %8阶巴特沃斯滤波器
yt = filter(B, A, st);

Nf = length(st);
Fs = (0:Nf-1)./Nf.*45600;
RT = fft(rt,Nf);			%对FM信号快速傅里叶变换
ST=fft(st,Nf);              %对解调信号快速傅里叶变换
YT=fft(yt,Nf);              %对恢复信号快速傅里叶变换

figure('Position', [100, 200, 900, 500])
subplot(321);                                %生成FM信号的时域波形
plot(t1(1:500), rt(1:500), 'linewidth', 1);                 
%plot(t1, rt, 'linewidth', 1);        
title('r(t)：接收到的FM信号的时域波形');
xlabel('t/s');
legend('r(t)');

subplot(322);                               %生成FM信号的频域波形
semilogy(Fs,abs(fftshift(RT))/max(abs(RT)),'linewidth',1,'Color','g');
title('r(t)_f：接收到的FM信号的频域波形');
xlabel('f/Hz');
legend('R(f)');

subplot(323);                              %生成解调信号的时域图形
plot(t,st,'linewidth',1);
title('s(t)：解调信号的时域波形');
xlabel('t/s');
legend('s(t)');

subplot(324);                               %生成解调信号的频域图形
semilogy(Fs,abs(fftshift(ST))/max(abs(ST)),'linewidth',1,'Color','g');
title('s(t)_f：解调信号的频域波形');
xlabel('f/Hz');
legend('S(f)');

subplot(325);                              %生成恢复信号的时域图形
plot(t,yt,'linewidth',1);
title('y(t)：恢复信号的时域波形');
xlabel('t/s');
legend('y(t)')

subplot(326);                               %生成恢复信号的频域图形
semilogy(Fs,abs(fftshift(YT))/max(abs(YT)),'linewidth',1,'Color','g');
title('y(t)_f：恢复信号的频域波形');
xlabel('f/Hz');
legend('Y(f)');

%audiowrite('pluto_music2.wav', 5*yt, 45600)

%% 释放音频和信号源，并允许更改其属性值和输入特性
release(sigSrc)
release(fmBroadcastDemod)
release(player)