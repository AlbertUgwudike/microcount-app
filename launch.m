function launch(f) 
%LAUNCHMVCAPP Launch the small MVC application. 

arguments
    f(1, 1) matlab.ui.Figure = uifigure() 
end

% Rename figure.
f.Name = "Microcount"; 
f.Position = [1 1 714 631];
am = Model; 
% Create the home view and controller.
ac = AppController(am); 
vw = AppView(am, ac, 'Parent', f); 


end