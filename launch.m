function launch(f) 

    arguments
        f(1, 1) matlab.ui.Figure = uifigure() 
    end
    
    % Rename figure.
    f.Name = "Microcount"; 
    f.Position = [1 1 714 631];
    
    model = Model();
    
    % Create the home view and controller.
    app_view = AppView(f);
    home_view = HomeView(app_view.HomeTab);
    select_view = SelectImagesView(app_view.SelectTab);
    register_view = RegisterView(app_view.RegisterTab);
    regions_view = RegionsView(app_view.RegionsTab);
    analyse_view = AnalyseView(app_view.AnalyseTab);
    
    AppController(model, app_view);
    HomeController(model, home_view);
    SelectImagesController(model, select_view);
    RegisterController(model, register_view);
    RegionsController(model, regions_view);
    AnalyseController(model, analyse_view);

end