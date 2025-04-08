function [four_way_filters, five_way_filters] = branch_filters()
%BRANCH_FILTERS 14 branch filters for branch detection

    arrow1 = [
        [-1, -1,  1];
        [ 1,  1, -1];
        [-1,  1, -1];
    ];
    
    arrow2 = flip(arrow1);
    arrow3 = arrow1';
    arrow4 = flip(arrow3);

    
    hammer1 = [
        [-1, -1, -1];
        [ 1,  1,  1];
        [-1,  1, -1];
    ];
    
    hammer2 = flip(hammer1);
    hammer3 = hammer1';
    hammer4 = hammer2';
    
    lambda1 = [
        [ 1, -1,  1];
        [-1,  1, -1];
        [-1, -1,  1];
    ];

    lambda2 = flip(lambda1);
    lambda3 = lambda1';
    lambda4 = flip(lambda3);
    
    yesod1 = [
        [ 1, -1,  1];
        [-1,  1, -1];
        [-1,  1, -1];
    ];
    
    yesod2 = flip(yesod1);
    yesod3 = yesod1';
    yesod4 = yesod2';
    
    plus = [
        [-1,  1, -1];
        [ 1,  1,  1];
        [-1,  1, -1];
    ];
    
    times = [
        [ 1, -1,  1];
        [-1,  1, -1];
        [ 1, -1,  1];
    ];
    
    four_way_filters = { 
        arrow1; arrow2; arrow3; arrow4; 
        hammer1; hammer2; hammer3; hammer4; 
        lambda1; lambda2; lambda3; lambda4; 
        yesod1; yesod2; yesod3; yesod4; 
    };

    five_way_filters = {
        plus; times;
    };
end

