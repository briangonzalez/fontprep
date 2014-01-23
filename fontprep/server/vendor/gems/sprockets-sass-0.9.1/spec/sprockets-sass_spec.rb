require 'spec_helper'

describe Sprockets::Sass do
  before :each do
    @root   = create_construct
    @assets = @root.directory 'assets'
    @env    = Sprockets::Environment.new @root.to_s
    @env.append_path @assets.to_s
  end

  after :each do
    @root.destroy!
  end

  it 'processes scss files normally' do
    @assets.file 'main.css.scss', '//= require dep'
    @assets.file 'dep.css.scss', 'body { color: blue; }'
    asset = @env['main.css']
    asset.to_s.should == "body {\n  color: blue; }\n"
  end

  it 'processes sass files normally' do
    @assets.file 'main.css.sass', '//= require dep'
    @assets.file 'dep.css.sass', "body\n  color: blue"
    asset = @env['main.css']
    asset.to_s.should == "body {\n  color: blue; }\n"
  end

  it 'imports standard files' do
    @assets.file 'main.css.scss', %(@import "dep";\nbody { color: $color; })
    @assets.file 'dep.css.scss', '$color: blue;'
    asset = @env['main.css']
    asset.to_s.should == "body {\n  color: blue; }\n"
  end

  it 'imports partials' do
    @assets.file 'main.css.scss', %(@import "_dep";\nbody { color: $color; })
    @assets.file '_dep.css.scss', '$color: blue;'
    asset = @env['main.css']
    asset.to_s.should == "body {\n  color: blue; }\n"
  end

  it 'imports other syntax' do
    @assets.file 'main.css.scss', %(@import "dep";\nbody { color: $color; })
    @assets.file 'dep.sass', "$color: blue\nhtml\n  height: 100%"
    asset = @env['main.css']
    asset.to_s.should == "html {\n  height: 100%; }\n\nbody {\n  color: blue; }\n"
  end

  it 'imports files with the correct content type' do
    @assets.file 'main.css.scss', %(@import "dep";\nbody { color: $color; })
    @assets.file 'dep.js', 'var app = {};'
    @assets.file '_dep.css.scss', '$color: blue;'
    asset = @env['main.css']
    asset.to_s.should == "body {\n  color: blue; }\n"
  end

  it 'imports files with directives' do
    @assets.file 'main.css.scss', %(@import "dep";)
    @assets.file 'dep.css', "/*\n *= require subdep\n */"
    @assets.file 'subdep.css.scss', "$color: blue;\nbody { color: $color; }"
    asset = @env['main.css']
    asset.to_s.should include("body {\n  color: blue; }\n")
  end

  it 'imports files with additional processors' do
    @assets.file 'main.css.scss', %(@import "dep";\nbody { color: $color; })
    @assets.file 'dep.css.scss.erb', "$color: <%= 'blue' %>;"
    asset = @env['main.css']
    asset.to_s.should == "body {\n  color: blue; }\n"
  end

  it 'imports relative files' do
    @assets.file 'folder/main.css.scss', %(@import "./dep-1";\n@import "./subfolder/dep-2";\nbody { background-color: $background-color; color: $color; })
    @assets.file 'folder/dep-1.css.scss', '$background-color: red;'
    @assets.file 'folder/subfolder/dep-2.css.scss', '$color: blue;'
    asset = @env['folder/main.css']
    asset.to_s.should == "body {\n  background-color: red;\n  color: blue; }\n"
  end

  it 'imports relative partials' do
    @assets.file 'folder/main.css.scss', %(@import "./dep-1";\n@import "./subfolder/dep-2";\nbody { background-color: $background-color; color: $color; })
    @assets.file 'folder/_dep-1.css.scss', '$background-color: red;'
    @assets.file 'folder/subfolder/_dep-2.css.scss', '$color: blue;'
    asset = @env['folder/main.css']
    asset.to_s.should == "body {\n  background-color: red;\n  color: blue; }\n"
  end

  it 'imports relative files without preceding ./' do
    @assets.file 'folder/main.css.scss', %(@import "dep-1";\n@import "subfolder/dep-2";\nbody { background-color: $background-color; color: $color; })
    @assets.file 'folder/dep-1.css.scss', '$background-color: red;'
    @assets.file 'folder/subfolder/dep-2.css.scss', '$color: blue;'
    asset = @env['folder/main.css']
    asset.to_s.should == "body {\n  background-color: red;\n  color: blue; }\n"
  end

  it 'imports relative partials without preceding ./' do
    @assets.file 'folder/main.css.scss', %(@import "dep-1";\n@import "subfolder/dep-2";\nbody { background-color: $background-color; color: $color; })
    @assets.file 'folder/_dep-1.css.scss', '$background-color: red;'
    @assets.file 'folder/subfolder/_dep-2.css.scss', '$color: blue;'
    asset = @env['folder/main.css']
    asset.to_s.should == "body {\n  background-color: red;\n  color: blue; }\n"
  end

  it 'imports files relative to root' do
    @assets.file 'folder/main.css.scss', %(@import "dep";\nbody { color: $color; })
    @assets.file 'dep.css.scss', '$color: blue;'
    asset = @env['folder/main.css']
    asset.to_s.should == "body {\n  color: blue; }\n"
  end

  it 'imports partials relative to root' do
    @assets.file 'folder/main.css.scss', %(@import "dep";\nbody { color: $color; })
    @assets.file '_dep.css.scss', '$color: blue;'
    asset = @env['folder/main.css']
    asset.to_s.should == "body {\n  color: blue; }\n"
  end

  it 'shares Sass environment with other imports' do
    @assets.file 'main.css.scss', %(@import "dep-1";\n@import "dep-2";)
    @assets.file '_dep-1.scss', '$color: blue;'
    @assets.file '_dep-2.scss', 'body { color: $color; }'
    asset = @env['main.css']
    asset.to_s.should == "body {\n  color: blue; }\n"
  end

  it 'imports files from the assets load path' do
    vendor = @root.directory 'vendor'
    @env.append_path vendor.to_s

    @assets.file 'main.css.scss', %(@import "dep";\nbody { color: $color; })
    vendor.file 'dep.css.scss', '$color: blue;'
    asset = @env['main.css']
    asset.to_s.should == "body {\n  color: blue; }\n"
  end

  it 'allows global Sass configuration' do
    Sprockets::Sass.options[:style] = :compact
    @assets.file 'main.css.scss', "body {\n  color: blue;\n}"

    asset = @env['main.css']
    asset.to_s.should == "body { color: blue; }\n"
    Sprockets::Sass.options.delete(:style)
  end

  it 'imports files from the Sass load path' do
    vendor = @root.directory 'vendor'
    Sprockets::Sass.options[:load_paths] = [ vendor.to_s ]

    @assets.file 'main.css.scss', %(@import "dep";\nbody { color: $color; })
    vendor.file 'dep.scss', '$color: blue;'
    asset = @env['main.css']
    asset.to_s.should == "body {\n  color: blue; }\n"
    Sprockets::Sass.options.delete(:load_paths)
  end

  it 'works with the Compass framework' do
    @assets.file 'main.css.scss', %(@import "compass/css3";\nbutton { @include border-radius(5px); })

    asset = @env['main.css']
    asset.to_s.should include('border-radius: 5px;')
  end

  it 'imports globbed files' do
    @assets.file 'main.css.scss', %(@import "folder/*";\nbody { color: $color; background: $bg-color; })
    @assets.file 'folder/dep-1.css.scss', '$color: blue;'
    @assets.file 'folder/dep-2.css.scss', '$bg-color: red;'
    asset = @env['main.css']
    asset.to_s.should == "body {\n  color: blue;\n  background: red; }\n"
  end

  it 'adds dependencies when imported' do
    @assets.file 'main.css.scss', %(@import "dep";\nbody { color: $color; })
    dep = @assets.file 'dep.css.scss', '$color: blue;'

    asset = @env['main.css']
    asset.should be_fresh(@env)

    mtime = Time.now + 1
    dep.open('w') { |f| f.write '$color: red;' }
    dep.utime mtime, mtime

    asset.should_not be_fresh(@env)
  end

  it 'adds dependencies from assets when imported' do
    @assets.file 'main.css.scss', %(@import "dep-1";\nbody { color: $color; })
    @assets.file 'dep-1.css.scss', %(@import "dep-2";\n)
    dep = @assets.file 'dep-2.css.scss', '$color: blue;'

    asset = @env['main.css']
    asset.should be_fresh(@env)

    mtime = Time.now + 1
    dep.open('w') { |f| f.write '$color: red;' }
    dep.utime mtime, mtime

    asset.should_not be_fresh(@env)
  end

  it 'adds dependencies when imported from a glob' do
    @assets.file 'main.css.scss', %(@import "folder/*";\nbody { color: $color; background: $bg-color; })
    @assets.file 'folder/_dep-1.scss', '$color: blue;'
    dep = @assets.file 'folder/_dep-2.scss', '$bg-color: red;'

    asset = @env['main.css']
    asset.should be_fresh(@env)

    mtime = Time.now + 1
    dep.open('w') { |f| f.write "$bg-color: white;" }
    dep.utime mtime, mtime

    asset.should_not be_fresh(@env)
  end

  it "uses the environment's cache" do
    cache = {}
    @env.cache = cache

    @assets.file 'main.css.scss', %($color: blue;\nbody { color: $color; })

    @env['main.css'].to_s
    sass_cache = cache.keys.detect { |key| key =~ /main\.css\.scss/ }
    sass_cache.should_not be_nil
  end

  it 'adds the #asset_path helper' do
    @assets.file 'asset_path.css.scss', %(body { background: url(asset-path("image.jpg")); })
    @assets.file 'asset_url.css.scss', %(body { background: asset-url("image.jpg"); })
    @assets.file 'asset_path_options.css.scss', %(body { background: url(asset-path("image.jpg", $digest: true, $prefix: "/themes")); })
    @assets.file 'asset_url_options.css.scss', %(body { background: asset-url("image.jpg", $digest: true, $prefix: "/themes"); })
    @assets.file 'image.jpg'

    @env['asset_path.css'].to_s.should == %(body {\n  background: url("/assets/image.jpg"); }\n)
    @env['asset_url.css'].to_s.should == %(body {\n  background: url("/assets/image.jpg"); }\n)
    @env['asset_path_options.css'].to_s.should =~ %r(body \{\n  background: url\("/themes/image-[0-9a-f]+.jpg"\); \}\n)
    @env['asset_url_options.css'].to_s.should =~ %r(body \{\n  background: url\("/themes/image-[0-9a-f]+.jpg"\); \}\n)
  end

  it 'adds the #image_path helper' do
    @assets.file 'image_path.css.scss', %(body { background: url(image-path("image.jpg")); })
    @assets.file 'image_url.css.scss', %(body { background: image-url("image.jpg"); })
    @assets.file 'image_path_options.css.scss', %(body { background: url(image-path("image.jpg", $digest: true, $prefix: "/themes")); })
    @assets.file 'image_url_options.css.scss', %(body { background: image-url("image.jpg", $digest: true, $prefix: "/themes"); })
    @assets.file 'image.jpg'

    @env['image_path.css'].to_s.should == %(body {\n  background: url("/assets/image.jpg"); }\n)
    @env['image_url.css'].to_s.should == %(body {\n  background: url("/assets/image.jpg"); }\n)
    @env['image_path_options.css'].to_s.should =~ %r(body \{\n  background: url\("/themes/image-[0-9a-f]+.jpg"\); \}\n)
    @env['image_url_options.css'].to_s.should =~ %r(body \{\n  background: url\("/themes/image-[0-9a-f]+.jpg"\); \}\n)
  end

  it 'adds the #font_path helper' do
    @assets.file 'font_path.css.scss', %(@font-face { src: url(font-path("font.ttf")); })
    @assets.file 'font_url.css.scss', %(@font-face { src: font-url("font.ttf"); })
    @assets.file 'font_path_options.css.scss', %(@font-face { src: url(font-path("font.ttf", $digest: true, $prefix: "/themes")); })
    @assets.file 'font_url_options.css.scss', %(@font-face { src: font-url("font.ttf", $digest: true, $prefix: "/themes"); })
    @assets.file 'font.ttf'

    @env['font_path.css'].to_s.should == %(@font-face {\n  src: url("/assets/font.ttf"); }\n)
    @env['font_url.css'].to_s.should == %(@font-face {\n  src: url("/assets/font.ttf"); }\n)
    @env['font_path_options.css'].to_s.should =~ %r(@font-face \{\n  src: url\("/themes/font-[0-9a-f]+.ttf"\); \}\n)
    @env['font_url_options.css'].to_s.should =~ %r(@font-face \{\n  src: url\("/themes/font-[0-9a-f]+.ttf"\); \}\n)
  end

  it 'adds the #asset_data_uri helper' do
    @assets.file 'asset_data_uri.css.scss', %(body { background: asset-data-uri("image.jpg"); })
    @assets.file 'image.jpg', File.read('spec/fixtures/image.jpg')

    @env['asset_data_uri.css'].to_s.should == %(body {\n  background: url(data:image/jpeg;base64,%2F9j%2F4AAQSkZJRgABAgAAZABkAAD%2F7AARRHVja3kAAQAEAAAAPAAA%2F%2B4ADkFkb2JlAGTAAAAAAf%2FbAIQABgQEBAUEBgUFBgkGBQYJCwgGBggLDAoKCwoKDBAMDAwMDAwQDA4PEA8ODBMTFBQTExwbGxscHx8fHx8fHx8fHwEHBwcNDA0YEBAYGhURFRofHx8fHx8fHx8fHx8fHx8fHx8fHx8fHx8fHx8fHx8fHx8fHx8fHx8fHx8fHx8fHx8f%2F8AAEQgAAQABAwERAAIRAQMRAf%2FEAEoAAQAAAAAAAAAAAAAAAAAAAAgBAQAAAAAAAAAAAAAAAAAAAAAQAQAAAAAAAAAAAAAAAAAAAAARAQAAAAAAAAAAAAAAAAAAAAD%2F2gAMAwEAAhEDEQA%2FACoD%2F9k%3D); }\n)
  end

  it "mirrors Compass's #image_url helper" do
    @assets.file 'image_path.css.scss', %(body { background: url(image-url("image.jpg", true)); })
    @assets.file 'image_url.css.scss', %(body { background: image-url("image.jpg", false); })
    @assets.file 'cache_buster.css.scss', %(body { background: image-url("image.jpg", false, true); })
    @assets.file 'image.jpg'

    @env['image_path.css'].to_s.should == %(body {\n  background: url("/assets/image.jpg"); }\n)
    @env['image_url.css'].to_s.should == %(body {\n  background: url("/assets/image.jpg"); }\n)
    @env['cache_buster.css'].to_s.should == %(body {\n  background: url("/assets/image.jpg"); }\n)
  end

  it "mirrors Compass's #font_url helper" do
    @assets.file 'font_path.css.scss', %(@font-face { src: url(font-url("font.ttf", true)); })
    @assets.file 'font_url.css.scss', %(@font-face { src: font-url("font.ttf", false); })
    @assets.file 'font.ttf'

    @env['font_path.css'].to_s.should == %(@font-face {\n  src: url("/assets/font.ttf"); }\n)
    @env['font_url.css'].to_s.should == %(@font-face {\n  src: url("/assets/font.ttf"); }\n)
  end

  it "mirrors Sass::Rails's #asset_path helpers" do
    @assets.file 'asset_path.css.scss', %(body { background: url(asset-path("image.jpg", image)); })
    @assets.file 'asset_url.css.scss', %(body { background: asset-url("icon.jpg", image); })
    @assets.file 'image.jpg'

    @env['asset_path.css'].to_s.should == %(body {\n  background: url("/assets/image.jpg"); }\n)
    @env['asset_url.css'].to_s.should == %(body {\n  background: url("/images/icon.jpg"); }\n)
  end

  it 'allows asset helpers from within Compass mixins' do
    @assets.file 'bullets.css.scss', %(@import "compass";\nul { @include pretty-bullets('bullet.gif', 10px, 10px); })
    @assets.file 'bullet.gif'

    @env['bullets.css'].to_s.should =~ %r[background: url\("/assets/bullet\.gif"\)]
  end

  it 'compresses css' do
    css = "div {\n  color: red;\n}\n"
    Sprockets::Sass::Compressor.new.compress(css).should == "div{color:red}\n"
  end

  describe Sprockets::Sass::SassTemplate do
    describe 'initialize_engine' do
      it 'initializes super if super is uninitinalized' do
        Tilt::SassTemplate.stub(:engine_initialized?).and_return false
        template = Sprockets::Sass::SassTemplate.new {}
        template.should_receive(:require_template_library) # called from Tilt::SassTemplate.initialize
        template.initialize_engine
      end

      it "does not initializes super if super is initinalized to silence warnings" do
        Tilt::SassTemplate.stub(:engine_initialized?).and_return true
        template = Sprockets::Sass::SassTemplate.new {}
        template.should_not_receive(:require_template_library) # called from Tilt::SassTemplate.initialize
        template.initialize_engine
      end
    end
  end
end
