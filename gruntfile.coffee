module.exports = (grunt) ->

  # Get all grunt modules
  require('matchdep').filterDev('grunt-*').forEach(grunt.loadNpmTasks)
  require('time-grunt')(grunt)

  # Project configuration.
  grunt.initConfig

    # Collect data about the project
    pkg: grunt.file.readJSON('package.json')

    # Set Banner for some generated files
    banner: '/*! <%= pkg.name %> - v<%= pkg.version %> - ' + '<%= grunt.template.today("yyyy-mm-dd") %> */\n'

    # coffee
    coffee:
      all:
        files: [
          expand: true
          cwd: '<%= pkg.paths.src.coffee %>'
          src: ['*.coffee']
          dest: '<%= pkg.paths.src.js %>'
          ext: '.js'
        ]

    # concat
    concat:
      all:
        src: [
          '<%= pkg.paths.src.js %>*.js'
        ]
        dest: '<%= pkg.paths.build.js %>script.js'

    # eslint
    eslint:
      options:
        config: '<%= pkg.esLintRules %>'
      all: ['<%= pkg.paths.src.js %>*.js']

    # sass
    sass:
      all:
        files: [
          expand: true
          cwd: '<%= pkg.paths.src.sass %>'
          src: ['*.sass','!_*.sass']
          dest: '<%= pkg.paths.src.css %>'
          ext: '.css'
        ]

    # autoprefixer
    autoprefixer:
      all:
        files: [
          expand: true
          cwd: '<%= pkg.paths.src.css %>'
          src: ['*.css']
          dest: '<%= pkg.paths.src.css %>'
          ext: '.css'
        ]

    # imageEmbed
    # REMEMBER! Fonts should be ignored
    # by trailing a `/*ImageEmbed:skip*/`
    # after `src: url(...)`
    imageEmbed:
      options:
        deleteAfterEncoding : false
      all:
        files: [
          expand: true
          cwd: '<%= pkg.paths.src.css %>'
          src: ['*.css']
          dest: '<%= pkg.paths.src.css %>'
        ]

    # cssmin
    cssmin:
      options:
        banner: '<%= banner %>'
      all:
        files: [
          expand: true
          cwd: '<%= pkg.paths.src.css %>'
          src: ['*.css']
          dest: '<%= pkg.paths.build.css %>'
          ext: '.css'
        ]

    # watch
    watch:
      # watch coffee
      coffee:
        files: ['<%= pkg.paths.src.coffee %>*.coffee']
        tasks: ['blink1:bad', 'newer:coffee', 'newer:eslint', 'concat', 'blink1:good']
        options:
          livereload: true
      # watch sass
      sass:
        files: ['<%= pkg.paths.src.sass %>*.sass']
        tasks: ['blink1:bad', 'newer:sass', 'newer:autoprefixer', 'newer:imageEmbed', 'newer:cssmin', 'blink1:good']
        options:
          livereload: true

      # watch copy
      copy:
        files: [
          '<%= pkg.paths.src.dir %>*'
          '<%= pkg.paths.src.dir %>site/**/*'
          '<%= pkg.paths.src.dir %>images/**/*'
        ]
        tasks: ['newer:copy']
        options:
          livereload: true

      # watch content
      content:
        files: [
          '<%= pkg.paths.src.dir %>content/**/*'
        ]
        tasks: ['newer:copy']
        options:
          livereload: true

    # copy
    copy:
      all:
        files: [
          expand: true
          cwd: '<%= pkg.paths.src.dir %>'
          src: ['**/*','!<%= pkg.paths.src.dir %>**','<%= pkg.paths.src.dir %>images/**/*']
          dest: '<%= pkg.paths.build.dir %>'
        ]

    # php
    php:
      all:
        options:
          port: 1337
          hostname: 'localhost'
          base: '<%= pkg.paths.root %>'
          keepalive: true
          open: true

    # concurrent
    concurrent:
      all:
        tasks: ['php','watch','notify']
      options:
        logConcurrentOutput: true

    # notify
    notify:
      server:
        options:
          title: 'Yo'
          message: 'Server läuft auf <%= php.all.options.hostname %>:<%= php.all.options.port %>'

    # blink1
    color:
      process: '#660'
      good: '#086'
      bad: '#900'

    blink1:
      off:
        options:
          turnOff: true
      good:
        colors: ['<%= color.good %>']
        options:
          #turnOff: true
          ledIndex: 2
          fadeMillis: 500
      bad:
        colors: ['<%= color.bad %>']
        options:
          ledIndex: 2
          fadeMillis: 500

  # Default task(s)
  grunt.registerTask('scripts', ['coffee', 'eslint', 'concat'])
  grunt.registerTask('styles', ['sass', 'autoprefixer', 'imageEmbed', 'cssmin'])
  grunt.registerTask('styles', ['sass', 'autoprefixer', 'cssmin'])
  grunt.registerTask('default', ['blink1:off', 'scripts', 'styles', 'blink1:good', 'concurrent'])
