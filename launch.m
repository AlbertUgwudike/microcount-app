function launch(f) 

    arguments
        f(1, 1) matlab.ui.Figure = uifigure() 
    end
    
    % Rename figure.
    f.Name = "Microcount"; 
    f.Position = [1 1 714 631];
    
    model = Model();
    
    % Create the home view and controller.
    appView = AppView('Parent', f);
    homeView = HomeView('Parent', appView.HomeTab);
    selectView = SelectImagesView('Parent', appView.SelectTab);
    registerView = RegisterView('Parent', appView.RegisterTab);
    
    AppController(model, appView);
    HomeController(model, homeView);
    SelectImagesController(model, selectView);
    RegisterController(model, registerView);

end