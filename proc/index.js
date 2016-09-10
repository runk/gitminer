var fs = require('fs');
var spawn = require('child_process').spawn;
var jade = require('jade');

// data = fs.readFileSync('./data', 'utf8');

/*
deadrunk@gmail.com
2014-07-03 17:04:52 +1000

1 1 advertiser/lib/routes/payment.coffee
6 1 common/lib/utils/plan.coffee
*/
exports.parse = function(body) {
  p = {};

  body = body.split('\n\n');
  var p = {
    author: body[0],
    date: new Date(body[1]),
    files: {},
    overall: {files: 0, '+': 0, '-': 0}
  };

  var files = (body[2] || '').split('\n');
  for (var i = files.length - 1; i >= 0; i--) {
    var line = files[i];

    if (!line || line[0] === '-')
      continue; // empty line or binary file

    line = line.split('\t');
    p.overall.files++;
    p.overall['+'] += +line[0];
    p.overall['-'] += +line[1];
    p.files[line[2]] = {'+': +line[0], '-': +line[1]}
  };
  return p;
}

exports.parseLog = function(buffer) {
  var commits = buffer.split('\n\n\n');
  var result = [];
  for (var i = 0; i < commits.length; i++) {
    var body = commits[i];
    if (!body) continue;
    result.push(exports.parse(body));
  };
  return result;
}

exports.gitLog = function(cb) {
  process.chdir('/Users/runk/projects/direct-web');

  var format = '%n%n%an <%ae>%n%n%ci';
  // var format = '%n%n%ae%n%n%ci;

  log = spawn('git', ['log', '--format=' + format, '--numstat', '--since=2014-01-01', '--no-merges', '--date-order']);
  var buffer = '\n'
  log.stdout.on('data', function (data) {
    buffer += data.toString();
  });

  log.stderr.on('data', function (data) {
    console.error(data);
  });

  log.on('close', function (code) {
    var commits = exports.parseLog(buffer);
    cb(null, commits);
  });
};


exports.main = function(commits, cb) {
  var fn = jade.compile(
    fs.readFileSync(__dirname + '/report.jade'),
    {filename: __dirname + '/report.jade'}
  );

  var html = fn(exports.context(commits));
  cb(null, html);
};

exports.context = function(commits) {
  var timeline = require('./plugins/timeline')(commits);
  var hot = require('./plugins/hot')(commits);
  var responsible = require('./plugins/responsible')(commits);
  var sloc = require('./plugins/sloc')(commits);

  return {
    sloc: sloc,
    timeline: timeline,
    hot: hot,
    responsible: responsible
  };
}
