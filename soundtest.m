function soundtest()
timeLength=0.1;            % ����ʱ������λ��
samples=timeLength*44100;  % Ĭ�ϲ�����44100�������������
H = dsp.AudioRecorder(...
    'NumChannels'   , 1 ,...               % 1 ��ͨ��
    'DeviceDataType', '16-bit integer',... % 16λ����
    'OutputNumOverrunSamples',true,...     % ���������־
    'SamplesPerFrame', samples);           % ��������
[audioIn,~] = step(H);                     % ��һ�β���
figure('Name','ʵʱƵ��','MenuBar'...
    ,'none','ToolBar','none','NumberTitle','off');
xdata=(1:1:samples/2)/timeLength;          
axes1= subplot(1,2,1);
axes2= subplot(1,2,2);
pic= plot(axes1, 1:1:samples, audioIn);    % ��ʼ����Ƶ����ͼ
pic2= bar(axes2,xdata, xdata*0,'r');       % ��ʼ��Ƶ��ͼ
set(axes1,'xlim', [0 samples], 'ylim', ...
    [-0.15 0.15],'XTick',[],'YTick',[] );
set(axes2,'xlim', [min(xdata) max(xdata)], 'ylim',[0 6] , ...
     'xscale','log','XTick',[1 10 100 1e3 1e4],'YTick',[] );
xlabel(axes2,'Ƶ�� (Hz)');
xlabel(axes1,'����');
axes2.Position=[0.040 0.48 00.92 0.48]; % ���£���ȣ��߶�
axes1.Position=[0.040 0.06 0.92 0.25];
drawnow;
 while 3>2
   [audioIn,Overrun] = step(H);        % ����
   if Overrun > 0
      warning('  ������� %d λ\n',Overrun);
   end
   ydata_fft=fft(audioIn);             % ����Ҷ�任
   ydata_abs=abs(ydata_fft(1:samples/2));% ȡ����ֵ
   set(pic, 'ydata',audioIn);          % ���²���ͼ����
   set(pic2, 'ydata',log(ydata_abs));  % ����Ƶ��ͼ����
   drawnow;                            % ˢ��
end
end