%% Get the desktop's Java handle (Matlab 7 only)
desktop = com.mathworks.mde.desk.MLDesktop.getInstance;
 
%% Inspect the available desktop functions
%methodsview(desktop);
%uiinspect(desktop);
 
%% Save the current layout
%desktop.saveLayout('Yair');
 
%% Switch between different layouts
%desktop.restoreLayout('Yair');
desktop.restoreLayout('Default');
%desktop.restoreLayout('History and Command Window');

