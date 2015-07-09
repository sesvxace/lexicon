#--
# Lexicon v1.3 by Solistra and Enelvon
# =============================================================================
# 
# Summary
# -----------------------------------------------------------------------------
#   This script provides information and browsing capabilities for all of the
# RGSS3 scripts that are present in the RPG Maker VX Ace Script Editor. Script
# source code may be browsed and paginated in-game with the use of a REPL (such
# as the SES Console) or using script calls. This is primarily a scripter's
# tool.
# 
# Usage
# -----------------------------------------------------------------------------
#   This script is designed to function entirely through a REPL or script
# calls (although the latter is not recommended). As such, all of the available
# functionality of this script is available through simple methods.
# 
#   In order to browse the source code of a script, simply use the provided
# `SES::Lexicon.browse` method with the file name of the script you wish to
# view. Example:
# 
#     SES::Lexicon.browse('Game_Interpreter')
# 
#   This method opens the given script in the pager, allowing paginated
# browsing of the script's source code. Without pagination, it's very likely
# that a significant portion of the script may be swallowed by the console's
# buffer (especially when viewing large scripts such as `Game_Interpreter`).
# 
#   If you need to view a specific line or chunk of source code, you can use
# the `SES::Lexicon.line` method. The usage of this method involves providing
# the script name, line number, and (optionally) the number of lines around the
# requested line number to display as well. For example, if we wanted to view
# the `update` method of `Scene_Base` and the 5 lines of code both above and
# below that method, we would use the following:
# 
#     SES::Lexicon.line('Scene_Base', 40, 5)
# 
#   There are also two methods provided for information-gathering purposes:
# `SES::Lexicon.named` and `SES::Lexicon.defining`. As expected, the `named`
# method returns an array of script names containing the given string or
# regular expression, and the `defining` method returns an array of scripts
# which define or redefine the given class or module. Examples:
# 
#     SES::Lexicon.named('Manager')  # => ["DataManager", "SceneManager",
#                                    #     "BattleManager"]
#     SES::Lexicon.defining('Cache') # => ["Cache"]
# 
#   The `defining` method can also take partial class or module names and will
# return an array of script names which match the partial information given.
# For example, you can easily view which scripts modify any of the Scene_*
# classes using `SES::Lexicon.defining('Scene_')`.
# 
#   In addition to this, you can also browse for a specific method definition
# using its signature in standard Ruby notation using `SES::Lexicon.find`. For
# example, you can jump immediately to the definition of the `update` instance
# method of `Scene_Base` or the `return` class method of `SceneManager` like
# so:
# 
#     SES::Lexicon.find('Scene_Base#update')
#     SES::Lexicon.find('SceneManager.return')
# 
#   The Lexicon also enables direct reading of the script information that it
# stores. This information is provided as a reader method for the Lexicon's
# `@scripts` instance variable. The elements of this array store information as
# `RGSS_Script` data structures -- each structure includes both the `name` and
# `code` methods which provide the expected information when accessed. For
# example, if you want to simply print the contents of `Main` to the console,
# you could use the following:
# 
#     puts SES::Lexicon.scripts[-2].code
# 
# Using the Pager
# -----------------------------------------------------------------------------
#   The Lexicon's pager paginates large text so that it can be viewed in pages
# which may be navigated with commands. When using the pager, you will come
# across a string at the bottom of the paged output with `>>` at the end of it;
# this indicates that a command is expected.
# 
#   By default, giving no command (by simply pressing Enter) will advance the
# pager to the next page of text; this is exactly the same as giving any of the
# following commands: `>`, `forward`, `next`, or `down`. You may browse the
# previous page of text with `<`, `back`, `prev`, `previous`, or `up`.
# 
#   In addition to this, you can browse a specific number of pages forward or
# backward in the paginated text by passing a valid integer as the command.
# Positive integers advance the text forward, negatives show previous pages of
# the text. You may browse between -99 and 99 pages at a time; any number above
# or below these values is not a valid command.
# 
#   In order to exit the pager, simply pass any of the following commands: `q`,
# `quit`, or `exit`. This will cause the pager to immediately terminate and
# return the position of the pager in the paginated text.
# 
# License
# -----------------------------------------------------------------------------
#   This script is made available under the terms of the MIT Expat license.
# View [this page](http://sesvxace.wordpress.com/license/) for more detailed
# information.
# 
# Installation
# -----------------------------------------------------------------------------
#   Place this script below Materials, but above Main. Place this script below
# the SES Core (v2.0) script if you are using it.
# 
#++

