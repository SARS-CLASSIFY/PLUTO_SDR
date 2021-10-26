clear
%% 麦克风录音初始化
timeLength=0.1;            % 采样时长，单位秒
samples=timeLength*44100;  % 默认采样率44100，计算采样点数
H = dsp.AudioRecorder(...
    'NumChannels'   , 1 ,...               % 1 个通道
    'DeviceDataType', '16-bit integer',... % 16位采样
    'OutputNumOverrunSamples',true,...     % 启用溢出标志
    'SamplesPerFrame', samples);           % 采样点数
[audioIn,~] = step(H);                     % 第一次采样



%% 发射初始化
txPluto = sdrtx('Pluto','RadioID','usb:0',...
        'CenterFrequency',92.4e6,...
        'Gain',-0,...
        'ChannelMapping',1,...
        'BasebandSampleRate',228000);
txPluto.ShowAdvancedProperties = true;

afr=dsp.AudioFileReader('Amazing Trees.flac','SamplesPerFrame',44100/2);
adw = audioDeviceWriter('SampleRate', afr.SampleRate);
mod=comm.FMBroadcastModulator('AudioSampleRate',afr.SampleRate, ...
    'SampleRate',txPluto.BasebandSampleRate,'Stereo',false);
%data=audioread('Scarborough Fair.flac');

%% 接收初始化
sigSrc=comm.SDRRxPluto(...
        'CenterFrequency',92.4e6,...%The channel you want to listen to (Hz)
        'GainSource','Manual',...
        'Gain',50,...                       %can control volume
        'ChannelMapping',1,...
        'BasebandSampleRate',228000,...
        'OutputDataType','single',...
        'SamplesPerFrame',45600*5/2);%5.2:发射有少量间断;5似乎行;4.2:接收有间断;4.8:接收过一段时间间断一次

% 初始化解调
fmBroadcastDemod = comm.FMBroadcastDemodulator(...
        'SampleRate', 228000, ...
        'FrequencyDeviation', 75e3, ...
        'FilterTimeConstant', 7.5e-5, ...
        'AudioSampleRate', 45600, ...
        'Stereo', true);

% 创建音频播放器
player = audioDeviceWriter('SampleRate',45600);

%while ~isDone(afr)
while (1)
    
%%    麦克风或音频直接输入调制
       [audioIn,Overrun] = step(H);        % 采样
       if Overrun > 0
          warning('  数据溢出 %d 位\n',Overrun);
       end

    
        data = audioIn;
    
        %data = afr();
        %adw(data); 本机播放
        %data=(data(:,1)+data(:,2))/2;
        data=mod(data);
        underflow=txPluto(data);
%%  解调部分
        
%         rcv = sigSrc();
%         audioSig = fmBroadcastDemod(rcv);
%         player(audioSig);
end
