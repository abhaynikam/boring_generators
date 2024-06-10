# frozen_string_literal: true

module Boring
  module Favicon
    class BuildGenerator < Rails::Generators::Base
      desc "Build favicons for all platforms"
      source_root File.expand_path("templates", __dir__)

      ICO_SIZES = %w(16 32)
      APPLE_SIZES = %w(57 60 72 76 114 120 129 144 152)
      APPLE_PRECOMPOSED_SIZES = %w(120 129 152)
      SMALL_BREAK = 50
      LARGE_BREAK = 150
      MS_TILE_SIZES = %w(144)
      FAVICON_DIR = "favicons"
      FILE_FAVICO_DIR = "app/assets/images/#{FAVICON_DIR}"
      DEFAULT_PRIMARY_COLOR = "#082472"
      DEFAULT_FAVICON_LETTER = "B" # B for boring_generators :)
      DEFAULT_IMAGE_PATH = "#{FILE_FAVICO_DIR}/template.png"

      class_option :primary_color,        type: :string, aliases: "-color",
                                          desc: "Tell us the primary color to build favicon. Default to primary: #{DEFAULT_PRIMARY_COLOR}"
      class_option :favico_letter,        type: :string, aliases: "-letter",
                                          desc: "Tell us the favicon letter to build favicon. Default to primary: #{DEFAULT_FAVICON_LETTER}"
      class_option :font_file_path,       type: :string, aliases: "-fp",
                                          desc: "Tell us the font to be used generate favicon."
      class_option :application_name,     type: :string, aliases: "-app_name",
                                          desc: "Tell us the application name to be used in favicon partial."

      def build_favicon
        @application_name = options[:application_name]
        @primary_color = options[:primary_color]

        unless /Version/m =~ (`convert -version`)
          say <<~WARNING, :red
            ERROR: You do not have ImageMagick installed.
          WARNING
        end
      end

      def create_favicon_directory
        unless File.exist?(FILE_FAVICO_DIR)
          Dir.mkdir FILE_FAVICO_DIR
        end
      end

      def build_favicon_for_existing_template_image
        return unless File.exist?(DEFAULT_IMAGE_PATH)

        say "Converting template image to favicons..."
        template_name = "#{FILE_FAVICO_DIR}/template.png"
        template_small_name = "#{FILE_FAVICO_DIR}/template-small.png"
        template_large_name = "#{FILE_FAVICO_DIR}/template-large.png"
        template_small_name = template_name unless File.file?(template_small_name)
        template_large_name = template_name unless File.file?(template_large_name)
        ICO_SIZES.each do |size|
          ico_template = template_name
          ico_template = template_small_name if size.to_i <= SMALL_BREAK
          ico_template = template_small_name if size.to_i >= LARGE_BREAK
          (`convert #{ico_template} -resize #{size}x#{size} #{FILE_FAVICO_DIR}/favicon-#{size}x#{size}.ico`)
        end
        APPLE_SIZES.each do |size|
          ico_template = template_name
          ico_template = template_small_name if size.to_i <= SMALL_BREAK
          ico_template = template_small_name if size.to_i >= LARGE_BREAK
          (`convert #{ico_template} -resize #{size}x#{size} #{FILE_FAVICO_DIR}/apple-touch-icon-#{size}x#{size}.png`)
        end
        APPLE_PRECOMPOSED_SIZES.each do |size|
          ico_template = template_name
          ico_template = template_small_name if size.to_i <= SMALL_BREAK
          ico_template = template_small_name if size.to_i >= LARGE_BREAK
          (`convert #{ico_template} -resize #{size}x#{size} #{FILE_FAVICO_DIR}/apple-touch-icon-#{size}x#{size}-precomposed.png`)
        end
        MS_TILE_SIZES.each do |size|
          ico_template = template_name
          ico_template = template_small_name if size.to_i <= SMALL_BREAK
          ico_template = template_small_name if size.to_i >= LARGE_BREAK
          (`convert #{ico_template} -resize #{size}x#{size} #{FILE_FAVICO_DIR}/mstile-#{size}x#{size}.png`)
        end
        ico_template = template_name
        ico_template = template_small_name if 152 <= SMALL_BREAK
        ico_template = template_small_name if 152 >= LARGE_BREAK
        (`convert #{ico_template} -resize 152x152 #{FILE_FAVICO_DIR}/apple-touch-icon.png`)
        (`convert #{ico_template} -resize 152x152 #{FILE_FAVICO_DIR}/apple-touch-icon-precomposed.png`)
      end

      def generate_new_favicon_using_favico_letter
        return if File.exist?(DEFAULT_IMAGE_PATH)
        say "Creating favicons from application...", :green

        favico_letter = options[:favico_letter] || @application_name.try(:first) || DEFAULT_FAVICON_LETTER
        font_file_path = options[:font_file_path]
        favicon_color = options[:primary_color] || DEFAULT_PRIMARY_COLOR

        ICO_SIZES.each do |size|
          (`convert -background "#{favicon_color}" -fill white -size #{size}x#{size} -gravity center #{font_file_path ? "-font #{font_file_path}" : ""} label:#{favico_letter} #{FILE_FAVICO_DIR}/favicon-#{size}x#{size}.ico`)
        end
        APPLE_SIZES.each do |size|
          (`convert -background "#{favicon_color}" -fill white -size #{size}x#{size} -gravity center #{font_file_path ? "-font #{font_file_path}" : ""} label:#{favico_letter} #{FILE_FAVICO_DIR}/apple-touch-icon-#{size}x#{size}.png`)
        end
        APPLE_PRECOMPOSED_SIZES.each do |size|
          (`convert -background "#{favicon_color}" -fill white -size #{size}x#{size} -gravity center #{font_file_path ? "-font #{font_file_path}" : ""} label:#{favico_letter} #{FILE_FAVICO_DIR}/apple-touch-icon-#{size}x#{size}-precomposed.png`)
        end
        MS_TILE_SIZES.each do |size|
          (`convert -background "#{favicon_color}" -fill white -size #{size}x#{size} -gravity center #{font_file_path ? "-font #{font_file_path}" : ""} label:#{favico_letter} #{FILE_FAVICO_DIR}/mstile-#{size}x#{size}.png`)
        end
        (`convert -background "#{favicon_color}" -fill white -size 152x152 -gravity center #{font_file_path ? "-font #{font_file_path}" : ""} label:#{favico_letter} #{FILE_FAVICO_DIR}/apple-touch-icon.png`)
        (`convert -background "#{favicon_color}" -fill white -size 152x152 -gravity center #{font_file_path ? "-font #{font_file_path}" : ""} label:#{favico_letter} #{FILE_FAVICO_DIR}/apple-touch-icon-precomposed.png`)
      end

      def add_favicon_partial
        say "Copying favicon layout partial", :green
        template("favicon.html.erb", "app/views/layouts/shared/_favicon.html.erb")
        insert_into_file "app/views/layouts/application.html.erb", <<~RUBY, after: /head.*\n/
          \t\t<%= render 'layouts/shared/favicon' %>
        RUBY
      end
    end
  end
end
