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
        AverageSchollIndex (1, 1) double
        AverageBranchAreaUm2 (1, 1) double
        AverageTotalBranchLengthUm (1, 1) double
        PercentageBranchArea (1, 1) double
        ProcessLengthUmPerMm2 (1, 1) double
        RegionAreaMm2 (1, 1) double
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
                args.AverageSchollIndex
                args.AverageBranchAreaUm2
                args.AverageTotalBranchLengthUm
                args.PercentageBranchArea
                args.ProcessLengthUmPerMm2
                args.RegionAreaMm2
            end

            obj.MicrogliaDensity = args.MicrogliaDensity;
            obj.PercentageIba1Area = args.PercentageIba1Area;
            obj.PercentageCD68Area = args.PercentageCD68Area;
            obj.PercentageActivatedMicroglia = args.PercentageActivatedMicroglia;
            obj.AverageRotundity = args.AverageRotundity;
            obj.AverageSomaSizeUm = args.AverageSomaSizeUm;
            obj.AverageBranchCount = args.AverageBranchCount;
            obj.AverageBranchLengthUm = args.AverageBranchLengthUm;
            obj.AverageSchollIndex = args.AverageSchollIndex;
            obj.AverageBranchAreaUm2 = args.AverageBranchAreaUm2;
            obj.AverageTotalBranchLengthUm = args.AverageTotalBranchLengthUm;
            obj.PercentageBranchArea = args.PercentageBranchArea;
            obj.ProcessLengthUmPerMm2 = args.ProcessLengthUmPerMm2;
            obj.RegionAreaMm2 = args.RegionAreaMm2;
        end
    end
end

