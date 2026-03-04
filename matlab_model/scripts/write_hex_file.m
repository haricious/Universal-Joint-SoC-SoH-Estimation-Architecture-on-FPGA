function write_hex_file(filename, fx)
    hex_vals = fx.hex;   % char array

    fid = fopen(filename,'w');
    if fid == -1
        error('Cannot open %s', filename);
    end

    for k = 1:size(hex_vals,1)
        fprintf(fid,'%s\n', strtrim(hex_vals(k,:)));
    end

    fclose(fid);
end
