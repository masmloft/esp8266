var utils = require("utils.js");

function prepareCompiler(product, input, output)
{
    var args = [];

    if (input.cpp.debugInformation)
        args.push('-g');

    var opt = input.cpp.optimization
    if (opt === 'fast')
        args.push('-O2');
    if (opt === 'small')
        args.push('-Os');
    if (opt === 'none')
        args.push('-O0');

    if (product.cpp.sysroot)
        args.push('--sysroot=' + product.cpp.sysroot);

    if(product.cpp.driverFlags)
        Array.prototype.push.apply(args, product.cpp.driverFlags);

    compilerName = product.cpp.cCompilerName
    if(input.fileTags == "c")
    {
        compilerName = product.cpp.cCompilerName
        args = args.concat(product.cpp.commonCompilerFlags)
        args = args.concat(product.cpp.cFlags)
    }
    if(input.fileTags == "cpp")
    {
        compilerName = product.cpp.cxxCompilerName
        args = args.concat(product.cpp.commonCompilerFlags)
        args = args.concat(product.cpp.cxxFlags)
    }
    if(input.fileTags == "asm_cpp")
    {
        compilerName = product.cpp.cCompilerName
        args = args.concat(product.cpp.commonCompilerFlags)
        args = args.concat(product.cpp.assemblerFlags)
    }

    if (input.cpp.defines)
        args = args.concat([].uniqueConcat(input.cpp.defines).map(function(item) { return "-D" + item; }));
    if (input.cpp.includePaths)
        args = args.concat([].uniqueConcat(input.cpp.includePaths).map(function(item) { return "-I" + item; }));
    args.push('-o', output.filePath);
    args.push('-c', input.filePath);

    var app = product.cpp.toolchainInstallPath + (product.cpp.toolchainPrefix ? "/" + product.cpp.toolchainPrefix : "/") + compilerName;
    var cmd = new Command(app, args);
    cmd.description = "***Compiling " + input.fileName;
    if(product.cpp.verbose)
        cmd.description = "\n" + cmd.description + "\n" + app + " " + args.join(" ");
    return cmd;
}

function prepareStaticLibrary(product, inputs, output)
{
    var args = [];
    args.push('rcs');
    args.push(output.filePath);
    for (i in inputs["obj"])
        args.push(inputs["obj"][i].filePath);

    var app = product.cpp.toolchainInstallPath + (product.cpp.toolchainPrefix ? "/" + product.cpp.toolchainPrefix : "/") + product.cpp.staticLinkerName;
    var cmd = new Command(app, args);
    cmd.description = "***Creating " + output.fileName;
    if(product.cpp.verbose)
        cmd.description = "\n" + cmd.description + "\n" + app + " " + args.join(" ");
    cmd.highlight = "linker";
    return [cmd];
}

function linker_getFlags(product, inputs)
{
    var args = [];

    if(product.cpp.driverFlags)
        Array.prototype.push.apply(args, product.cpp.driverFlags);
    if(product.cpp.driverLinkerFlags)
        Array.prototype.push.apply(args, product.cpp.driverLinkerFlags);

    var linkerFlags = [];
    if(product.consoleApplication === false)
        linkerFlags.push("-subsystem", "windows");
    linkerFlags = linkerFlags.concat(product.cpp.linkerFlags)

    if(linkerFlags.length > 0)
        args = args.concat([["-Wl"].concat(linkerFlags).join(',')]);

    return args;
}

//Array.prototype.unshift
//Array.prototype.push
function linker_appendLibs(outputs, inputs, get, addfunc)
{
    if(inputs)
    {
        var ret = [];
        for (i in inputs)
        {
            //console.info(inputs[i])
            var item = get(inputs[i]);
            if (FileInfo.isAbsolutePath(item) || item.startsWith('@'))
                addfunc.call(ret, item);
            else
                addfunc.call(ret, "-l" + item);
        }
        //outputs = outputs.uniqueConcat(ret);
        outputs = outputs.concat(ret);
    }
    //console.info(outputs);
    return outputs;
}

function prepareApplicationLinker(product, inputs, output)
{
    var args = [];

    args = args.concat(linker_getFlags(product, inputs));

    args = args.uniqueConcat(product.cpp.libraryPaths.map(function(a) { return '-L' + a }));

    //throw product.cpp.linkerScripts;
    for (i in product.cpp.linkerScripts)
        args.push("-T",product.cpp.linkerScripts[i]);

    args.push("-Wl,--start-group");
    for (i in inputs["obj"])
        args.push(inputs["obj"][i].filePath);

    args = linker_appendLibs(args, inputs.staticlibrary, function(a) { return a.filePath; }, Array.prototype.unshift);
    args = linker_appendLibs(args, inputs.dynamiclibrary_import, function(a) { return a.filePath; }, Array.prototype.unshift);

    //throw product.cpp.staticLibraries

    args = linker_appendLibs(args, product.cpp.staticLibraries, function(a) { return a; }, Array.prototype.push);
    args = linker_appendLibs(args, product.cpp.dynamicLibraries, function(a) { return a; }, Array.prototype.push);

    args.push("-Wl,--end-group");

    args.push('-o', output.filePath);

    var app = product.cpp.toolchainInstallPath + (product.cpp.toolchainPrefix ? "/" + product.cpp.toolchainPrefix : "/") + product.cpp.linkerName;

    var cmd = new Command(app, args);
    cmd.description = "***Linking " + output.fileName;
    if(product.cpp.verbose)
        cmd.description = "\n" + cmd.description + "\n" + app + " " + args.join(" ");
    cmd.highlight = "linker";
    return [cmd];
}
