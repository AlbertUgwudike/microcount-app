classdef Direction < uint8
    enumeration
        North (0)
        East  (1)
        South (2)
        West  (3)
    end

    methods
        function new_dir = rotate(dir)
            new_dir = Direction(mod(dir + 1, 4));
        end

        function agl = reverse_angle(dir)
            switch dir
                case Direction.North
                    agl = 0;
                case Direction.East
                    agl = -90;
                case Direction.South
                    agl = 180;
                case Direction.West
                    agl = 90;
            end
        end

        function agl = to_angle(dir)
            switch dir
                case Direction.North
                    agl = 0;
                case Direction.East
                    agl = 90;
                case Direction.South
                    agl = 180;
                case Direction.West
                    agl = -90;
            end
        end
    end
end

