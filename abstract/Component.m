classdef ( Abstract ) Component < matlab.ui.componentcontainer.ComponentContainer 

    properties ( SetAccess = immutable, GetAccess = public ) 
        Model(1, 1) Model
        Contr
    end

    methods

        function obj = Component( model, controller) 

            arguments
                model(1, 1) Model
                controller
            end % arguments

            % Do not create a default figure parent for the component, and
            % ensure that the component spans its parent. By default,
            % ComponentContainer objects are auto-parenting - that is, a
            % figure is created automatically if no parent argument is
            % specified.
            obj@matlab.ui.componentcontainer.ComponentContainer( ... 
                "Parent", [], ... 
                "Units", "normalized", ... 
                "Position", [0, 0, 1, 1] ) 

            % Store the model.
            obj.Model = model; 
            obj.Contr = controller;

        end

    end 

end