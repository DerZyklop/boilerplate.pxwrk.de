module.exports = (grunt) ->

  # Get all grunt modules
  require('matchdep').filterDev('grunt-*').forEach(grunt.loadNpmTasks)

  # Project configuration.
  grunt.initConfig

    # Collect data about the project
    pkg: grunt.file.readJSON('package.json')
    paths: grunt.file.readJSON('paths.json')

    # Set Banner for some generated files
    banner: '/*! <%= pkg.name %> - v<%= pkg.version %> - ' + '<%= grunt.template.today("yyyy-mm-dd") %> */\n'

    # coffee
    coffee:
      all:
        files: [
          expand: true
          cwd: '<%= paths.src.coffee %>'
          src: ['*.coffee']
          dest: '<%= paths.src.js %>'
          ext: '.js'
        ]

    # eslint
    eslint:
      options:
        config: 'eslint.json'
      all: ['<%= paths.src.js %>*.js']

    # uglify
    uglify:
      options:
        banner: '<%= banner %>'
      all:
        files: [
          expand: true
          cwd: '<%= paths.src.js %>'
          src: ['*.js']
          dest: '<%= paths.build.js %>'
          ext: '.min.js'
        ]

    # sass
    sass:
      all:
        files: [
          expand: true
          cwd: '<%= paths.src.sass %>'
          src: ['*.sass']
          dest: '<%= paths.src.css %>'
          ext: '.css'
        ]

    # autoprefixer
    autoprefixer:
      all:
        files: [
          expand: true
          cwd: '<%= paths.src.css %>'
          src: ['*.css']
          dest: '<%= paths.src.css %>'
          ext: '.css'
        ]

    # imageEmbed
    imageEmbed:
      options:
        deleteAfterEncoding : false
      all:
        files: [
          expand: true
          cwd: '<%= paths.src.css %>'
          src: ['*.css']
          dest: '<%= paths.src.css %>'
        ]

    # cssmin
    cssmin:
      options:
        banner: '<%= banner %>'
      all:
        files: [
          expand: true
          cwd: '<%= paths.src.css %>'
          src: ['*.css']
          dest: '<%= paths.build.css %>'
          ext: '.min.css'
        ]

    # watch
    watch:
      # watch coffee
      coffee:
        files: ['<%= paths.src.coffee %>*.coffee']
        tasks: ['newer:coffee', 'newer:eslint', 'newer:uglify']
        options:
          livereload: true
      # watch sass
      sass:
        files: ['<%= paths.src.sass %>*.sass']
        tasks: ['newer:sass', 'newer:autoprefixer', 'newer:imageEmbed', 'newer:cssmin']
        options:
          livereload: true

      # watch templates
      templates:
        files: ['<%= paths.src.dir %>*.{html,php}']
        tasks: ['newer:copy']
        options:
          livereload: true

    # copy
    copy:
      all:
        files: [
          expand: true
          cwd: '<%= paths.src.dir %>'
          src: ['*.{html,php}']
          dest: '<%= paths.build.dir %>'
        ]

    # php
    php:
      all:
        options:
          port: 1337
          hostname: 'localhost'
          base: '<%= paths.build.dir %>'
          keepalive: true
          open: true

  # Default task(s)
  grunt.registerTask('default', ['watch'])
  grunt.registerTask('server', ['php'])
