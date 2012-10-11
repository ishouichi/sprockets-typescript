var Compiler;
(function (Compiler) {
    Compiler.TypeScriptError = function (message) {
        this.message = "TypeScript compiler: " + message;
    }

    var Resolver = function (environment, settings) {
        this.environment = environment;
        this.settings = settings;
        this.visited = {};
    }
    Resolver.prototype.resolveCode = function (unit, parentContext, asResident) {
        var resolvedUnit = new TypeScript.SourceUnit();
        resolvedUnit.path = parentContext.resolve(unit.path);
        if (!this.visited[resolvedUnit.path]) {
            var context;
            if (!unit.content) {
                result = parentContext.evaluate(resolvedUnit.path);
                resolvedUnit.content = result.content;
                context = result.context;
            } else {
                resolvedUnit.content = unit.content;
            }
            if (resolvedUnit.content) {
                var preProcessedFileInfo = TypeScript.preProcessFile(resolvedUnit, this.settings);
                for (var i = 0; i < preProcessedFileInfo.referencedFiles.length; i++) {
                    var referencedUnit = preProcessedFileInfo.referencedFiles[i];
                    var resolvedPath = (context ? context : parentContext).resolve(referencedUnit.path);
                    if (resolvedPath == resolvedUnit.path) {
                        throw new Compiler.TypeScriptError("File contains reference to itself (" + resolvedUnit.path + ")");
                    }
                    this.resolveCode(referencedUnit, (context ? context : parentContext), true);
                    if (!context) {
                        parentContext.depends_on(referencedUnit.path);
                    }
                }

                for (var i = 0; i < preProcessedFileInfo.importedFiles.length; i++) {
                    var importedUnit = preProcessedFileInfo.importedFiles[i];
                    this.resolveCode(importedUnit, (context ? context : parentContext), true);
                    if (!context) {
                        parentContext.require(importedUnit.path);
                    }
                }
            }

            if (asResident) {
                this.environment.residentCode.push(resolvedUnit);
            } else {
                this.environment.code.push(resolvedUnit);
            }
            this.visited[resolvedUnit.path] = true;
        }
    }

    function resolve(environment, settings) {
        var resolvedEnvironment = new TypeScript.CompilationEnvironment(settings, null);
        var resolver = new Resolver(resolvedEnvironment, settings);

        for (var i = 0; i < environment.residentCode.length; i++) {
            resolver.resolveCode(environment.residentCode[i], Ruby.context, true);
        }

        for (var i = 0; i < environment.code.length; i++) {
            resolver.resolveCode(environment.code[i], Ruby.context, false);
        }

        return resolvedEnvironment;
    }

    Compiler.compile = function () {
        var settings = new TypeScript.CompilationSettings();
        var environment = new TypeScript.CompilationEnvironment(settings, null);

        for (var i = 0; i < Ruby.additionalUnits.length; i++) {
            var unit = new TypeScript.SourceUnit(Ruby.additionalUnits[i].path, Ruby.additionalUnits[i].content);
            environment.residentCode.push(unit);
        }
        var mainUnit = new TypeScript.SourceUnit(Ruby.source.path, Ruby.source.content);
        environment.code.push(mainUnit);

        // resolve if we have context
        var resolvedEnvironment = Ruby.context ? resolve(environment) : environment;

        var result = {
            source: "",
            Write: function (s) { this.source += s; },
            WriteLine: function (s) { this.source += s + "\n"; },
            Close: function () {}
        }

        var compilerUnits = [];

        var compiler = new TypeScript.TypeScriptCompiler(result, null, new TypeScript.NullLogger(), settings);
        compiler.parser.errorRecovery = true;
        compiler.setErrorCallback(function (minChar, charLen, message, unitIndex) {
            compiler.errorReporter.hasErrors = true;
            var filename = compilerUnits[unitIndex].path;
            var msg = filename + " (" + compiler.parser.scanner.line + "," + compiler.parser.scanner.col + "): " + message;
            throw new Compiler.TypeScriptError(msg);
        });

        for (var i = 0; i < resolvedEnvironment.residentCode.length; i++) {
            try {
                var unit = resolvedEnvironment.residentCode[i];
                compilerUnits.push(unit);
                compiler.addUnit(unit.content, unit.path, true);
            } catch (err) {
                throw err;
            }
        }
        for (var i = 0; i < resolvedEnvironment.code.length; i++) {
            try {
                var unit = resolvedEnvironment.code[i];
                compilerUnits.push(unit);
                compiler.addUnit(unit.content, unit.path, false);
            } catch (err) {
                throw err;
            }
        }

        compiler.typeCheck();
        var createFile = function (filename) { return result; }
        compiler.emit(false, createFile);

        return result.source;
    }
})(Compiler || (Compiler = {}))
