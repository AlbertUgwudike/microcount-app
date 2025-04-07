classdef RegionTree
    %REGIONTREE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Key RegionKey
        Name string
        Descendants (:, 1) RegionTree
    end
    
    methods
        function rt = RegionTree(parent_key, name, child_keys)
            rt.Key = parent_key;
            rt.Name = name;
            rt.Descendants = child_keys;
        end
    end

    methods (Static)

        function rt = generate_tree()
            table_fn = "/Users/vaness/.brainglobe/allen_mouse_100um_v1.2/structures.csv";
            st_table = table2struct(readtable(table_fn));
            kids = RegionTree.create_region_tree(st_table, RegionKey.root);
            rt = RegionTree(RegionKey.root, "Root", kids);
            save("app/assets/RegionTree.mat", "rt");
        end

        function rt = create_region_tree(st_table, parent_key)
            parent_acc = parent_key.Name;
            accs = cellfun(@convertCharsToStrings, { st_table.acronym });
            parent_idx = [st_table(accs == parent_acc).id];
            child_subtable = st_table([st_table.parent_structure_id] == parent_idx);

            child_keys = {child_subtable.acronym};
            child_names = {child_subtable.name};

            N = numel(child_names);

            if N == 0
                rt = RegionTree.empty;
                return;
            end

            rt(1) = RegionTree(parent_key, parent_acc, RegionTree.empty);

            for i = 1:N
                region_key = RegionKey.from_string(child_keys{i});
                kids = RegionTree.create_region_tree(st_table, region_key);
                rt(i + 1) = RegionTree(region_key, child_names{i}, kids);
            end

        end

    end
end

