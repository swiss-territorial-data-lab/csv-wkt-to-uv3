
    % csv_wkt_to_uv3
    %
    %     Nils Hamel - nils.hamel@alumni.epfl.ch
    %     Huriel Reichel
    %     Copyright (c) 2020 STDL, Swiss Territorial Data Lab
    %
    % This program is free software: you can redistribute it and/or modify
    % it under the terms of the GNU General Public License as published by
    % the Free Software Foundation, either version 3 of the License, or
    % (at your option) any later version.
    %
    % This program is distributed in the hope that it will be useful,
    % but WITHOUT ANY WARRANTY; without even the implied warranty of
    % MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    % GNU General Public License for more details.
    %
    % You should have received a copy of the GNU General Public License
    % along with this program.  If not, see <http://www.gnu.org/licenses/>.

    function csv_wkt_to_uv3( cv_file, cv_delimiter, cv_color, cv_uv3 )

        % Standard color map - Stolen form python matplotlib (tab20b and tab20c)
        cv_cmap = uint8([
        0.19215686, 0.50980392, 0.74117647;
        0.41960784, 0.68235294, 0.83921569;
        0.61960784, 0.79215686, 0.88235294;
        0.77647059, 0.85882353, 0.9372549 ;
        0.90196078, 0.33333333, 0.05098039;
        0.99215686, 0.55294118, 0.23529412;
        0.99215686, 0.68235294, 0.41960784;
        0.99215686, 0.81568627, 0.63529412;
        0.19215686, 0.63921569, 0.32941176;
        0.45490196, 0.76862745, 0.4627451 ;
        0.63137255, 0.85098039, 0.60784314;
        0.78039216, 0.91372549, 0.75294118;
        0.51764706, 0.23529412, 0.22352941;
        0.67843137, 0.28627451, 0.29019608;
        0.83921569, 0.38039216, 0.41960784;
        0.90588235, 0.58823529, 0.61176471;
        0.48235294, 0.25490196, 0.45098039;
        0.64705882, 0.31764706, 0.58039216;
        0.80784314, 0.42745098, 0.74117647;
        0.87058824, 0.61960784, 0.83921569;
        ] * 255 );

        % Extract desired colormap - Modular condition to ensure index in 1:20
        cv_cmap = cv_cmap( mod(cv_color-1,20)+1, 1:3 );

        % initialise color array %
        cv_color = zeros( 1, 3 );

        % create target table - add your own target in addition to WKT
        cv_target{1} = 'WKT';
        cv_target{2} = 'MSL';
        cv_target{3} = 'R';
        cv_target{4} = 'G';
        cv_target{5} = 'B';
        cv_target{6} = 'X';
        cv_target{7} = 'Y';

        % create input stream
        cv_stream = fopen( cv_file, 'r' );

        % check input stream
        if ( cv_stream < 0 )

            % show message %
            error( 'unable to open stream' );

        end

        % create output stream
        cv_export = fopen( cv_uv3, 'w' );

        % check output stream
        if ( cv_export < 0 )

            % show message
            error( 'unable to create stream' );

        end

        % extract CSV header for targets detection
        cv_header = fgetl( cv_stream );

        % decompose CSV header for target detection
        cv_header = strsplit( cv_header, cv_delimiter, 'CollapseDelimiters', false );

        % initialise data pointer array
        cv_data = cell( size( cv_target ) );

        % anylyze header for target detection
        for cv_j = 1 : size( cv_header, 2 )

            % loop on specified target to search
            for cv_i = 1 : size( cv_target, 2 )

                % target detection condition
                if ( strfind(cv_header{cv_j}, cv_target{cv_i}) )

                    % save target position in CSV header
                    cv_data{cv_i} = cv_j;

                end

            end

        end

        % start importing CSV line by line
        cv_line = fgetl( cv_stream );

        % CSV analysis line by line
        while ( ischar(cv_line) )

            % decompose CSV line %
            cv_split = strsplit( cv_line, cv_delimiter, 'CollapseDelimiters', false );

            % check for WKT %
            if ( cv_data{1} > 0 )

                % detect third dimension in WKT
                if ( strfind( cv_split{1,cv_data{1}}, ' Z ' ) )

                    % three dimension vertex
                    cv_vertex = 3;

                else

                    % two dimension vertex
                    cv_vertex = 2;

                end

                % extract and simplify WKT geometry
                cv_element = csv_wkt_to_uv3_readwkt( cv_split{1,cv_data{1}} );

            else

                % check for external x, y %
                if ( ( cv_data{6} > 0 ) && ( cv_data{7} > 0 ) )

                    % create coordinates string %
                    cv_element{1,1} = [ strrep( cv_split{1,cv_data{6}}, '"', ' ' ) " " strrep( cv_split{1,cv_data{7}}, '"', ' ' ) " 0" ];
                
                    % two dimension vertex
                    cv_vertex = 3;

                end

            end

            % check for elevation
            if ( cv_data{2} > 0 )

                % read elevation %
                cv_elevation = double( str2num( strrep( cv_split{1,cv_data{2}}, '"', ' ' ) ) );

            else

                % initialise elevation %
                cv_elevation = [];

            end

            % check for r
            if ( cv_data{3} > 0 )

                % read r %
                cv_color(1) = double( str2num( strrep( cv_split{1,cv_data{3}}, '"', ' ' ) ) );

            else

                % initialise r %
                cv_color(1) = cv_cmap(1);

            end

            % check for g
            if ( cv_data{4} > 0 )

                % read r %
                cv_color(2) = double( str2num( strrep( cv_split{1,cv_data{4}}, '"', ' ' ) ) );

            else

                % initialise r %
                cv_color(2) = cv_cmap(2);

            end

            % check for b
            if ( cv_data{5} > 0 )

                % read r %
                cv_color(3) = double( str2num( strrep( cv_split{1,cv_data{5}}, '"', ' ' ) ) );

            else

                % initialise r %
                cv_color(3) = cv_cmap(3);

            end

            % process WKT elements
            for cv_i = 1 : size( cv_element, 2 )

                % display simplified WTK %
                display(cv_element{cv_i});

                % export WKT in output UV3 stream
                csv_wkt_to_uv3_export( cv_element{cv_i}, cv_vertex, cv_color, cv_elevation, cv_export );

            end

            % read CSV next line
            cv_line = fgetl( cv_stream );

        end

        % delete output stream %
        fclose( cv_export );

        % delete input stream %
        fclose( cv_stream );

    end

    function cv_element = csv_wkt_to_uv3_readwkt( cv_wkt )

        % parenthesis stack
        cv_push = 0;

        % extracted primitive index
        cv_k = 0;

        % initialise cancel value %
        cv_cancel = 1;

        % parsing simplified WKT geometry
        for cv_i = 1 : length( cv_wkt )

            % parenthesis stack management
            if ( cv_wkt(cv_i) == '(' )

                % push starting position
                cv_push = cv_i;

                % udpate cancel value %
                cv_cancel = 0;

            end

            % parenthesis stack management
            if ( ( cv_wkt(cv_i) == ')' ) && ( cv_cancel == 0 ) )

                % update primitive index
                cv_k = cv_k + 1;

                % push starting and ending position for the line/polygone strip
                cv_token(cv_k,1) = cv_push + 1;
                cv_token(cv_k,2) = cv_i - 1;

                % udpate cancel value %
                cv_cancel = 1;

            end

        end

        % simplify WKT format
        for cv_i = 1 : cv_k

            % remove commas by spaces
            cv_element{cv_i} = strrep( cv_wkt(cv_token(cv_i,1):cv_token(cv_i,2)), ',', ' ' );

        end

    end

    function csv_wkt_to_uv3_export( cv_element, cv_vertex, cv_color, cv_elevation, cv_export )

        % read simplified WKT geometry
        cv_pose = sscanf( cv_element, '%lf' );

        % reshape geometry coordinates array (2 or 3 by n)
        cv_pose = reshape( cv_pose, [ cv_vertex, length( cv_pose ) / cv_vertex ] )';

        % convert coordinates in radian
        cv_pose(:,1) = cv_pose(:,1) * ( pi / 180. );
        cv_pose(:,2) = cv_pose(:,2) * ( pi / 180. );

        % check external elevation %
        if ( isempty( cv_elevation ) == 0 )

            % assign elevation %
            cv_pose(:,3) = cv_elevation;

        end

        % check vertex unicity - export as point
        if ( size( cv_pose, 1 ) == 1 )

            % export coordinates array (UV3)
            fwrite( cv_export, cv_pose(1,1:3), 'double' );

            % export primitive type and color (UV3)
            fwrite( cv_export, [ 1, cv_color ], 'uint8' );

        else % export as lines

            % compute stand-alone line index array
            cv_step = repelem( [1:size(cv_pose,1)], 2 );

            % compose and export linear primitives
            for cv_i = 2 : length( cv_pose ) - 1

                % export coordinates array (UV3)
                fwrite( cv_export, cv_pose(cv_step(cv_i),1:3), 'double' );

                % export primitive type and color (UV3)
                fwrite( cv_export, [ 2, cv_color ], 'uint8' );

            end

        end

    end

