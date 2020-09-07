
    % csv_wkt_to_uv3
    %
    %     Nils Hamel - nils.hamel@alumni.epfl.ch
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
        cv_color = cv_cmap( mod(cv_color-1,20)+1, 1:3 );

        % create target table - add your own target in addition to WKT
        cv_target{1} = 'WKT';

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
            cv_split = strsplit( cv_line, ';', 'CollapseDelimiters', false );

            % extract and simplify WKT geometry
            cv_element = csv_wkt_to_uv3_readwkt( cv_split{1,cv_data{1}} );

            % process WKT elements
            for cv_i = 1 : size( cv_element, 2 )

                % display simplified WTK %
                display(cv_element{cv_i});

                % export WKT in output UV3 stream
                csv_wkt_to_uv3_export( cv_element{cv_i}, cv_color, cv_export );

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

        % parsing simplified WKT geometry
        for cv_i = 1 : length( cv_wkt )

            % parenthesis stack management
            if ( cv_wkt(cv_i) == '(' )

                % push starting position
                cv_push = cv_i;

            end

            % parenthesis stack management
            if ( cv_wkt(cv_i) == ')' )

                % update primitive index
                cv_k = cv_k + 1;

                % push starting and ending position for the line/polygone strip
                cv_token(cv_k,1) = cv_push + 1;
                cv_token(cv_k,2) = cv_i - 1;

            end

        end

        % simplify WKT format
        for cv_i = 1 : cv_k

            % remove commas by spaces
            cv_element{cv_i} = strrep( cv_wkt(cv_token(cv_i,1):cv_token(cv_i,2)), ',', ' ' );

        end

    end

    function csv_wkt_to_uv3_export( cv_element, cv_color, cv_export )

        % read simplified WKT geometry
        cv_value = sscanf( cv_element, '%lf' );

        % reshape geometry coordinates array (2 by n)
        cv_value = reshape( cv_value, [ 2, length( cv_value ) / 2 ] )';

        % compute stand-alone line index array
        cv_step = repelem( [1:size(cv_value,1)], 2 );

        % compose and export linear primitives
        for cv_i = 2 : length( cv_step ) - 1

            % compute coordinates array (converted in radian)
            cv_pose = [ cv_value(cv_step(cv_i),1:2) * ( pi / 180. ), 0 ];

            % export coordinates array (UV3)
            fwrite( cv_export, cv_pose, 'double' );

            % export primitive type and color (UV3)
            fwrite( cv_export, [ 2, cv_color ], 'uint8' );

        end

    end

