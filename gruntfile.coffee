# +---------------------------------------------+ #
# |#############################################| #
# |###################EEEEEEE###################| #
# |##################/      /\##################| #
# |#################/      /  \#################| #
# |################/      /    \################| #
# |###############/      /      \###############| #
# |##############/      /        \##############| #
# |#############/      /     A    \#############| #
# |############/      /     / \    \############| #
# |###########/      /     /   \    \###########| #
# |##########/      /     /     \    \##########| #
# |#########/      /     /#\     \    \#########| #
# |########/      /     /###\     \    \########| #
# |#######/      /     /#####\     \    \#######| #
# |######/      /_____/EEEEEEE\     \    \######| #
# |#####/                      \     \    \#####| #
# |####(________________________\     \    )####| #
# |#####\                              \  /#####| #
# |######\______________________________\/######| #
# |#############################################| #
# |############# +-------------------+ #########| #
# |############# | www.der-zyklop.de | #########| #
# |############# +-------------------+ #########| #
# |#############################################| #
# +–––––––––––––––––––––––––––––––––––––––––––––+ #

# Info's about this Gruntfile: https://github.com/DerZyklop/boilerplate.pxwrk.de

module.exports = (grunt) ->

  require('matchdep').filterDev('grunt-*').forEach(grunt.loadNpmTasks)

  grunt.initConfig

    # load content from the package.json
    pkg: grunt.file.readJSON('package.json')

    # Set up some vars
    paths:
      base: ''
      assets: '<%= paths.base %>assets/'
      coffee: '<%= paths.assets %>coffee/'
      js: '<%= paths.assets %>js/'
      sass: '<%= paths.assets %>sass/'
      css: '<%= paths.assets %>styles/'
      sassfilename: 'styles'

    banner: '/*! <%= pkg.name %> - v<%= pkg.version %> - ' + '<%= grunt.template.today("yyyy-mm-dd") %> */'


    # process coffee-files
    coffee:
      dev:
        files: [
          expand: true
          cwd: '<%= paths.coffee %>'
          src: ['*.coffee']
          dest: '<%= paths.js %>script.js'
          ext: '.js'
        ]
      prod:
        options:
          join: false
          bare: true
        files: [
          expand: true
          cwd: '<%= paths.coffee %>'
          src: ['*.coffee']
          dest: '<%= paths.coffee %>pre_js'
          ext: '.js'
        ]

    # minify js-files
    uglify:
      options:
        banner: '<%= banner %>'
      js:
        files:
          '<%= paths.js %>script.min.js': [
            '<%= paths.coffee %>pre_js/jquery*.js'
            '<%= paths.coffee %>pre_js/*.js'
          ]
        options:
          mangle: false


    # process sass-files
    sass:
      all:
        options:
          compass: true
          style: 'compressed'
        files: '<%= paths.sass %>css/<%= paths.sassfilename %>.css': '<%= paths.sass %><%= paths.sassfilename %>.sass'

    # add and remove prefixes
    autoprefixer:
      all:
        expand: true
        flatten: true
        src: '<%= paths.sass %>css/*.css'
        dest: '<%= paths.sass %>prefixed_css/'

    # minify css-files
    cssmin:
      options:
        banner: '<%= banner %>'
      dev:
        expand: false
        flatten: true
        src: '<%= paths.sass %>css/*.css'
        dest: '<%= paths.css %><%= paths.sassfilename %>.css'
      prod:
        expand: false
        flatten: true
        src: '<%= paths.sass %>prefixed_css/*.css'
        dest: '<%= paths.css %><%= paths.sassfilename %>.css'

    # compress images
    imagemin:
      options:
        optimizationLevel: 7
      all:
        files: [
          expand: true
          cwd: './thumbs/uncompressed'
          src: ['**/*.{gif,png}']
          dest: './thumbs/'
        ]
      jpg:
        options:
          progressive: true
        files: [
          expand: true
          cwd: './thumbs/uncompressed'
          src: ['**/*.jpg']
          dest: './thumbs/'
        ]


    # test accessability
    shell:
      pa11y:
        options:
          stdout: true
        command: 'pa11y http://<%= php.all.options.hostname %>:<%= php.all.options.port%>'


    watch:
      options:
        livereload: true

      styles_dev:
        files: ['<%= paths.sass %>**/*.sass']
        tasks: ['newer:sass','newer:cssmin:dev']
      script_dev:
        files: ['<%= paths.coffee %>*.coffee']
        tasks: ['newer:coffee:dev']

      styles_prod:
        files: ['<%= paths.sass %>**/*.sass']
        tasks: ['newer:sass','newer:autoprefixer','newer:cssmin:prod']
      script_prod:
        files: ['<%= paths.coffee %>*.coffee']
        tasks: ['newer:coffee:prod','newer:uglify']

      images:
        files: [
          'thumbs/uncompressed/**/*.{gif,png,jpg}'
        ]
        tasks: ['newer:imagemin']

      templates:
        files: [
          'site/templates/**/*'
          'site/snippets/**/*'
          'site/plugins/**/*'
        ]

    php:
      all:
        options:
          port: 1337
          hostname: 'localhost'
          base: '<%= paths.base %>'
          keepalive: true
          open: true

    concurrent:
      dev: ['watch']
      options:
        logConcurrentOutput: true


  grunt.registerTask('server', ['php'])

  #grunt.registerTask('test', ['shell:pa11y'])

  grunt.registerTask('default', ['watch'])
  grunt.registerTask('dev', ['concurrent:dev']);
