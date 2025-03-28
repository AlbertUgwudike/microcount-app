classdef ( Abstract ) Component < matlab.ui.componentcontainer.ComponentContainer

    properties (Access = public) 
        RegistrarFnc
    end

    methods

        function obj = Component(parent)
            arguments
                parent = []
            end
            % Do not create a default figure parent for the component, and
            % ensure that the component spans its parent. By default,
            % ComponentContainer objects are auto-parenting - that is, a
            % figure is created automatically if no parent argument is
            % specified.
            obj@matlab.ui.componentcontainer.ComponentContainer( ... 
                "Parent", parent, ... 
                "Units", "normalized", ... 
                "Position", [0, 0, 1, 1] ...
            ) 
        end

    end 

    methods (Access = public)

        function call_registrar(comp, event, data)
            arguments
                comp
                event
                data = []
            end
            comp.RegistrarFnc{1}(event, data)
        end
    end

    methods (Access = protected)
        function update(~)
            % Default implementation is empty as
            % we do not rely on this for updates
        end

        setup(~)
    end

end