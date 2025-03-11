function launch(f) 
%LAUNCHMVCAPP Launch the small MVC application. 

arguments
    f(1, 1) matlab.ui.Figure = uifigure() 
end

% Rename figure.
f.Name = "Small MVC App"; 


f.Position = [1 1 714 631];
% f.BackgroundColor = [0.94 0.94 0.94];

% Create the layout.
% g = uigridlayout( ... 
%     "Parent", f, ... 
%     "RowHeight", {"1x", 40}, ... 
%     "ColumnWidth", "1x" ); 

% Create the model.
am = Model; 

% Create the home view and controller.
ac = AppController(am); 
vw = AppView(am, ac, 'Parent', f); 

% Create toolbar to reset the model.
% icon = fullfile( matlabroot, ...
% "toolbox", “matlab”, “icons”, “tool_rotate_3d.png” ); 
% tb = uitoolbar( "Parent", f ); 
% uipushtool( ... 
%     "Parent", tb, ... 
%     "Icon", icon, ... 
%     "Tooltip", "Reset the data.", ... 
%     "ClickedCallback", @onReset ); 
% 
%     function onReset( ~, ~ ) 
%         %ONRESET Callback function for the toolbar reset button.
% 
%         % Reset the model.
%         reset( m ) 
% 
%     end
% 
% % Return the figure handle if requested.
% if nargout > 0 
%     nargoutchk( 1, 1 ) 
%     varargout{1} = f; 
% end % if

end