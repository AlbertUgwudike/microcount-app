function err = lof2tiff(input_fn, output_fn)
    f = @(fn)replace(fn," ","\ ");
    f = @(fn) fn;
    cmd = sprintf("java -Xmx8g -jar ./convert/convert.jar '%s' '%s'", f(input_fn), f(output_fn));
    disp(cmd)
    err = system(cmd);
end

