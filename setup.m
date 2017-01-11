function setup()
    persistent iniFlag
    if isempty(iniFlag)
        addpath('elements');
        addpath('mesh');
        addpath('export');
        addpath('postProcess');
        iniFlag = true;
    end
end