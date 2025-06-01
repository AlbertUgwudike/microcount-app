classdef MicrocountResult

    properties
        MicrogliaDensity (1, 1) double
        PercentageIba1Area (1, 1) double
        PercentageCD68Area (1, 1) double
        PercentageActivatedMicroglia (1, 1) double
        AverageRotundity (1, 1) double
        AverageSomaSizeUm (1, 1) double
        AverageBranchCount (1, 1) uint16
        AverageBranchLengthUm (1, 1) double
    end
    
    methods
        function obj = MicrocountResult(args)
            arguments
                args.MicrogliaDensity
                args.PercentageIba1Area
                args.PercentageCD68Area
                args.PercentageActivatedMicroglia
                args.AverageRotundity
                args.AverageSomaSizeUm
                args.AverageBranchCount
                args.AverageBranchLengthUm
            end

            obj.MicrogliaDensity = args.MicrogliaDensity;
            obj.PercentageIba1Area = args.PercentageIba1Area;
            obj.PercentageCD68Area = args.PercentageCD68Area;
            obj.PercentageActivatedMicroglia = args.PercentageActivatedMicroglia;
            obj.AverageRotundity = args.AverageRotundity;
            obj.AverageSomaSizeUm = args.AverageSomaSizeUm;
            obj.AverageBranchCount = args.AverageBranchCount;
            obj.AverageBranchLengthUm = args.AverageBranchLengthUm;
        end
    end
end

