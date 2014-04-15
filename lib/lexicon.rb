#--
# Lexicon v1.1 by Solistra
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
# functionality of this script is available through simple methods. This script
# also organizes RGSS3 script information primarily by "file" name -- that is,
# the name of the script as defined in the RMVX Ace Script Editor.
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
# buffer (especially when viewing large scripts such as Game_Interpreter).
# 
#   If you need to view a specific line or chunk of source code, you can use
# the `SES::Lexicon.line` method. The usage of this method involves providing
# the script name, line number, and (optionally) the number of lines around the
# requested line number to display as well. For example, if we wanted to view
# the `update` method of Scene_Base and the 5 lines of code both above and
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
#   The Lexicon also enables direct reading of the script information that it
# stores. This information is provided as a reader method for the Lexicon's
# `@scripts` instance variable. The format of this array stores information as
# a hash -- each hash includes the `:name` and `:code` keys which provide the
# expected information when accessed. For example, if you want to simply print
# the contents of Main to the console, you could use the following:
# 
#     puts SES::Lexicon.scripts[-2][:code]
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
module SES
  # ===========================================================================
  # Lexicon
  # ===========================================================================
  # Provides information about the installed RGSS3 scripts present in the RMVX
  # Ace Script Editor.
  module Lexicon
    # =========================================================================
    # BEGIN CONFIGURATION
    # =========================================================================
    # The number of lines to show per page within the Lexicon's pager. This is
    # set to 23 by default, which fills the default RGSS Console's window with
    # output from the pager.
    @pager_lines = 23
    
    # The number of lines to surround source code lines queried with the `line`
    # or `chunk` methods of the Lexicon. The number defined here determines the
    # number of lines shown both above and below the line given. Set this to 0
    # in order to display *only* the requested line.
    @surrounding_lines = 5
    # =========================================================================
    # END CONFIGURATION
    # =========================================================================
    class << self
      attr_accessor :pager_lines, :surrounding_lines
      attr_reader   :pager,       :scripts
    end
    # =========================================================================
    # Pager
    # =========================================================================
    # Paginates textual input by displaying only `lines` number of lines at a
    # time until the end of input has been reached.
    class Pager
      attr_accessor :lines
      attr_reader   :text
      
      # Initialize a new Pager instance with the given textual input and number
      # of lines to display by default. Textual input is converted into an
      # array separated by the Windows EOL separator.
      def initialize(string = '', lines = 23)
        @lines    = lines
        self.text = string.to_s
      end
      
      # Writer method for the `@text` instance variable. Performs conversion of
      # the given string into an array separated by the Windows EOL separator.
      def text=(string)
        @text = string.split("\r\n")
      end
      
      # Paginates the `@text` input by displaying only the given number of
      # lines at a time. User input is required between pages. The pager quits
      # operation if the user enters either 'q' or 'Q' as input, but continues
      # pagination otherwise. Returns the number of lines of input that were
      # browsed.
      def page(lines = @lines)
        # Store the current position of the pager and its maximum position.
        position, total = 0, @text.size
        while position < total
          @text.each_with_index do |line, index|
            break if position >= total
            # Only display the line if it is within the limits of the current
            # position and the given number of lines to display at a time.
            puts line if index.between?(position, position + lines)
          end
          # Store the previous position -- this is used so that we can tell if
          # there are more pages to display or if the one displayed was the
          # last.
          prev_position = position
          position     += lines + 1
          (prev_position < total - lines) ? print('-- MORE -- >> ') : break
          # Quit pagination and break if the user enters 'q' or 'Q' as input.
          break if gets.chomp!.downcase == 'q'
        end
        # Return the total lines of text that were viewed through the pager.
        position > total ? total : position
      end
      
      # Provides a descriptive string representing the Pager instance.
      def to_s
        "SES Lexicon Pager: #{@text.size} lines, #{@lines} shown"
      end
      alias :inspect :to_s
    end
    
    # Instantiate the Pager for the Lexicon. Used by the `Lexicon.page` method.
    @pager = Pager.new('', @pager_lines)
    
    # Load all installed script data and organize it. Scripts maintain their
    # numerical index based on their placement in the Script Editor. Names of
    # scripts are stored in the internal hash with the `:name` key, code is
    # decompressed and stored with the `:code` key.
    @scripts = load_data('Data/Scripts.rvdata2').map! do |script|
      { :name => script[1],
        :code => Zlib::Inflate.inflate(script.last).force_encoding("utf-8") }
    end
    
    # Locates scripts containing the given name and returns an array of full
    # script names which were located.
    def self.named(name)
      name = name.to_s if (name.is_a?(Class) || name.is_a?(Module))
      @scripts.select do |script|
        script[:name][name] && !script[:code].strip.empty?
      end.map { |script| script[:name] }
    end
    
    # Returns an array of script names which define the given class or module.
    # Note: this method is fairly stupid and won't catch more exotic class or
    # module definitions, but it works more than well enough for the default
    # RMVX Ace scripts as well as most third-party scripts.
    def self.defining(name)
      name = name.to_s.split('::').last if name.to_s['::']
      @scripts.select do |script|
        ["class #{name}", "module #{name}"].any? do |definition|
          script[:code][definition]
        end
      end.map { |script| script[:name] }
    end
    
    # Paginates code from the script with the given name through the `@pager`
    # instance owned by the Lexicon. Returns the return value of the pager
    # (the number of lines written to standard output).
    def self.page(name)
      name = name.to_s if (name.is_a?(Class) || name.is_a?(Module))
      @pager.text = @scripts.select do |script|
        script[:name][name] && !script[:code].strip.empty?
      end.map { |script| script[:code] }.join("\r\n")
      @pager.page(@pager_lines)
    end
    class << self ; alias :browse :page ; end
    
    # Prints the code from the script with the given name on the given line
    # with the given number of lines surrounding it. The number given for the
    # surrounding lines determines how many lines are shown both above and
    # below the target line of code. Returns the number of lines shown.
    def self.chunk(name, line, surround = @surrounding_lines)
      name   = name.to_s if (name.is_a?(Class) || name.is_a?(Module))
      string = ''
      script = @scripts.select { |s| s[:name][name] }[0][:code].split("\r\n")
      start  = [0, line - surround, script.size - surround].sort[1]
      stop   = [surround, line + surround, script.size].sort[1]
      puts (script = script[start..stop]).join("\r\n")
      script.size
    end
    class << self ; alias :line :chunk ; end
    
    # Register this script with the SES Core if it exists.
    if SES.const_defined?(:Register)
      Description = Script.new(:Lexicon, 1.1)
      Register.enter(Description)
    end
  end
end