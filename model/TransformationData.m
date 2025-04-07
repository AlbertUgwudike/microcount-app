classdef TransformationData

    properties (Access = private)
        ImageSize (1, 2) uint32
    end

    properties
        AtlasHex (6, 2) double
        HistHex (6, 2) double
        Transform affinetform2d
        SliceIdx = 50;
        Direction Direction
        Orientation Orientation
    end
    
    methods
        function obj = TransformationData(hist_hex, atlas_hex, tform_mat, sz, slice_idx, dir, ori)
            arguments
                hist_hex (6, 2) double
                atlas_hex (6, 2) double
                tform_mat affinetform2d
                sz
                slice_idx = 50
                dir Direction = Direction.North
                ori Orientation = Orientation.Axial
            end

            obj.HistHex = hist_hex;
            obj.AtlasHex = atlas_hex;
            obj.Transform = tform_mat;
            obj.ImageSize = sz;
            obj.SliceIdx = slice_idx;
            obj.Direction = dir;
            obj.Orientation = ori;
        end

        function sz = get_img_sz(td)
            if ismember(uint8(td.Direction), [1, 3])
                sz = flip(td.ImageSize);
            else
                sz = td.ImageSize;
            end
        end

        function sz = ori_img_sz(td)
            sz = td.ImageSize;
        end
    end

    methods (Static)
        function tform = default(hist_sz, atlas_sz, n_slices)
            hist_hex = gen_hex(hist_sz);
            atlas_hex = gen_hex(atlas_sz);
            tform_mat = eye(3, 3, "double");
            tform = TransformationData(hist_hex, atlas_hex, tform_mat, hist_sz, n_slices / 2);
        end
    end
end

