clear

%% �����û�����
%sdrdev('Pluto');
%configurePlutoRadio('AD9364')

%%��������д�����
%userInput = helperFMUserInput;
%%����ϵͳ����
%[fmRxParams,sigSrc] = helperFMConfig(userInput);

%% ���ò�������ʼ��
fmRxParams.FrontEndFrameTime=0.0168;    %0.0193
fmRxParams.FrontEndSampleRate=228e3;    %ȡ5����Ƶ������

%��ʼ��SDR���ն�
sigSrc=comm.SDRRxPluto(...
        'CenterFrequency',98.8e6,...%����Ƶ�� (Hz)
        'GainSource','Manual',...
        'Gain',50,...                      %��������
        'ChannelMapping',1,...
        'BasebandSampleRate',fmRxParams.FrontEndSampleRate,...
        'OutputDataType','single',...
        'SamplesPerFrame',4410);

% ��ʼ��FM�����
fmBroadcastDemod = comm.FMBroadcastDemodulator(...
        'SampleRate', fmRxParams.FrontEndSampleRate, ...
        'FrequencyDeviation', 75e3, ...
        'FilterTimeConstant', 7.5e-5, ...
        'AudioSampleRate', 45600, ...
        'Stereo', true);

% ��ʼ����Ƶ����
player = audioDeviceWriter('SampleRate',45600);
%info(player)

% ��ʼ������ʱ��
radioTime = 0;
totalLost = 0;
lost_frame = single(zeros(4410, 1));
m = 1;

%% �����벥��
if ~isempty(findPlutoRadio)
        %while radioTime < userInput.Duration   %���ò���ʱ�䣨�룩
        %while 1
        while radioTime  < 3
                %����
                [rcv, lost, late] = sigSrc();
                %rcv = sigSrc();
                %lost = 0;
                %late = 1;
                lost_frame(m)=lost;
                m=m+1;

                % ���FM�㲥�źŲ����Ž������Ƶ
                audioSig = fmBroadcastDemod(rcv);
                player(audioSig);

                % ���²���ʱ�䡣��ӿ��ܶ�ʧ������֡ʱ
                radioTime = radioTime + fmRxParams.FrontEndFrameTime + ...
                            double(lost)/fmRxParams.FrontEndSampleRate;
                totalLost = totalLost + lost;
        end
else
        warning('PlutoRadioNotFound')
end
fprintf('Total samples lost: %d (%d frames) \n ', totalLost, totalLost / 4410)
%% ʱ���Ƶ�����

%rx_signal ���յ����ź�
%datavalid ָʾ�����Ƿ�Ϸ�
%overflowָʾ�����Ƿ����
[rx_signal,datavalid,overflow] = sigSrc();
rt = real(rx_signal(:,1));
t1 = (0: length(rt)-1)./45600;

%st = demod(real(rx_signal)',fc,fs,'fm');
st = audioSig(:, 1);
t = (0: length(st)-1)./45600;
Wn = 8000*2/45600;
[B, A] = butter(8, Wn, 'low'); %8�װ�����˹�˲���
yt = filter(B, A, st);

Nf = length(st);
Fs = (0:Nf-1)./Nf.*45600;
RT = fft(rt,Nf);			%��FM�źſ��ٸ���Ҷ�任
ST=fft(st,Nf);              %�Խ���źſ��ٸ���Ҷ�任
YT=fft(yt,Nf);              %�Իָ��źſ��ٸ���Ҷ�任

figure('Position', [100, 200, 900, 500])
subplot(321);                                %����FM�źŵ�ʱ����
plot(t1(1:500), rt(1:500), 'linewidth', 1);                 
%plot(t1, rt, 'linewidth', 1);        
title('r(t)�����յ���FM�źŵ�ʱ����');
xlabel('t/s');
legend('r(t)');

subplot(322);                               %����FM�źŵ�Ƶ����
semilogy(Fs,abs(fftshift(RT))/max(abs(RT)),'linewidth',1,'Color','g');
title('r(t)_f�����յ���FM�źŵ�Ƶ����');
xlabel('f/Hz');
legend('R(f)');

subplot(323);                              %���ɽ���źŵ�ʱ��ͼ��
plot(t,st,'linewidth',1);
title('s(t)������źŵ�ʱ����');
xlabel('t/s');
legend('s(t)');

subplot(324);                               %���ɽ���źŵ�Ƶ��ͼ��
semilogy(Fs,abs(fftshift(ST))/max(abs(ST)),'linewidth',1,'Color','g');
title('s(t)_f������źŵ�Ƶ����');
xlabel('f/Hz');
legend('S(f)');

subplot(325);                              %���ɻָ��źŵ�ʱ��ͼ��
plot(t,yt,'linewidth',1);
title('y(t)���ָ��źŵ�ʱ����');
xlabel('t/s');
legend('y(t)')

subplot(326);                               %���ɻָ��źŵ�Ƶ��ͼ��
semilogy(Fs,abs(fftshift(YT))/max(abs(YT)),'linewidth',1,'Color','g');
title('y(t)_f���ָ��źŵ�Ƶ����');
xlabel('f/Hz');
legend('Y(f)');

%audiowrite('pluto_music2.wav', 5*yt, 45600)

%% �ͷ���Ƶ���ź�Դ�����������������ֵ����������
release(sigSrc)
release(fmBroadcastDemod)
release(player)