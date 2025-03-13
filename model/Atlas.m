classdef Atlas
    
    properties
        ReferenceAtlas
        AnnotationAtlas
    end
    
    methods
        function atlas = Atlas()
            disp('Loading Allen CCF atlas...')
            atlas_path = '~/.brainglobe/allen_mouse_50um_v1.2/';
            atlas.ReferenceAtlas = tiffreadVolume(append(atlas_path, 'reference.tiff'));
            atlas.AnnotationAtlas = tiffreadVolume(append(atlas_path, 'annotation.tiff'));
            disp('Done.')
        end
    end
end

