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
  require('time-grunt')(grunt)

  grunt.initConfig

    # load content from the package.json
    pkg: grunt.file.readJSON('package.json')
    paths: grunt.file.readJSON('conf/boilerplate.json')


    banner: '/*! <%= pkg.name %> - v<%= pkg.version %> - ' + '<%= grunt.template.today("yyyy-mm-dd") %> */'


    # process coffee-files
    coffee:
      dev:
        files: [
          expand: true
          cwd: '<%= paths.coffee %>'
          src: ['*.coffee']
          dest: '<%= paths.coffee %>pre_js'
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
      all:
        files:
          '<%= paths.js %>script.js': [
            '<%= paths.coffee %>pre_js/jquery*.js'
            '<%= paths.coffee %>pre_js/*.js'
          ]
        options:
          mangle: false

    eslint:
      options:
        config: 'conf/eslint.json'
      all: ['<%= paths.coffee %>pre_js/*.js']


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
        files: [
          expand: true
          cwd: '<%= paths.sass %>'
          src: ['css/*.css']
          dest: '<%= paths.sass %>'
        ]


    # minify css-files
    cssmin:
      options:
        banner: '<%= banner %>'
      dev:
        files: [
          expand: true
          cwd: '<%= paths.sass %>'
          src: ['css/*.css']
          dest: '<%= paths.sass %>'
        ]
      prod:
        files: [
          expand: true
          cwd: '<%= paths.sass %>'
          src: ['css/*.css']
          dest: '<%= paths.sass %>'
        ]


    copy:
      all:
        files: [
          flatten: true
          expand: true
          cwd: '<%= paths.sass %>'
          src: ['css/*.css']
          dest: '<%= paths.css %>'
        ]


    imageEmbed:
      options:
        deleteAfterEncoding : false
      all:
        files: [
          expand: true
          cwd: '<%= paths.css %>'
          src: ['*.css']
          dest: '<%= paths.css %>'
        ]


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

      styles_dev:
        files: ['<%= paths.sass %>**/*.sass']
        tasks: ['sass','newer:cssmin:dev','copy','newer:imageEmbed']
        options:
          livereload: true
      script_dev:
        files: ['<%= paths.coffee %>*.coffee']
        tasks: ['newer:coffee:dev','newer:uglify','newer:eslint']
        options:
          livereload: true

      styles_prod:
        files: ['<%= paths.sass %>**/*.sass']
        #tasks: ['newer:sass','newer:autoprefixer','newer:cssmin:prod','newer:imageEmbed']
        tasks: ['sass','newer:autoprefixer','newer:cssmin:prod','copy']
        options:
          livereload: true
      script_prod:
        files: ['<%= paths.coffee %>*.coffee']
        tasks: ['newer:coffee:prod','newer:uglify']
        options:
          livereload: true

      images:
        files: [
          'thumbs/uncompressed/**/*.{gif,png,jpg}'
        ]
        tasks: ['newer:imagemin']
        options:
          livereload: true

      templates:
        files: [
          'site/templates/**/*'
          'site/snippets/**/*'
          'site/plugins/**/*'
          'assets/images/**/*'
        ]
        options:
          livereload: true


    php:
      all:
        options:
          port: 1337
          hostname: 'localhost'
          base: '<%= paths.base %>'
          keepalive: true
          open: true


    concurrent:
      dev:
        tasks: ['php','switchwatch:styles_dev:script_dev:images:templates']
      prod:
        tasks: ['php','switchwatch:styles_prod:script_prod:images:templates']
      options:
        logConcurrentOutput: true


  # Run with: grunt switchwatch:target1:target2 to only watch those targets
  grunt.registerTask 'switchwatch', ->
    targets = Array.prototype.slice.call(arguments, 0)
    Object.keys(grunt.config('watch')).filter (target) ->
      return !(grunt.util._.indexOf(targets, target) != -1)
    .forEach (target) ->
      grunt.log.writeln('Ignoring ' + target + '...')
      grunt.config(['watch', target], {files: []})
    grunt.task.run('watch')


  grunt.registerTask('server', ['php'])

  #grunt.registerTask('dev', ['switchwatch:styles_dev:script_dev:images:templates'])
  grunt.registerTask('dev', ['concurrent:dev'])
  #grunt.registerTask('prod',['switchwatch:styles_prod:script_prod:images:templates'])
  grunt.registerTask('prod',['concurrent:dev'])
