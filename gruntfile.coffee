# # Globbing
# for performance reasons we're only matching one level down:
# 'test/spec/{,*/}*.js'
# use this if you want to recursively match all subfolders:
# 'test/spec/**/*.js'
# 
spawn = require('child_process').spawn;

module.exports = (grunt) ->
  # Load grunt tasks automatically
  require('load-grunt-tasks')(grunt);

  # Time how long tasks take. Can help when optimizing build times
  require('time-grunt')(grunt);

  # Define the configuration for all the tasks
  grunt.initConfig
    # Project settings
    pkg: grunt.file.readJSON 'package.json'
    cfg:
      fed: grunt.file.readJSON 'fedConfig.json'
      path:
        src: "frontend"
        build: ".tmp"
        dist: "dist"

    # Watches files for changes and runs tasks based on the changed files
    watch: {
      js: 
        files: ['<%= cfg.path.src %>/scripts/{,*/}*.js']
        tasks: ['newer:jshint']
        options: 
          livereload: true
      
      coffee:
        files: ['<%= cfg.path.src %>/scripts/{,*/}*.coffee']
        tasks: ['newer:coffee']
        options: 
          livereload: true

      css:
        files: ['<%= cfg.path.src %>/styles/{,*/}*.css']
        tasks: ['newer:copy:styles', 'autoprefixer']
        options: 
          livereload: true

      less:
        files: ['<%= cfg.path.src %>/styles/{,*/}*.less']
        tasks: ['newer:less', 'autoprefixer']
        options: 
          livereload: true

      gruntfile: 
        files: ['gruntfile.coffee']
    }

    # Open browser
    open: {
      dev : 
        path: 'http://<%= cfg.fed.server.hostname%>:<%= cfg.fed.server.port%>',
        app: 'Google Chrome'
    }

    # The actual grunt server settings
    connect: {
      options: 
        port: '<%= cfg.fed.server.port%>'
        # Change this to '0.0.0.0' to access the server from outside.
        hostname: '<%= cfg.fed.server.hostname%>'
        livereload: 35729
      
      livereload:
        options:
          open: true
          base: [
            '.tmp'
            '<%= cfg.path.src %>'
          ]   

      dist: 
        options: 
          open: true
          base: '<%= cfg.path.dist %>'
        
    }

    # Make sure code styles are up to par and there are no obvious mistakes
    jshint:{
      options:
        jshint: ".jshintrc"
        reporter: require('jshint-stylish')
      src: ['<%= cfg.path.src %>/scripts/{,*/}*.js']
    }

    # compile *.coffee
    coffee: {
      compile: 
        files: [
          {
            expand: true
            cwd: "<%=cfg.path.src%>/scripts"
            src: ["{,*/}*.coffee"]
            dest: "<%=cfg.path.build%>/scripts"
            ext: ".js"
          }
        ]
    }

    # compile *.less
    less: {
      compile: 
        files: [
          {
            expand: true
            cwd: "<%=cfg.path.src%>/styles"
            src: ["{,*/}*.less", '!{,*/}*.mixin.less'] # mixin的less文件不参与编译
            dest: '<%=cfg.path.build%>/styles'
            ext: ".css"
          }
        ]
    }

    # Add vendor prefixed styless
    autoprefixer: {
      options: 
        browsers: ['last 1 version']
      dist:
        files: [
          {
            expand: true,
            cwd: '.tmp/styles/',
            src: '{,*/}*.css',
            dest: '.tmp/styles/'
          }
        ]
    }

    # Automatically inject Bower components into the app
    'bower-install': {
      src: 
        html: '<%= cfg.path.src %>/index.html',
        ignorePath: '<%= cfg.path.src %>/'
    }

    # Renames files for browser caching purposes
    rev: {
      dist: 
        files: {
          src: [
            '<%= cfg.path.dist %>/scripts/{,*/}*.js'
            '<%= cfg.path.dist %>/styles/{,*/}*.css'
            '<%= cfg.path.dist %>/images/{,*/}*.{png,jpg,jpeg,gif,webp,svg}'
            '<%= cfg.path.dist %>/styles/fonts/*'
          ]
        }
    }

    # Empties folders to start fresh
    clean: {
      dist:
        files: [
          {
            dot: true,
            src: [
              '.tmp',
              '<%= cfg.path.dist %>/*',
              '!<%= cfg.path.dist %>/.git*'
            ]
          }
        ]
      server: '.tmp'
    }

    # Copies remaining files to places other tasks can use
    copy: {
      dist: 
        files: [{
          expand: true,
          dot: true,
          cwd: '<%= cfg.path.src %>'
          dest: '<%= cfg.path.dist %>'
          src: [
            '*.{ico,png,txt}'
            '.htaccess'
            '*.html'
            'views/{,*/}*.html'
            'bower_components/**/*'
            'images/{,*/}*.{webp}'
            'fonts/*'
          ]
        }, {
          expand: true
          cwd: '.tmp/images'
          dest: '<%= cfg.path.dist %>/images'
          src: ['generated/*']
        }]
      
      styles: 
        expand: true
        cwd: '<%= cfg.path.src %>/styles'
        dest: '.tmp/styles/'
        src: '{,*/}*.css'
      scripts:
        expand: true
        cwd: '<%= cfg.path.src %>/scripts'
        dest: '.tmp/scripts/'
        src: '{,*/}*.js'
      
    }

    # Reads HTML for usemin blocks to enable smart builds that automatically
    # concat, minify and revision files. Creates configurations in memory so
    # additional tasks can operate on them
    useminPrepare: {
      html: '<%= cfg.path.src %>/index.html',
      options: 
        dest: '<%= cfg.path.dist %>'
    }

    # Performs rewrites based on rev and the useminPrepare configuration
    usemin: {
      html: ['<%= cfg.path.dist %>/{,*/}*.html'],
      css: ['<%= cfg.path.dist %>/styles/{,*/}*.css'],
      options: 
        assetsDirs: ['<%= cfg.path.dist %>']
      
    }

    # The following *-min tasks produce minified files in the dist folder
    imagemin: {
      dist: 
        files: [{
          expand: true,
          cwd: '<%= cfg.path.src %>/images'
          src: '{,*/}*.{png,jpg,jpeg,gif}'
          dest: '<%= cfg.path.dist %>/images'
        }]
    }
    svgmin: {
      dist: 
        files: [{
          expand: true,
          cwd: '<%= cfg.path.src %>/images'
          src: '{,*/}*.svg'
          dest: '<%= cfg.path.dist %>/images'
        }]
    }
    # htmlmin: {
    #   dist: {
    #     options: {
    #       collapseWhitespace: true
    #       collapseBooleanAttributes: true
    #       removeCommentsFromCDATA: true
    #       removeOptionalTags: true
    #     },
    #     files: [{
    #       expand: true
    #       cwd: '<%= cfg.path.dist %>'
    #       src: ['*.html', 'views/{,*/}*.html']
    #       dest: '<%= cfg.path.dist %>'
    #     }]
    #   }
    # }
    

    # Run some tasks in parallel to speed up the build process
    # concurrent: {
    #   server: [
    #     'coffee'
    #     'less'
    #     'copy:styles'
    #     'copy:scripts'
    #   ]
    #   dist: [
    #     'copy:styles'
    #     'imagemin'
    #     'svgmin'
    #   ]
    # }

  # ----- tasks config end ----- #

  grunt.registerTask 'serve', (target)->

    # grunt.util.spawn {
    #   cmd: "fed"
    #   args: ["server", "fedConfig.json"]
    # }, ()->
    #   grunt.log.writeln('FED has started ......')

    if target is 'dist'
      return grunt.task.run(['build', 'connect:dist:keepalive'])
    grunt.task.run([
      'clean:server'
      'bower-install'
      'coffee'
      'less'
      'copy:styles'
      'copy:scripts'
      'autoprefixer'
      'connect:livereload'
      'watch'
    ])

  grunt.registerTask 'build', [
    'clean:dist'
    'bower-install'
    'useminPrepare'
    'coffee'
    'less'
    'copy:styles'
    'copy:scripts'
    'imagemin'
    'svgmin'
    'autoprefixer'
    'concat'
    'copy:dist'
    'cssmin'
    'uglify'
    'rev'
    'usemin'
  ]





