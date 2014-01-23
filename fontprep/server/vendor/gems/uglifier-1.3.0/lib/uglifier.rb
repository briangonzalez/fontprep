# encoding: UTF-8

require "execjs"
require "multi_json"

class Uglifier
  Error = ExecJS::Error
  # MultiJson.engine = :json_gem

  # Default options for compilation
  DEFAULTS = {
    :mangle => true, # Mangle variable and function names, use :vars to skip function mangling
    :toplevel => false, # Mangle top-level variable names
    :except => ["$super"], # Variable names to be excluded from mangling
    :max_line_length => 32 * 1024, # Maximum line length
    :squeeze => true, # Squeeze code resulting in smaller, but less-readable code
    :seqs => true, # Reduce consecutive statements in blocks into single statement
    :dead_code => true, # Remove dead code (e.g. after return)
    :lift_vars => false, # Lift all var declarations at the start of the scope
    :unsafe => false, # Optimizations known to be unsafe in some situations
    :copyright => true, # Show copyright message
    :ascii_only => false, # Encode non-ASCII characters as Unicode code points
    :inline_script => false, # Escape </script
    :quote_keys => false, # Quote keys in object literals
    :define => {}, # Define values for symbol replacement
    :beautify => false, # Ouput indented code
    :beautify_options => {
      :indent_level => 4,
      :indent_start => 0,
      :space_colon => false
    }
  }

  SourcePath = File.expand_path("../uglify.js", __FILE__)
  ES5FallbackPath = File.expand_path("../es5.js", __FILE__)

  # Minifies JavaScript code using implicit context.
  #
  # source should be a String or IO object containing valid JavaScript.
  # options contain optional overrides to Uglifier::DEFAULTS
  #
  # Returns minified code as String
  def self.compile(source, options = {})
    self.new(options).compile(source)
  end

  # Initialize new context for Uglifier with given options
  #
  # options - Hash of options to override Uglifier::DEFAULTS
  def initialize(options = {})
    @options = DEFAULTS.merge(options)
    @context = ExecJS.compile(File.open(ES5FallbackPath, "r:UTF-8").read + File.open(SourcePath, "r:UTF-8").read)
  end

  # Minifies JavaScript code
  #
  # source should be a String or IO object containing valid JavaScript.
  #
  # Returns minified code as String
  def compile(source)
    source = source.respond_to?(:read) ? source.read : source.to_s

    js = []
    js << "var result = '';"
    js << "var source = #{json_encode(source)};"
    js << "var ast = UglifyJS.parser.parse(source);"

    if @options[:lift_vars]
      js << "ast = UglifyJS.uglify.ast_lift_variables(ast);"
    end

    if @options[:copyright]
      js << <<-JS
      var comments = UglifyJS.parser.tokenizer(source)().comments_before;
      for (var i = 0; i < comments.length; i++) {
        var c = comments[i];
        result += (c.type == "comment1") ? "//"+c.value+"\\n" : "/*"+c.value+"*/\\n";
      }
      JS
    end

    js << "ast = UglifyJS.uglify.ast_mangle(ast, #{json_encode(mangle_options)});"

    if @options[:squeeze]
      js << "ast = UglifyJS.uglify.ast_squeeze(ast, #{json_encode(squeeze_options)});"
    end

    if @options[:unsafe]
      js << "ast = UglifyJS.uglify.ast_squeeze_more(ast);"
    end

    js << "result += UglifyJS.uglify.gen_code(ast, #{json_encode(gen_code_options)});"

    if !@options[:beautify] && @options[:max_line_length]
      js << "result = UglifyJS.uglify.split_lines(result, #{@options[:max_line_length].to_i})"
    end

    js << "return result + ';';"

    @context.exec js.join("\n")
  end
  alias_method :compress, :compile

  private

  def mangle_options
    {
      "mangle" => @options[:mangle],
      "toplevel" => @options[:toplevel],
      "defines" => defines,
      "except" => @options[:except],
      "no_functions" => @options[:mangle] == :vars
    }
  end

  def squeeze_options
    {
      "make_seqs" => @options[:seqs],
      "dead_code" => @options[:dead_code],
      "keep_comps" => !@options[:unsafe]
    }
  end

  def defines
    Hash[(@options[:define] || {}).map do |k, v|
      token = if v.is_a? Numeric
        ['num', v]
      elsif [true, false].include?(v)
        ['name', v.to_s]
      elsif v == nil
        ['name', 'null']
      else
        ['string', v.to_s]
      end
      [k, token]
    end]
  end

  def gen_code_options
    options = {
      :ascii_only => @options[:ascii_only],
      :inline_script => @options[:inline_script],
      :quote_keys => @options[:quote_keys]
    }

    if @options[:beautify]
      options.merge(:beautify => true).merge(@options[:beautify_options])
    else
      options
    end
  end

  # MultiJson API detection
  if MultiJson.respond_to? :dump
    def json_encode(obj)
      MultiJson.dump(obj)
    end
  else
    def json_encode(obj)
      MultiJson.encode(obj)
    end
  end
end
