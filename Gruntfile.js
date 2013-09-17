'use strict';


module.exports = function (grunt) {
    // Load all grunt tasks
    require('matchdep').filterDev('grunt-*').forEach(grunt.loadNpmTasks);

    grunt.initConfig({

        watch: {
            coffeescript: {
                files: ['src/*.coffee'],
                tasks: ['coffee', 'jshint']
            }
        },


        coffee: {
            compile: {
                options: {
                    join: true
                },
                files: {
                    'dist/cookiemonster.js': ['src/constants.coffee',
                                              'src/util.coffee',
                                              'src/cookiemonster.coffee']
                }
            }
        },


        jshint: {
            all: ['dist/*.js']
        }

    });

    grunt.registerTask('default', [
        'coffee',
        'jshint',
        'watch'
    ]);
};