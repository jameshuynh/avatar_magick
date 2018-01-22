require "dragonfly/hash_with_css_style_keys"

module AvatarMagick
  module Generators

    # Generates an initials avatar by extracting the first letter of
    # the first 3 words in string. Can be customized with background color,
    # text color, font, and size.
    class InitialAvatar
      def call(content, string, opts={})
        opts = ::Dragonfly::HashWithCssStyleKeys[opts]
        args = []

        # defaults
        format      = opts[:format] || 'png'
        background  = opts[:background_color] ? "##{opts[:background_color]}" : content.env[:avatar_magick][:background_color]
        color       = opts[:color] ? "##{opts[:color]}" : content.env[:avatar_magick][:color]
        size        = opts[:size] || content.env[:avatar_magick][:size]
        font        = opts[:font] || content.env[:avatar_magick][:font]
        maximum     = (opts[:maximum] || content.env[:avatar_magick][:maximum]).to_i

        maximum = 1 if maximum.negative?
        # extract the first letter of the first 3 words and capitalize
        text = (string.split(/\s/)- ["", nil]).map { |t| t.to_s[0].upcase }.slice(0, maximum).join('')

        w, h = size.split('x').map { |d| d.to_i }
        h ||= w

        font_size = ( w / [text.length, maximum].max ).to_i

        gradient = background.include?('-')
        # Settings
        args.push("-gravity none")
        args.push("-antialias")
        args.push("-pointsize #{font_size}")
        args.push("-font \"#{font}\"")
        args.push("-family '#{opts[:font_family]}'") if opts[:font_family]
        args.push("-fill #{color}")
        args.push("-background #{gradient ? 'none' : background}")
        args.push("caption:#{text}")
        if gradient
          background = background.gsub('#', '').split('-').map{|c| '#'.concat(c) }.join('-')
          args.push("-gravity center -append -trim")
          args.push("-size #{w}x#{h}")
          args.push("gradient:#{background}")
          args.push("+swap -gravity center -compose over -composite")
        end

        content.generate!(:convert, args.join(' '), format)

        args.clear
        args.push("-gravity center")
        args.push("-extent #{w}x#{h}")

        content.process!(:convert, args.join(' '))

        content.add_meta('format' => format, 'name' => "avatar.#{format}")
      end
    end
  end
end
