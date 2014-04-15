
Lexicon v1.1 by Solistra
=============================================================================

Summary
-----------------------------------------------------------------------------
  This script provides information and browsing capabilities for all of the
RGSS3 scripts that are present in the RPG Maker VX Ace Script Editor. Script
source code may be browsed and paginated in-game with the use of a REPL (such
as the SES Console) or using script calls. This is primarily a scripter's
tool.

Usage
-----------------------------------------------------------------------------
  This script is designed to function entirely through a REPL or script
calls (although the latter is not recommended). As such, all of the available
functionality of this script is available through simple methods. This script
also organizes RGSS3 script information primarily by "file" name -- that is,
the name of the script as defined in the RMVX Ace Script Editor.

  In order to browse the source code of a script, simply use the provided
`SES::Lexicon.browse` method with the file name of the script you wish to
view. Example:

    SES::Lexicon.browse('Game_Interpreter')

  This method opens the given script in the pager, allowing paginated
browsing of the script's source code. Without pagination, it's very likely
that a significant portion of the script may be swallowed by the console's
buffer (especially when viewing large scripts such as Game_Interpreter).

  If you need to view a specific line or chunk of source code, you can use
the `SES::Lexicon.line` method. The usage of this method involves providing
the script name, line number, and (optionally) the number of lines around the
requested line number to display as well. For example, if we wanted to view
the `update` method of Scene_Base and the 5 lines of code both above and
below that method, we would use the following:

    SES::Lexicon.line('Scene_Base', 40, 5)

  There are also two methods provided for information-gathering purposes:
`SES::Lexicon.named` and `SES::Lexicon.defining`. As expected, the `named`
method returns an array of script names containing the given string or
regular expression, and the `defining` method returns an array of scripts
which define or redefine the given class or module. Examples:

    SES::Lexicon.named('Manager')  # => ["DataManager", "SceneManager",
                                   #     "BattleManager"]
    SES::Lexicon.defining('Cache') # => ["Cache"]

  The `defining` method can also take partial class or module names and will
return an array of script names which match the partial information given.
For example, you can easily view which scripts modify any of the Scene_*
classes using `SES::Lexicon.defining('Scene_')`.

  The Lexicon also enables direct reading of the script information that it
stores. This information is provided as a reader method for the Lexicon's
`@scripts` instance variable. The format of this array stores information as
a hash -- each hash includes the `:name` and `:code` keys which provide the
expected information when accessed. For example, if you want to simply print
the contents of Main to the console, you could use the following:

    puts SES::Lexicon.scripts[-2][:code]

License
-----------------------------------------------------------------------------
  This script is made available under the terms of the MIT Expat license.
View [this page](http://sesvxace.wordpress.com/license/) for more detailed
information.

Installation
-----------------------------------------------------------------------------
  Place this script below Materials, but above Main. Place this script below
the SES Core (v2.0) script if you are using it.

