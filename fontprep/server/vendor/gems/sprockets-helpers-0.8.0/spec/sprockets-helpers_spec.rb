require 'spec_helper'

describe Sprockets::Helpers do
  describe '.configure' do
    it 'sets global configuration' do
      within_construct do |c|
        c.file 'assets/main.css'

        context.asset_path('main.css').should == '/assets/main.css'
        Sprockets::Helpers.configure do |config|
          config.digest = true
          config.prefix = '/themes'
        end
        context.asset_path('main.css').should =~ %r(/themes/main-[0-9a-f]+.css)
        Sprockets::Helpers.digest = nil
        Sprockets::Helpers.prefix = nil
      end
    end
  end

  describe '.digest' do
    it 'globally configures digest paths' do
      within_construct do |c|
        c.file 'assets/main.js'

        context.asset_path('main', :ext => 'js').should == '/assets/main.js'
        Sprockets::Helpers.digest = true
        context.asset_path('main', :ext => 'js').should =~ %r(/assets/main-[0-9a-f]+.js)
        Sprockets::Helpers.digest = nil
      end
    end
  end

  describe '.environment' do
    it 'sets a custom assets environment' do
      within_construct do |c|
        c.file 'themes/main.css'

        custom_env = Sprockets::Environment.new
        custom_env.append_path 'themes'
        Sprockets::Helpers.environment = custom_env
        context.asset_path('main.css').should == '/assets/main.css'
        Sprockets::Helpers.environment = nil
      end
    end
  end

  describe '.asset_host' do
    context 'that is a string' do
      it 'prepends the asset_host' do
        within_construct do |c|
          c.file 'assets/main.js'
          c.file 'public/logo.jpg'

          Sprockets::Helpers.asset_host = 'assets.example.com'
          context.asset_path('main.js').should == 'http://assets.example.com/assets/main.js'
          context.asset_path('logo.jpg').should =~ %r(http://assets.example.com/logo.jpg\?\d+)
          Sprockets::Helpers.asset_host = nil
        end
      end

      context 'with a wildcard' do
        it 'cycles asset_host between 0-3' do
          within_construct do |c|
            c.file 'assets/main.css'
            c.file 'public/logo.jpg'

            Sprockets::Helpers.asset_host = 'assets%d.example.com'
            context.asset_path('main.css').should =~ %r(http://assets[0-3].example.com/assets/main.css)
            context.asset_path('logo.jpg').should =~ %r(http://assets[0-3].example.com/logo.jpg\?\d+)
            Sprockets::Helpers.asset_host = nil
          end
        end
      end
    end

    context 'that is a proc' do
      it 'prepends the returned asset_host' do
        within_construct do |c|
          c.file 'assets/main.js'
          c.file 'public/logo.jpg'

          Sprockets::Helpers.asset_host = Proc.new { |source| File.basename(source, File.extname(source)) + '.assets.example.com' }
          context.asset_path('main.js').should == 'http://main.assets.example.com/assets/main.js'
          context.asset_path('logo.jpg').should =~ %r(http://logo.assets.example.com/logo.jpg\?\d+)
          Sprockets::Helpers.asset_host = nil
        end
      end
    end
  end

  describe '.prefix' do
    it 'sets a custom assets prefix' do
      within_construct do |c|
        c.file 'assets/logo.jpg'

        context.asset_path('logo.jpg').should == '/assets/logo.jpg'
        Sprockets::Helpers.prefix = '/images'
        context.asset_path('logo.jpg').should == '/images/logo.jpg'
        Sprockets::Helpers.prefix = nil
      end
    end
  end

  describe '.protocol' do
    it 'sets the protocol to use with asset_hosts' do
      within_construct do |c|
        c.file 'assets/main.js'
        c.file 'public/logo.jpg'

        Sprockets::Helpers.asset_host = 'assets.example.com'
        Sprockets::Helpers.protocol   = 'https'
        context.asset_path('main.js').should == 'https://assets.example.com/assets/main.js'
        context.asset_path('logo.jpg').should =~ %r(https://assets.example.com/logo.jpg\?\d+)
        Sprockets::Helpers.asset_host = nil
        Sprockets::Helpers.protocol   = nil
      end
    end

    context 'that is :relative' do
      it 'sets a relative protocol' do
        within_construct do |c|
          c.file 'assets/main.js'
          c.file 'public/logo.jpg'

          Sprockets::Helpers.asset_host = 'assets.example.com'
          Sprockets::Helpers.protocol   = :relative
          context.asset_path('main.js').should == '//assets.example.com/assets/main.js'
          context.asset_path('logo.jpg').should =~ %r(\A//assets.example.com/logo.jpg\?\d+)
          Sprockets::Helpers.asset_host = nil
          Sprockets::Helpers.protocol   = nil
        end
      end
    end
  end

  describe '.public_path' do
    it 'sets a custom location for the public path' do
      within_construct do |c|
        c.file 'output/main.js'

        context.asset_path('main.js').should == '/main.js'
        Sprockets::Helpers.public_path = './output'
        context.asset_path('main.js').should =~ %r(/main.js\?\d+)
        Sprockets::Helpers.public_path = nil
      end
    end
  end

  describe '#asset_path' do
    context 'with URIs' do
      it 'returns URIs untouched' do
        context.asset_path('https://ajax.googleapis.com/ajax/libs/jquery/1.6.4/jquery.min.js').should ==
          'https://ajax.googleapis.com/ajax/libs/jquery/1.6.4/jquery.min.js'
        context.asset_path('http://ajax.googleapis.com/ajax/libs/jquery/1.6.4/jquery.min.js').should ==
          'http://ajax.googleapis.com/ajax/libs/jquery/1.6.4/jquery.min.js'
        context.asset_path('//ajax.googleapis.com/ajax/libs/jquery/1.6.4/jquery.min.js').should ==
          '//ajax.googleapis.com/ajax/libs/jquery/1.6.4/jquery.min.js'
      end
    end

    context 'with regular files' do
      it 'returns absolute paths' do
        context.asset_path('/path/to/file.js').should == '/path/to/file.js'
        context.asset_path('/path/to/file.jpg').should == '/path/to/file.jpg'
        context.asset_path('/path/to/file.eot?#iefix').should == '/path/to/file.eot?#iefix'
      end

      it 'appends the extension for javascripts and stylesheets' do
        context.asset_path('/path/to/file', :ext => 'js').should == '/path/to/file.js'
        context.asset_path('/path/to/file', :ext => 'css').should == '/path/to/file.css'
      end

      it 'prepends a base dir' do
        context.asset_path('main', :dir => 'stylesheets', :ext => 'css').should == '/stylesheets/main.css'
        context.asset_path('main', :dir => 'javascripts', :ext => 'js').should == '/javascripts/main.js'
        context.asset_path('logo.jpg', :dir => 'images').should == '/images/logo.jpg'
      end

      it 'appends a timestamp if the file exists in the output path' do
        within_construct do |c|
          c.file 'public/main.js'
          c.file 'public/favicon.ico'
          c.file 'public/font.eot'
          c.file 'public/font.svg'

          context.asset_path('main', :ext => 'js').should =~ %r(/main.js\?\d+)
          context.asset_path('/favicon.ico').should =~ %r(/favicon.ico\?\d+)
          context.asset_path('font.eot?#iefix').should =~ %r(/font.eot\?\d+#iefix)
          context.asset_path('font.svg#FontName').should =~ %r(/font.svg\?\d+#FontName)
        end
      end
    end

    context 'with assets' do
      it 'returns URLs to the assets' do
        within_construct do |c|
          c.file 'assets/logo.jpg'
          c.file 'assets/main.js'
          c.file 'assets/main.css'

          context.asset_path('main', :ext => 'css').should == '/assets/main.css'
          context.asset_path('main', :ext => 'js').should == '/assets/main.js'
          context.asset_path('logo.jpg').should == '/assets/logo.jpg'
        end
      end

      it 'prepends the assets prefix' do
        within_construct do |c|
          c.file 'assets/logo.jpg'

          context.asset_path('logo.jpg').should == '/assets/logo.jpg'
          context.asset_path('logo.jpg', :prefix => '/images').should == '/images/logo.jpg'
        end
      end

      it 'uses the digest path if configured' do
        within_construct do |c|
          c.file 'assets/main.js'
          c.file 'assets/font.eot'
          c.file 'assets/font.svg'

          context.asset_path('main', :ext => 'js').should == '/assets/main.js'
          context.asset_path('main', :ext => 'js', :digest => true).should =~ %r(/assets/main-[0-9a-f]+.js)
          context.asset_path('font.eot?#iefix', :digest => true).should =~ %r(/assets/font-[0-9a-f]+.eot\?#iefix)
          context.asset_path('font.svg#FontName', :digest => true).should =~ %r(/assets/font-[0-9a-f]+.svg#FontName)
        end
      end

      it 'returns a body parameter' do
        within_construct do |c|
          c.file 'assets/main.js'
          c.file 'assets/font.eot'
          c.file 'assets/font.svg'

          context.asset_path('main', :ext => 'js', :body => true).should == '/assets/main.js?body=1'
          context.asset_path('font.eot?#iefix', :body => true).should == '/assets/font.eot?body=1#iefix'
          context.asset_path('font.svg#FontName', :body => true).should == '/assets/font.svg?body=1#FontName'
        end
      end
    end

    context 'when debuging' do
      it 'does not use the digest path' do
        within_construct do |c|
          c.file 'assets/main.js'

          Sprockets::Helpers.digest = true
          context.asset_path('main.js', :debug => true).should == '/assets/main.js'
          Sprockets::Helpers.digest = nil
        end
      end

      it 'does not prepend the asset host' do
        within_construct do |c|
          c.file 'assets/main.js'

          Sprockets::Helpers.asset_host = 'assets.example.com'
          context.asset_path('main.js', :debug => true).should == '/assets/main.js'
          Sprockets::Helpers.asset_host = nil
        end
      end
    end

    if defined?(::Sprockets::Manifest)
      context 'with a manifest' do
        it 'reads path from a manifest file' do
          within_construct do |c|
            asset_file    = c.file 'assets/application.js'
            manifest_file = c.join 'manifest.json'

            manifest = Sprockets::Manifest.new(env, manifest_file)
            manifest.compile 'application.js'

            Sprockets::Helpers.configure do |config|
              config.digest   = true
              config.prefix   = '/assets'
              config.manifest = Sprockets::Manifest.new(env, manifest_file)
            end

            asset_file.delete
            context.asset_path('application.js').should =~ %r(/assets/application-[0-9a-f]+.js)

            Sprockets::Helpers.digest = nil
            Sprockets::Helpers.prefix = nil
          end
        end

        context 'when debuging' do
          it 'does not read the path from the manifest file' do
            within_construct do |c|
              asset_file    = c.file 'assets/application.js'
              manifest_file = c.join 'manifest.json'

              manifest = Sprockets::Manifest.new(env, manifest_file)
              manifest.compile 'application.js'

              Sprockets::Helpers.configure do |config|
                config.digest   = true
                config.prefix   = '/assets'
                config.manifest = Sprockets::Manifest.new(env, manifest_file)
              end

              context.asset_path('application.js', :debug => true).should == '/assets/application.js'

              Sprockets::Helpers.digest = nil
              Sprockets::Helpers.prefix = nil
            end
          end
        end
      end
    end
  end

  describe '#javascript_path' do
    context 'with regular files' do
      it 'appends the js extension' do
        context.javascript_path('/path/to/file').should == '/path/to/file.js'
        context.javascript_path('/path/to/file.min').should == '/path/to/file.min.js'
      end

      it 'prepends the javascripts dir' do
        context.javascript_path('main').should == '/javascripts/main.js'
        context.javascript_path('main.min').should == '/javascripts/main.min.js'
      end
    end
  end

  describe '#stylesheet_path' do
    context 'with regular files' do
      it 'appends the css extension' do
        context.stylesheet_path('/path/to/file').should == '/path/to/file.css'
        context.stylesheet_path('/path/to/file.min').should == '/path/to/file.min.css'
      end

      it 'prepends the stylesheets dir' do
        context.stylesheet_path('main').should == '/stylesheets/main.css'
        context.stylesheet_path('main.min').should == '/stylesheets/main.min.css'
      end
    end
  end

  describe '#image_path' do
    context 'with regular files' do
      it 'prepends the images dir' do
        context.image_path('logo.jpg').should == '/images/logo.jpg'
      end
    end
  end

  describe '#font_path' do
    context 'with regular files' do
      it 'prepends the fonts dir' do
        context.font_path('font.ttf').should == '/fonts/font.ttf'
      end
    end
  end

  describe '#video_path' do
    context 'with regular files' do
      it 'prepends the videos dir' do
        context.video_path('video.mp4').should == '/videos/video.mp4'
      end
    end
  end

  describe '#audio_path' do
    context 'with regular files' do
      it 'prepends the audios dir' do
        context.audio_path('audio.mp3').should == '/audios/audio.mp3'
      end
    end
  end

  describe '#asset_tag' do
    it 'receives block to generate tag' do
      actual = context.asset_tag('main.js') { |path| "<script src=#{path}></script>" }
      actual.should == '<script src=/main.js></script>'
    end

    it 'raises when called without block' do
      expect { context.asset_tag('main.js') }.to raise_error(ArgumentError, "block missing")
    end

    it 'expands when configured' do
      within_construct do |construct|
        assets_layout(construct)
        Sprockets::Helpers.expand = true
        c = context
        c.stub(:asset_path).and_return(context.asset_path('main.js')) # Spy
        c.should_receive(:asset_path).with('main.js', {:expand => true})
        c.asset_tag('main.js') {}
        Sprockets::Helpers.expand = false
        c.should_receive(:asset_path).with('main.js', {:expand => false})
        c.asset_tag('main.js') {}
      end
    end

    describe 'when expanding' do
      it 'passes uri that is no asset untouched' do
        context.asset_tag('main.js', :expand => true) {}
      end

      it 'generates tag for each asset' do
        within_construct do |construct|
          assets_layout(construct)
          tags = context.asset_tag('main.js', :expand => true) do |path|
            "<script src=\"#{path}\"></script>"
          end
          tags.split("</script>").should have(3).scripts
          tags.should include('<script src="/assets/main.js?body=1"></script>')
          tags.should include('<script src="/assets/a.js?body=1"></script>')
          tags.should include('<script src="/assets/b.js?body=1"></script>')
        end
      end

    end
  end

  describe '#javascript_tag' do
    it 'generates script tag' do
      context.javascript_tag('main.js').should == '<script src="/main.js"></script>'
    end

    it 'appends extension' do
      context.javascript_tag('main').should == '<script src="/main.js"></script>'
    end

    describe 'when expanding' do
      it 'generates script tag for each javascript asset' do
        within_construct do |construct|
          assets_layout(construct)
          tags = context.javascript_tag('main.js', :expand => true)
          tags.should include('<script src="/assets/main.js?body=1"></script>')
          tags.should include('<script src="/assets/a.js?body=1"></script>')
          tags.should include('<script src="/assets/b.js?body=1"></script>')
        end
      end
    end
  end

  describe '#stylesheet_tag' do
    it 'generates stylesheet tag' do
      context.stylesheet_tag('main.css').should == '<link rel="stylesheet" href="/main.css">'
    end

    it 'generates stylesheet tag' do
      context.stylesheet_tag('main').should == '<link rel="stylesheet" href="/main.css">'
    end

    describe 'when expanding' do
      it 'generates stylesheet tag for each stylesheet asset' do
        within_construct do |construct|
          assets_layout(construct)
          tags = context.stylesheet_tag('main.css', :expand => true)
          tags.should include('<link rel="stylesheet" href="/assets/main.css?body=1">')
          tags.should include('<link rel="stylesheet" href="/assets/a.css?body=1">')
          tags.should include('<link rel="stylesheet" href="/assets/b.css?body=1">')
        end
      end
    end
  end
end
