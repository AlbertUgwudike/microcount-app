function err = lof2tiff(input_fn, output_fn)
    cmd = sprintf("java -Xmx8g -jar ./convert/convert.jar '%s' '%s'", input_fn, output_fn);
    err = system(cmd);
end

