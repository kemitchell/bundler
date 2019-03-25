# frozen_string_literal: true

module Bundler
  class CLI::Credits
    def initialize(options)
      @options = options
    end

    def run
      raise InvalidOption, "The `--only-group` and `--without-group` options cannot be used together" if @options["only-group"] && @options["without-group"]

      specs = if @options["only-group"] || @options["without-group"]
        filtered_specs_by_groups
      else
        Bundler.load.specs
      end.reject {|s| s.name == "bundler" }.sort_by(&:name)

      return Bundler.ui.info "No gems in the Gemfile" if specs.empty?

      specs.each do |s|
        Bundler.ui.info " #{s.name}: #{s.authors.join ', '}"
      end
    end

  private

    def verify_group_exists(groups)
      raise InvalidOption, "`#{@options["without-group"]}` group could not be found." if @options["without-group"] && !groups.include?(@options["without-group"].to_sym)

      raise InvalidOption, "`#{@options["only-group"]}` group could not be found." if @options["only-group"] && !groups.include?(@options["only-group"].to_sym)
    end

    def filtered_specs_by_groups
      definition = Bundler.definition
      groups = definition.groups

      verify_group_exists(groups)

      show_groups =
        if @options["without-group"]
          groups.reject {|g| g == @options["without-group"].to_sym }
        elsif @options["only-group"]
          groups.select {|g| g == @options["only-group"].to_sym }
        else
          groups
        end.map(&:to_sym)

      definition.specs_for(show_groups)
    end
  end
end
