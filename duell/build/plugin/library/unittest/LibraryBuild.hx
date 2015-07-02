package duell.build.plugin.library.unittest;

class LibraryBuild
{
    public function new()
    {
    }

    public function postParse() : Void
    {
        /// if no parsing is made we need to add the default state.
        if (Configuration.getData().LIBRARY.OPENGL == null)
        {
            Configuration.getData().LIBRARY.OPENGL = LibraryConfiguration.getData();
        }

        var haxeExtraSources = Path.join([Configuration.getData().OUTPUT,"haxe"]);
        if (Configuration.getData().SOURCES.indexOf(haxeExtraSources) == -1)
        {
            Configuration.getData().SOURCES.push(haxeExtraSources);
        }
    }

    public function preBuild() : Void
    {
//        var libPath : String = DuellLib.getDuellLib("opengl").getPath();
//
//        var exportPath : String = Path.join([Configuration.getData().OUTPUT,"haxe","gl"]);
//
//        var classSourcePath : String = Path.join([libPath,"template","gl"]);
//
//        TemplateHelper.recursiveCopyTemplatedFiles(classSourcePath, exportPath, Configuration.getData(), Configuration.getData().TEMPLATE_FUNCTIONS);
    }

    public function postBuild() : Void
    {
    }
}
