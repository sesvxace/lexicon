
Lexicon v1.3 by Solistra and Enelvon
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
functionality of this script is available through simple methods.

  In order to browse the source code of a script, simply use the provided
`SES::Lexicon.browse` method with the file name of the script you wish to
view. Example:

    SES::Lexicon.browse('Game_Interpreter')

  This method opens the given script in the pager, allowing paginated
browsing of the script's source code. Without pagination, it's very likely
that a significant portion of the script may be swallowed by the console's
buffer (especially when viewing large scripts such as `Game_Interpreter`).

  If you need to view a specific line or chunk of source code, you can use
the `SES::Lexicon.line` method. The usage of this method involves providing
the script name, line number, and (optionally) the number of lines around the
requested line number to display as well. For example, if we wanted to view
the `update` method of `Scene_Base` and the 5 lines of code both above and
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

  In addition to this, you can also browse for a specific method definition
using its signature in standard Ruby notation using `SES::Lexicon.find`. For
example, you can jump immediately to the definition of the `update` instance
method of `Scene_Base` or the `return` class method of `SceneManager` like
so:

    SES::Lexicon.find('Scene_Base#update')
    SES::Lexicon.find('SceneManager.return')

  The Lexicon also enables direct reading of the script information that it
stores. This information is provided as a reader method for the Lexicon's
`@scripts` instance variable. The elements of this array store information as
`RGSS_Script` data structures -- each structure includes both the `name` and
`code` methods which provide the expected information when accessed. For
example, if you want to simply print the contents of `Main` to the console,
you could use the following:

    puts SES::Lexicon.scripts[-2].code

Using the Pager
-----------------------------------------------------------------------------
  The Lexicon's pager paginates large text so that it can be viewed in pages
which may be navigated with commands. When using the pager, you will come
across a string at the bottom of the paged output with `>>` at the end of it;
this indicates that a command is expected.

  By default, giving no command (by simply pressing Enter) will advance the
pager to the next page of text; this is exactly the same as giving any of the
following commands: `>`, `forward`, `next`, or `down`. You may browse the
previous page of text with `<`, `back`, `prev`, `previous`, or `up`.

  In addition to this, you can browse a specific number of pages forward or
backward in the paginated text by passing a valid integer as the command.
Positive integers advance the text forward, negatives show previous pages of
the text. You may browse between -99 and 99 pages at a time; any number above
or below these values is not a valid command.

  In order to exit the pager, simply pass any of the following commands: `q`,
`quit`, or `exit`. This will cause the pager to immediately terminate and
return the position of the pager in the paginated text.

License
-----------------------------------------------------------------------------
  This script is made available under the terms of the MIT Expat license.
View [this page](http://sesvxace.wordpress.com/license/) for more detailed
information.

Installation
-----------------------------------------------------------------------------
  Place this script below Materials, but above Main. Place this script below
the SES Core (v2.0) script if you are using it.

