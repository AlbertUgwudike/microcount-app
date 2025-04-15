function err = lof2tiff(app_dir, input_fn, output_fn)
    cmd = sprintf('java -Xmx8g -jar "%s/convert/convert.jar" "%s" "%s"', app_dir, input_fn, output_fn);
    disp(cmd)
    err = system(cmd);
end

