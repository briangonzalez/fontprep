sprockets-sass
==============

**Better Sass integration with [Sprockets 2.x](http://github.com/sstephenson/sprockets)**

When using Sprockets 2.x with Sass you will eventually run into a pretty big issue. `//= require` directives will not allow Sass mixins, variables, etc. to be shared between files. So you'll try to use `@import`, and that'll also blow up in your face. `sprockets-sass` fixes all of this by creating a Sass::Importer that is Sprockets aware.

_Note: This works in Rails 3.1, thanks to the [sass-rails gem](http://github.com/rails/sass-rails). But if you want to use Sprockets and Sass anywhere else, like Sinatra, use `sprockets-sass`._

### Features

* Imports Sass _partials_ (filenames prepended with "_").
* Import paths work exactly like `require` directives.
* Imports either Sass syntax, or just regular CSS files.
* Imported files are preprocessed by Sprockets, so `.css.scss.erb` files can be imported.
  Directives from within imported files also work as expected.
* Automatic integration with Compass.
* Supports glob imports, like sass-rails.
* Asset path Sass functions. **New in 0.4!**


Installation
------------

``` bash
$ gem install sprockets-sass
```


Usage
-----

In your Rack application, setup Sprockets as you normally would, and require "sprockets-sass":

``` ruby
require "sprockets"
require "sprockets-sass"
require "sass"

map "/assets" do
  environment = Sprockets::Environment.new
  environment.append_path "assets/stylesheets"
  run environment
end

map "/" do
  run YourRackApp
end
```

Now `@import` works essentially just like a `require` directive, but with one essential bonus:
Sass mixins, variables, etc. work as expected.

Given the following Sass _partials_:

``` scss
// assets/stylesheets/_mixins.scss
@mixin border-radius($radius) {
  -webkit-border-radius: $radius;
  -moz-border-radius: $radius;
  border-radius: $radius;
}
```

``` scss
// assets/stylesheets/_settings.scss
$color: red;
```

In another file - you can now do this - from within a Sprockets asset:

``` scss
// assets/stylesheets/application.css.scss
@import "mixins";
@import "settings";

button {
  @include border-radius(5px);
  color: $color;
}
```

And `GET /assets/application.css` would return something like:

``` css
button {
  -webkit-border-radius: 5px;
  -moz-border-radius: 5px;
  border-radius: 5px;
  color: red; }
```

Passing Options to the Sass Engine
----------------------------------

If you would like to configure any of the Sass options, you can do so like this:

```ruby
Sprockets::Sass.options[:line_comments] = true
```

Compass Integration
-------------------

As of version 0.3.0, Compass is automatically detected and integrated. All you have to do
is configure Compass like you normally would:

``` ruby
require "sprockets"
require "sprockets-sass"
require "sass"
require "compass"

Compass.configuration do |compass|
  # ...
end

map "/assets" do
  environment = Sprockets::Environment.new
  environment.append_path "assets/stylesheets"
  run environment
end

# etc...
```

The load paths and other options from Compass are automatically used:

``` scss
// assets/stylesheets/application.css.scss
@import "compass/css3";

button {
  @include border-radius(5px);
}
```


Asset Path Sass Functions
-------------------------

As of version 0.4.0, asset path helpers have been added. In order to use them you must add [sprockets-helpers](https://github.com/petebrowne/sprockets-helpers) to your Gemfile:

``` ruby
gem "sprockets-sass",    "~> 0.5"
gem "sprockets-helpers", "~> 0.2"
# etc...
```

Here's a quick guide to setting up sprockets-helpers in your application (look at the project's [README](https://github.com/petebrowne/sprockets-helpers/blob/master/README.md) for more information):

``` ruby
require "sprockets"
require "sprockets-sass"
require "sprockets-helpers"
require "sass"

map "/assets" do
  environment = Sprockets::Environment.new
  environment.append_path "assets/stylesheets"
  
  Sprockets::Helpers.configure do |config|
    config.environment = environment
    config.prefix      = "/assets"
    config.digest      = false
  end
  
  run environment
end

# etc...
```

The Sass functions are based on the ones in sass-rails. So there is a `-path` and `-url` version of each helper:

``` scss
background: url(asset-path("logo.jpg")); // background: url("/assets/logo.jpg");
background: asset-url("logo.jpg");       // background: url("/assets/logo.jpg");
```

The API of the functions mimics the helpers provided by sprockets-helpers, using Sass keyword arguments as options:

``` scss
background: asset-url("logo.jpg", $digest: true);               // background: url("/assets/logo-27a8f1f96afd8d4c67a59eb9447f45bd.jpg");
background: asset-url("logo", $prefix: "/themes", $ext: "jpg"); // background: url("/themes/logo.jpg");
```

As of version 0.6.0, `#asset_data_uri` has been added, which creates a data URI for the given asset:

``` scss
background: asset-data-uri("image.jpg"); // background: url(data:image/jpeg;base64,...);
```


Copyright
---------

Copyright (c) 2011 [Peter Browne](http://petebrowne.com). See LICENSE for details.
