classdef Atlas
    
    properties
        ReferenceAtlas
        AnnotationAtlas
        Size
    end

    properties (Access = private)
        AbrMap containers.Map
        IdxMap containers.Map
    end
    
    methods
        function atlas = Atlas()
            disp('Loading Allen CCF atlas...')
            atlas_path = '~/.brainglobe/allen_mouse_50um_v1.2/';
            atlas.ReferenceAtlas = tiffreadVolume(append(atlas_path, 'reference.tiff'));
            atlas.AnnotationAtlas = tiffreadVolume(append(atlas_path, 'annotation.tiff'));
            atlas.Size = size(atlas.AnnotationAtlas);
            
            s_table_fn = append(atlas_path, 'structures.csv');
            s_table = table2struct(readtable(s_table_fn));

            atlas.IdxMap = atlas.create_idx_map(s_table);
            atlas.AbrMap = atlas.create_abr_map(s_table);

            disp('Done.')
        end

        function borders = calc_borders(atlas, out_sz, tform_data, regions)
            arguments
                atlas Atlas
                out_sz
                tform_data TransformationData
                regions = {}
            end
            ann_image = atlas.AnnotationAtlas(:, :, tform_data.SliceIdx);
            ref_img = imref2d(uint16(out_sz) + [2 * Constants.PAD, 2 * Constants.PAD]);
            tform_mat = tform_data.Transform;
            ali_image = imwarp(ann_image, tform_mat, 'nearest', 'Outputview', ref_img);
            filtered = conv2(ali_image, ones(3) ./ 9, 'same');
            borders = 65536 * uint16(round(filtered) ~= ali_image);
            if ~isempty(regions)
                borders = borders + 65536 * atlas.fill_region(regions, ali_image);
            end
        end

        function idx_set = abr_to_idx_set(atlas, abbr)
            idx = atlas.AbrMap(abbr);
            idx_set = [idx, atlas.IdxMap(idx)];
        end

        function mask = fill_region(atlas, abbrs, ann_slice)
            find_fun  = @(abbr) atlas.abr_to_idx_set(abbr);
            idx_sets  = cellfun(find_fun, abbrs, UniformOutput=false);
            mask      = uint16(zeros(size(ann_slice)));

            for i = 1:numel(idx_sets)
                idx_set = idx_sets{i};
                parent_idx = idx_set(1);
                tmp = ismember(ann_slice, idx_set);
                mask(tmp) = parent_idx;
            end

        end


    end

    methods (Static)

        function imap = create_idx_map(st_table)
            all_idxs = [st_table.id];
            find_fun = @(id) Atlas.child_idxs_from_table(st_table, id);
            idxs = arrayfun(find_fun, all_idxs, 'UniformOutput', false);
            imap = containers.Map(all_idxs, idxs);
        end

        function amap = create_abr_map(st_table)
            all_abrs = {st_table.acronym};
            all_idxs = [st_table.id];
            amap = containers.Map(all_abrs, all_idxs);
        end

        function idxs = child_idxs_from_table(st_table, idx)
            child_idxs = [st_table([st_table.parent_structure_id] == idx).id];
            if numel(child_idxs) == 0
                idxs = child_idxs;
                return
            end
            recursive_find = @(i) Atlas.child_idxs_from_table(st_table, i);
            others = arrayfun(recursive_find, child_idxs, 'UniformOutput', false);
            idxs = [child_idxs, cell2mat(others)];
        end

    end
end

