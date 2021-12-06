"use strict";

var gulp        = require('gulp');
var sass        = require('gulp-sass');
var minify      = require('gulp-minify');
var watch       = require('gulp-watch');

var scssOptions = {
    errLogToConsole: true,
    outputStyle: 'compressed'
};

gulp.task('scssMain', function () {

    return gulp.src('www/content/scss/*.scss')
        .pipe(sass(scssOptions))
        .pipe(gulp.dest('www/content/css/'));
});

gulp.task('scssTemplates', function () {
    
    return gulp.src('www/content/scss/templates/*.scss')
        .pipe(sass(scssOptions))
        .pipe(gulp.dest('www/content/css/templates/'));
});

// Watch task
gulp.task('watch', function() {
    watch('www/content/scss/*.scss', gulp.series(['scssMain', 'scssTemplates']));
    watch('www/content/scss/**/*.scss', gulp.series(['scssMain', 'scssTemplates']));
});

gulp.task('default', gulp.series(['scssMain', 'scssTemplates', 'watch']));