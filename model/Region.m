classdef Region < handle
    
    properties (SetAccess = private)
        Parent ImageMetadata
        Location Location
        ID (1, 1) string
        MaskFn (1, 1) string
        ProcFn (1, 1) string
        SchollFn (1, 1) string
    end

    properties
        Iba1Threshold (1, 1) double
        CD68Threshold (1, 1) double
        MaxCD68Size (1, 1) uint32
        OverlapPercentage (1, 1) double
        SomaThreshold (1, 1) double
        ProcessStatus (1, 1) ProcessStatus = ProcessStatus.UNPROCESSED
        Result MicrocountResult = MicrocountResult.empty
    end
    
    methods
        function region = Region(img_md, location, iba1, cd68, cd68_max, act, soma)
            region.Parent   = img_md;
            region.Location = location;
            region.ID       = Region.generate_id(img_md.ID, location);
            region.MaskFn   = Region.get_mask_fn(img_md.WS_Dir, region.ID);
            region.ProcFn   = Region.get_proc_fn(img_md.WS_Dir, region.ID);
            region.SchollFn = Region.get_scholl_fn(img_md.WS_Dir, region.ID);

            region.Iba1Threshold = iba1;
            region.CD68Threshold = cd68;
            region.MaxCD68Size   = cd68_max;
            region.OverlapPercentage = act;
            region.SomaThreshold = soma;
        end

        function apply_setting_str_list(reg, setting_list)
            parsed_list = double(setting_list);
            reg.Iba1Threshold = parsed_list(1);
            reg.CD68Threshold = parsed_list(2);
            reg.MaxCD68Size = uint32(parsed_list(3));
            reg.OverlapPercentage = parsed_list(4);
            reg.SomaThreshold = parsed_list(5);
        end

        function str_list = get_setting_str_list(reg)
            iba1 = sprintf("%0.2f", reg.Iba1Threshold);
            cd68 = sprintf("%0.2f", reg.CD68Threshold);
            max_cd68 = string(reg.MaxCD68Size);
            soma = sprintf("%0.2f", reg.SomaThreshold);
            act = sprintf("%0.2f", reg.OverlapPercentage);
            str_list = [iba1, cd68, max_cd68, act, soma];
        end

        function settings = get_microcount_settings(region)
            arguments
                region Region
            end
            
            settings = MicrocountSettings( ...
                region.Parent.PixelDims, ...
                region.Parent.CellMarkerChannel, ...
                region.Parent.CoMarkerChannel, ...
                region.Iba1Threshold, ...
                region.CD68Threshold, ...
                region.MaxCD68Size, ...
                region.OverlapPercentage, ...
                region.SomaThreshold ...
            );

        end

        function fn = compute_proc_fn(region, ws_dir)
            arguments
                region Region
                ws_dir string
            end

            fn = sprintf( ...
                "%s/%s/%s.tiff", ...
                ws_dir, ...
                Constants.DIR_SLUG_PROC, ...
                region.ID ...
            );
        end
        
        function mask_fn = compute_mask_fn(region, ws_dir)

            arguments
                region Region
                ws_dir string
            end

            mask_fn = sprintf( ...
                "%s/%s/%s.tiff", ...
                ws_dir, ...
                Constants.DIR_SLUG_MASK, ...
                region.ID ...
            );
        end

        function mask_fn = compute_scholl_fn(region, ws_dir)

            arguments
                region Region
                ws_dir string
            end

            mask_fn = sprintf( ...
                "%s/%s/%s.xlsx", ...
                ws_dir, ...
                Constants.DIR_SLUG_SCHOLL, ...
                region.ID ...
            );
        end

    end

    methods (Static)
        function region = default_settings(img_md, location)
            arguments
                img_md ImageMetadata
                location Location
            end

            % This is where the ambiguity of whole image spec is resolved
            if location.RegionKey == RegionKey.WI
                location.Laterality = Laterality.BILAT;
            end

            region = Region(img_md, location, 0.35, 0.5, 10000, 2, 0.45);
        end

        function id = generate_id(identifier, location)
            id = identifier + "__" + string(location.RegionKey) + "__" + string(location.Laterality);
        end

        function [idenitifer, location] = decode_id(id)
            comps = split(id, "__");
            idenitifer = comps(1);
            region_key = RegionKey(comps(2));
            laterality = Laterality(comps(3));
            location = Location(region_key, laterality);
        end

        function valid = valid_setting_str_list(str_list)
            arguments
                str_list (:, 1) string
            end
            valid = ~any(arrayfun(@(n) isnan(double(n)), str_list));
        end

        function fn = get_proc_fn(ws_dir, id)
            arguments
                ws_dir string
                id string
            end

            fn = sprintf( ...
                "%s/%s/%s.tiff", ...
                ws_dir, ...
                Constants.DIR_SLUG_PROC, ...
                id ...
            );
        end
        
        function mask_fn = get_mask_fn(ws_dir, id)

            arguments
                ws_dir string
                id string
            end

            mask_fn = sprintf( ...
                "%s/%s/%s.tiff", ...
                ws_dir, ...
                Constants.DIR_SLUG_MASK, ...
                id ...
            );
        end

        function mask_fn = get_scholl_fn(ws_dir, id)

            arguments
                ws_dir string
                id string
            end

            mask_fn = sprintf( ...
                "%s/%s/%s.xlsx", ...
                ws_dir, ...
                Constants.DIR_SLUG_SCHOLL, ...
                id ...
            );
        end
    end
end

