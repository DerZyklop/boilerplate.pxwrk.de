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
      all:
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
      all:
        expand: false
        flatten: true
        src: '<%= paths.sass %>prefixed_css/*.css'
        dest: '<%= paths.css %><%= paths.sassfilename %>.css'

    # test accessability
    shell:
      pa11y:
        options:
          stdout: true
        command: 'pa11y http://<%= php.all.options.hostname %>:<%= php.all.options.port%>'


    watch:
      options:
        livereload: true
      livereload:
        files: [
          '<%= paths.css %>**/*.css'
          '<%= paths.js %>**/*.js'
        ]
        tasks: ['reload']

      sass:
        files: ['<%= paths.sass %>**/*.sass']
        tasks: ['sass']
      prefixes:
        files: ['<%= paths.sass %>css/*.css']
        tasks: ['autoprefixer']
      cssmin:
        files: ['<%= paths.sass %>prefixed_css/*.css']
        tasks: ['cssmin']

      coffee:
        files: ['<%= paths.coffee %>*.coffee']
        tasks: ['coffee']
      js:
        files: [
          '<%= paths.coffee %>pre_js/*.js'
        ]
        tasks: ['uglify']
      tmpl:
        files: [
          'site/templates/*'
          'site/snippets/*'
          'site/plugins/*'
        ]
        tasks: ['reload']

    php:
      all:
        options:
          port: 1337
          hostname: 'localhost'
          base: '<%= paths.base %>'
          keepalive: true

    open:
      all:
        path: 'http://<%= php.all.options.hostname %>:<%= php.all.options.port%>'


  grunt.registerTask "reload", "reload Chrome on OS X", ->
    require("child_process").exec("osascript " +
        "-e 'tell application \"Google Chrome\" " +
          "to tell the active tab of its first window' " +
        "-e 'reload' " +
        "-e 'end tell'")


  grunt.registerTask('server', ['open','php'])
  grunt.registerTask('test', ['shell:pa11y'])
  grunt.registerTask('default', ['reload','watch'])