# SES
# =============================================================================
# The top-level namespace for all SES scripts.
module SES
  # Lexicon
  # ===========================================================================
  # Provides information about the installed RGSS3 scripts present in the RMVX
  # Ace Script Editor.
  module Lexicon
    # =========================================================================
    # BEGIN CONFIGURATION
    # =========================================================================
    
    # The number of lines to show per page within the Lexicon's pager. This is
    # set to `23` by default, which fills the default RGSS Console's window
    # with output from the pager.
    @pager_lines = 23
    
    # The number of lines to surround source code lines queried with the `line`
    # or `chunk` methods of the Lexicon. The number defined here determines the
    # number of lines shown both above and below the line given. Set this to
    # `0` in order to display **only** the requested line.
    @surrounding_lines = 5
    
    # =========================================================================
    # END CONFIGURATION
    # =========================================================================
    class << self
      # @return [Fixnum] the default number of lines to show per page within
      #   the {Lexicon}'s {Pager} instance
      attr_accessor :pager_lines
      
      # @return [Fixnum] the number of lines to surround chunks of source code
      #   with
      attr_accessor :surrounding_lines
      
      # @return [Pager] the {Pager} instance currently used by the {Lexicon}
      attr_reader :pager
      
      # @return [Array<RGSS_Script>] array of script data used by the {Lexicon}
      attr_reader :scripts
    end
    # RGSS_Script
    # =========================================================================
    # A simple structure representing a script present in the script editor.
    RGSS_Script = Struct.new(:name, :code) do
      # @return [String] the name of this RGSS script
      def inspect
        name
      end
      
      # @return [String] the code of this RGSS script
      def to_s
        code
      end
    end
    # Pager
    # =========================================================================
    # Paginates textual input by displaying the given number of lines at a time
    # until the end of input has been reached.
    class Pager
      class << self
        # @return [Fixnum] the number of lines per page for the {Pager}
        attr_accessor :lines
      end
      
      # Determines the default number of lines per page for new Pager instances
      # to display. '23' fills the default RGSS3 console's window.
      @lines = 23
      
      # @return [Fixnum] the number of lines per page
      attr_accessor :lines
      
      # @return [Fixnum] the {Pager}'s position in its stored text
      attr_accessor :position
      
      # @return [Array<String>] the stored text being paginated
      attr_reader   :text
      
      # Initialize a new Pager instance with the given textual input and number
      # of lines to display by default. Textual input is converted into an
      # array separated by the Windows EOL separator.
      # 
      # @param string [String] the text to paginate
      # @param lines [Fixnum] the number of lines per page
      # @return [Pager] the new {Pager} instance
      def initialize(string = '', lines = self.class.lines)
        @lines    = lines
        @position = 0
        @previous = @position
        self.text = string
      end
      
      # Performs conversion of the given value into an array separated by the
      # Windows EOL separator.
      # 
      # @param value [#to_s] the object to separate and store as text
      # @return [String] the original string
      def text=(value)
        @text = value.to_s.split("\r\n")
      end
      
      # Paginates the `@text` input by displaying only the given number of
      # lines at a time. User input is required between pages.
      # 
      # @param lines [Fixnum] the number of lines per page
      # @return [Fixnum] the number of lines paginated
      def page(lines = @lines)
        catch :quit do
          throw :quit if (@position >= @text.size || @position < 0)
          @previous = @position
          @position += lines
          display_lines(@lines)
          (@previous < @text.size - lines) ? instance_exec(&prompt) : break
        end
        @position > @text.size ? @text.size : (@position > 0 ? @position : 0)
      end
      
      # Displays the lines from `@position` to the given number of lines. Lines
      # may be positive or negative -- a positive integer displays lines below
      # the current position, negative displays lines above it.
      # 
      # @param lines [Fixnum] the number of lines to display
      # @return [Fixnum] the new position in the paginated text
      def display_lines(lines)
        return (@position = 0) if (@position >= @text.size) || (@position < 0)
        @text.each_with_index do |line, index|
          next unless index.between?(*[@position, @position + lines].sort!)
          puts line
        end
      end
      
      # Prompts for user input for the pager and executes given commands.
      # 
      # @note The returned Proc object is run through `instance_exec` in the
      #   {Pager#page} method.
      # 
      # @param input [String, nil] the input to process
      # @return [Proc] representation of the code to call based on the given
      #   input
      def prompt(input = nil)
        print ('-- MORE -- ("q" to quit) >> ')
        retval = case (input = (i = gets.chomp! ; i.empty? ? 'forward' : i))
        when /^(?:\>|forward|next|down)$/i      ; -> { page(@lines)}
        when /^(?:\<|back|prev|previous|up)$/i  ; -> { page(-@lines)}
        when /^(-?\d{,2})$/                     ; -> { page(@lines * $1.to_i) }
        when /^(?:q|quit|exit)/i                ; -> { throw :quit }
        end
        if retval.nil?
          puts "Unknown command: #{input}"
          prompt
        else
          return retval
        end
      end
      
      # Resets the {Pager} instance to its default initialization state.
      # 
      # @return [self]
      def reset
        self.send(:initialize)
        yield self if block_given?
        self
      end
      
      # Provides a descriptive string representing the {Pager} instance.
      # 
      # @return [String] a descriptive representation
      def to_s
        "SES Lexicon Pager: #{@text.size} lines, #{@lines} shown"
      end
      alias_method :inspect, :to_s
    end
    
    # Instantiate the Pager for the Lexicon. Used by the `Lexicon.page` method.
    @pager = Pager.new('', @pager_lines)
    
    # Load all installed script data and organize it. Scripts maintain their
    # numerical index based on their placement in the Script Editor. Names of
    # scripts are stored in the internal structure with the `:name` key; code
    # is encoded as UTF-8 and stored with the `:code` key.
    @scripts = $RGSS_SCRIPTS.map do |script|
      RGSS_Script.new(script[1], script[3].force_encoding('utf-8'))
    end
    
    # Locates scripts containing the given name and returns an array of full
    # script names which were located.
    # 
    # @param name [String, Class, Module] the script name to locate
    # @return [Array<String>] an array of scripts with the given name
    def self.named(name)
      name = name.to_s if name.is_a?(Module)
      @scripts.select { |s| s.name[name] && !s.code.strip.empty? }.map!(&:name)
    end
    
    # Returns an array of script names which define the given class or module.
    # 
    # @note This method is fairly stupid and won't catch more exotic class or
    #   module definitions, but it works more than well enough for the default
    #   RMVX Ace scripts (as well as most third-party scripts).
    # 
    # @param name [#to_s] the class or module to locate
    # @return [Array<String>] an array of scripts defining the given class or
    #   module
    def self.defining(name)
      name = name.to_s.split('::')[-1] if name.to_s['::']
      @scripts.select do |script|
        ["class #{name}", "module #{name}"].any? { |defn| script.code[defn] }
      end.map!(&:name)
    end
    
    # Paginates code from the script with the given name through the `@pager`
    # instance owned by the Lexicon.
    # 
    # @param name [String, Class, Module] the script to paginate
    # @param line [Fixnum] the starting point of the pager in the script text
    # @return [Fixnum] the number of lines paged
    def self.page(name, line = 0)
      name = name.to_s if name.is_a?(Module)
      @pager.reset { |p| p.position = line }.text = @scripts.select do |script|
        script.name[name] && !script.code.strip.empty?
      end.map(&:code).join("\r\n")
      @pager.page(0)
    end
    class << self ; alias_method :browse, :page ; end
    
    # Paginates code from the script which defines the given method starting at
    # the source location of that method.
    # 
    # @param name [String] a string representing a class or module and the
    #   desired instance or class method
    # @return [Fixnum] the number of lines paged
    def self.find(name)
      k, m = name['#'] ? name.split('#') : name.split('.')
      klass = k.split('::').reduce(Object) { |obj, con| obj.const_get(con) }
      method = if name['#']
        klass.instance_method(m)
      else
        klass.method(m) rescue klass.instance_method(m)
      end
      name, line = *method.source_location
      name = $RGSS_SCRIPTS.at(name[1..4].to_i)[1]
      page(name, line - 1)
    end
    
    # Prints a targeted chunk of code from the given script name.
    # 
    # @param name [String, Class, Module] the script name to chunk
    # @param line [Fixnum] the target line
    # @param surround [Fixnum] the number of lines above and below the target
    #   line to display in the chunk
    # @return [Fixnum] the number of lines shown
    def self.chunk(name, line, surround = @surrounding_lines)
      name   = name.to_s if name.is_a?(Module)
      string = ''
      script = @scripts.select { |s| s.name[name] }[0].code.split("\r\n")
      start  = [0, line - surround, script.size - surround].sort[1]
      stop   = [surround, line + surround, script.size].sort[1]
      puts (script = script[start..stop]).join("\r\n")
      script.size
    end
    class << self ; alias_method :line, :chunk ; end
    
    # Register this script with the SES Core if it exists.
    if SES.const_defined?(:Register)
      # Script metadata.
      Description = Script.new(:Lexicon, 1.3)
      Register.enter(Description)
    end
  end
end
