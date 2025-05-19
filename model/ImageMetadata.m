classdef ImageMetadata < handle
    
    properties (SetAccess = private)
        SourceFn (1, 1) string
        DownFn (1, 1) string
        ConvFn (1, 1) string
        WS_Dir (1, 1) string
        ID (1, 1) string

        Size (1, 2) uint16
        DownSize (1, 2) uint16

        ChannelCount (1, 1) uint16 = 0
        RegistrationChannel (1, 1) uint16
        CellMarkerChannel (1, 1) uint16
        CoMarkerChannel (1, 1) uint16
    end

    properties
        ConvertStatus (1, 1) ConvertStatus = ConvertStatus.UNCONVERTED
        ConversionProgress (1, 1) double = 0;
        Aligned (1, 1) logical = false
        TransformationData TransformationData
        Regions (:, 1) Region = Region.empty()
    end
    
    methods
        function img_md = ImageMetadata(source_fn, ws_dir)
            arguments
                source_fn (1, 1) string
                ws_dir (1, 1) string
            end
            img_md.SourceFn = source_fn;
            [~, fn, ~] = fileparts(source_fn);
            img_md.ID = fn;
            img_md.DownFn = ImageMetadata.get_down_fn(fn, ws_dir);
            img_md.ConvFn = ImageMetadata.get_conv_fn(fn, ws_dir);
            img_md.WS_Dir = ws_dir;
            disp(img_md.WS_Dir)
        end

        function set_metadata(img_md)
            info = imfinfo(img_md.ConvFn);
            H = [info.Height];
            W = [info.Width];
            img_md.Size = [H(1), W(1)];

            img_md.ChannelCount = max([info.SamplesPerPixel, numel(info)]);
            img_md.RegistrationChannel = 1;
            img_md.CellMarkerChannel = 1 + mod(1, img_md.ChannelCount);
            img_md.CoMarkerChannel = 1 + mod(2, img_md.ChannelCount);

            info = imfinfo(img_md.DownFn);
            H = [info.Height];
            W = [info.Width];
            img_md.DownSize = [H(1), W(1)];
        end

        function add_region_save_mask(img_md, region, atlas)
            arguments
                img_md ImageMetadata
                region Region
                atlas Atlas
            end

            dn_mask = atlas.create_dn_size_mask(region);
            bbox = bounding_box(dn_mask);

            if isempty(bbox)
                fprintf("Region::add_region_save_mask - bbox empty - %s\n", region.ID)
                return;
            end

            bbox = bbox - [0, 0, 1, 1];

            img_md.Regions = cat(1, img_md.Regions, region);

            dn_img = imread(img_md.DownFn);
            c_mask = imcrop(dn_mask, bbox);
            r_mask = repmat(c_mask, 1, 1, size(dn_img, 3));

            dn_region = Utility.imcrop(dn_img, bbox);
            dn_region(r_mask == 0) = 0;
            dn_region = cat(3, dn_region(:, :, img_md.CellMarkerChannel), dn_region(:, :, img_md.CoMarkerChannel), zeros(size(c_mask)));

            imwrite(dn_region, region.MaskFn);
        end


        function locs = all_locations(img_md)
            arguments
                img_md ImageMetadata
            end

            locs = [img_md.Regions.Location];

            if (isempty(locs))
                locs = Location.empty;
            end
        end


        function set_channel_indices(img_md, reg_ch, cell_ch, co_ch)
            arguments
                img_md ImageMetadata
                reg_ch uint16
                cell_ch uint16
                co_ch uint16
            end
            img_md.RegistrationChannel = reg_ch;
            img_md.CellMarkerChannel   = cell_ch;
            img_md.CoMarkerChannel     = co_ch;
        end
        
    end

    methods (Static)

        function down_fn = get_down_fn(id, ws_dir)

            arguments
                id string
                ws_dir string
            end

            down_fn = sprintf( ...
                "%s/%s/%s_%s.tiff", ...
                ws_dir, ...
                Constants.DIR_SLUG_DOWN, ...
                id, ...
                "down" ...
            );
        end

        function conv_fn = get_conv_fn(id, ws_dir)

            arguments
                id string
                ws_dir string
            end

            conv_fn = sprintf( ...
                "%s/%s/%s_%s.tiff", ...
                ws_dir, ...
                Constants.DIR_SLUG_CONVERT, ...
                id, ...
                "conv" ...
            );
        end

        function v = valid_channel_indices(reg_ch, cell_ch, co_ch, N)
            arguments
                reg_ch uint16
                cell_ch uint16
                co_ch uint16
                N
            end
            arr = [reg_ch, cell_ch, co_ch];
            v = all(arr > 0) & all(arr <= N);
        end

    end
end

