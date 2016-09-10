var _ = require('lodash');

module.exports = function(commits) {
  var result = {};

  var byAuthor = _.groupBy(commits, 'author');
  for (var author in byAuthor) {
    var map = {}
    for (var i = byAuthor[author].length - 1; i >= 0; i--) {
      var commit = byAuthor[author][i];
      for (var file in commit.files) {
        map[file] = map[file] || {times: 0, lines: 0};
        map[file].times++;
        map[file].lines += commit.files[file]['+'] + commit.files[file]['-'];
      }
    };

    var tmp = [];
    for (file in map)
      tmp.push({file: file, times: map[file].times, lines: map[file].lines});

    tmp.sort(function(a, b) { return b.times - a.times });
    result[author] = tmp.slice(0, 5);
  }
  return result;
}
