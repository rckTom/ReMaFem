classdef shellControlClass
    %Parameters: 
    %elemForm: Element forumulation
    %          0 = Analytical
    %          1 = Numerical with gauss quadratur
    %nip: Number of Integration points, default = 4
    properties
        elemForm 
        nip
        t
    end
    methods
        function obj = shellControlClass(t,varargin)
            p = inputParser();
            addRequired(p,'t');
            addParameter(p,'elementForm',0);
            addParameter(p,'nip',4);
            
            parse(p,t,varargin{:});
            
            obj.elemForm = p.Results.elementForm;
            obj.nip = p.Results.nip;
            obj.t = p.Results.t;
        end
        
        function [valid,errMessage] = validate(obj)
            inputCorrect = isnumeric(obj.nip)&&isnumeric(obj.t)&&isnumeric(obj.elemForm);
            if obj.nip ~= 4 || ~inputCorrect
                valid = false;
                errMessage = 'Number of Integrationpoints not supported';
            else
                valid = true;
            end
        end
    end
end