Highcharts.setOptions({
   global: { useUTC: false }
});

var Redmon = (function() {
  var config
    , events = $({});

  /**
   * Loads the last 100 events and starts the periodic polling for new events.
   */
  function init(opts) {
    config = opts;
    toolbar.init();
    cli.init();
  //requestData(100, function(data) {
  //  renderDashboard(data);
  //  poll();
  //});
  }

  /**
   * Render the dashboard.
   */
  function renderDashboard(data) {
    memoryWidget.render(data);
    keyspaceWidget.render(data);
    infoWidget.render(data);
    //configWidget.render();
  }

  /**
   * Request the last {count} events.
   */
  function requestData(count, callback) {
    $.ajax({
      url: 'stats?count='+count,
      success: function(data) {
        callback(
          data.map(function(info) {
            return $.parseJSON(info);
          })
        );
      }
    });
  }

  /**
   * Request data from the server, add it to the graph and set a timeout to request again
   */
  function poll() {
    requestData(1, function(data) {
      events.trigger('data', data[0]);
      setTimeout(poll, config.pollInterval);
    });
  }

  function formatDate(date) {
    var d = new Date(parseInt(parseInt(date)));
    return d.getMonth()+1+'/'+d.getDate()+' '+d.getHours()+':'+d.getMinutes()+':'+d.getSeconds();
  }

  //////////////////////////////////////////////////////////////////////
  // toolbar: nav + event listeners
  var toolbar = (function() {
    var mapping = {}
      , current = {};

    function init() {
    //['dashboard', 'keys', 'cli', 'config'].forEach(function(el) {
    //  mapping[el] = $('#'+el)
    //  mapping[el].click(onNavClick);
    //});
    //current.tab   = mapping.dashboard;
    //current.panel = $('.viewport .dashboard');

      $('#flush-btn').click(function() {
        $('#flush-confirm').modal({
          backdrop: true,
          keyboard: true,
          show:     true
        });
      });

      $('#flush-cancel-btn').click(closeModal);

      $('#flush-confirm-btn').click(function() {
        onBtnClick('flushdb');
        closeModal();
      });

      $('#reset-btn').click(function() {
        onBtnClick('config resetstat');
        $('#info-tbl').effect("highlight", {}, 2000);
      });
    }

    function closeModal() {
      $('#flush-confirm').modal('hide');
    }

    function onNavClick(ev) {
      var tab = $(ev.currentTarget);
      if (!tab.hasClass('active')) {
        tab.addClass('active');
        current.tab.removeClass('active');

        var panel = $('.viewport .'+tab.attr('id'));
        current.panel.addClass('hidden');
        panel.removeClass('hidden').addClass('show');

        if (tab.dom === mapping.cli.dom) {
          cli.focus();
        }

        current = {tab: tab, panel: panel};
      }
    }

    function onBtnClick(cmd) {
      $.ajax({url: 'redis_infos/terminal?command='+cmd});
    }

    return {
      init: init
    }
  })();

  //////////////////////////////////////////////////////////////////////
  // encapsulate the keyspace chart
  var memoryWidget = (function() {
    var chart;

    function render(data) {
      chart = new Highcharts.Chart({
        chart: {
          renderTo: 'memory-container',
          defaultSeriesType: 'areaspline',
          zoomType: 'x'
        },
        title: {text: ''},
        xAxis: {
          type: 'datetime',
          title: {text: null}
        },
        yAxis: {title: null},
        legend: {enabled: false},
        credits: {enabled: false},
        plotOptions: {
          line: {
            shadow: false,
            lineWidth: 3
          },
          series: {
            marker: {
              radius: 0,
              fillColor: '#FFFFFF',
              lineWidth: 2,
              lineColor: null
            },
            fillColor: {
              linearGradient: [0, 0, 0, 300],
              stops: [
                [0, 'rgb(69, 114, 167)'],
                [1, 'rgba(2,0,0,0)']
              ]
            }
          }
        },
        series: [{data: points(data)}],
      });
    }

    function points(data) {
      return data.map(point);
    }

    function point(info) {
      return [
        parseInt(info.time),
        parseInt(info.used_memory)
      ];
    }

    function onData(ev, data) {
      if (data) {
        var series = chart.series[0];
        series.addPoint(point(data), true, series.data.length >= 25);
      }
    }

    // observe data events
    events.bind('data', onData);

    return {
      render: render
    }
  })();

  //////////////////////////////////////////////////////////////////////
  // encapsulate the keyspace chart
  var keyspaceWidget = (function(){
    var chart;

    function render(data) {
      var hits = []
        , misses = [];

      points(data).forEach(function(point) {
        hits.push(point[0]);
        misses.push(point[1]);
      });

      chart = new Highcharts.Chart({
        chart: {
          renderTo: 'keyspace-container',
          defaultSeriesType: 'line'
        },
        title: {text: ''},
        xAxis: {
          type: 'datetime',
          title: {text: null}
        },
        yAxis: {title: null},
        legend: {
          layout: 'horizontal',
          align: 'top',
          verticalAlign: 'top',
          x: -5,
          y: -3,
          margin: 25,
          borderWidth: 0
        },
        credits: {enabled: false},
        plotOptions: {
          line: {
            shadow: false,
            lineWidth: 3
          },
          series: {
            marker: {
              radius: 0,
              fillColor: '#FFFFFF',
              lineWidth: 2,
              lineColor: null
            }
          }
        },
        series: [{
          name: 'Hits',
          data: hits
        },{
          name: 'Misses',
          data: misses
        }]
      });
    }

    function points(data) {
      return data.map(point);
    }

    function point(info) {
      var time = parseInt(info.time);
      return [
        [time, parseInt(info.keyspace_hits)],
        [time, parseInt(info.keyspace_misses)]
      ];
    }

    function onData(ev, data) {
      if (data) {
        var newPoint = point(data);
        var hits = chart.series[0];
        hits.addPoint(newPoint[0], true, hits.data.length >= 25);

        var misses = chart.series[1];
        misses.addPoint(newPoint[1], true, misses.data.length >= 25);
      }
    }

    // observe data events
    events.bind('data', onData);

    return {
      render: render
    }
  })();

  //////////////////////////////////////////////////////////////////////
  // encapsulate the info widget
  var infoWidget = (function() {

    function render(data) {
      updateTable(data[data.length-1]);
    }

    function onData(ev, data) {
      if (data)
        updateTable(data);
    }

    function updateTable(data) {
      $('#info-tbl td[id]').each(function() {
        var el = $(this)
          , field = el.attr('id');

        if (data[field]) {
          var type = el.attr('type')
          if (type && type == 'date')
            el.text(formatDate(data[field]));
          else if (type && type == 'number')
            el.text(formatNumber(data[field]))
          else
            el.text(data[field]);
        }
      });
    }

    function formatNumber(num) {
      return (num + "").replace(/(\d)(?=(\d{3})+(\.\d+|)\b)/g, "$1,");
    }

    events.bind('data', onData);

    return {
      render: render
    }
  })();

  //////////////////////////////////////////////////////////////////////
  // encapsulate the slow log widget
  var slowlogWidget = (function() {

    function render(data) {
      updateTable(data[data.length-1]);
    }

    function onData(ev, data) {
      if (data)
        updateTable(data);
    }

    function updateTable(data) {
      $('#slow-tbl tr').remove();
      data.slowlog.forEach(function(entry) {
        $('#slow-tbl').append(
          $('<tr></tr>')
            .append(
              $('<td style="width: 65%; font-weight:bold;"></td>').html(entry.command)
            ).append(
              $('<td></td>').html((entry.process_time / 1000) + ' ms')
            ).append(
              $('<td></td>').html(formatDate(entry.timestamp))
            )
        );
      });
    }

    function formatNumber(num) {
      return (num + "").replace(/(\d)(?=(\d{3})+(\.\d+|)\b)/g, "$1,");
    }

    events.bind('data', onData);
  })();

  //////////////////////////////////////////////////////////////////////
  // encapsulate the config widget
  var configWidget = (function() {
    var selects = {
      'appendonly'                : 'yes,no',
      'no-appendfsync-on-rewrite' : 'yes,no',
      'slave-serve-stale-data'    : 'yes,no',
      'loglevel'                  : 'debug,verbose,notice,warning',
      'maxmemory-policy'          : 'volatile-lru,allkeys-lru,volatile-random,allkeys-random,volatile-ttl,noeviction',
      'appendfsync'               : 'always,everysec,no'
    };

    function render(data) {
      $('#config-table .editable').each(function() {
        var editable = $(this)
          , id = editable.attr('id');

        var config = {
          url           : '/products',
          element_id    : '0',
          update_value  : 'value',
          show_buttons  :  true,
          save_button   : '<button style="margin-left:5px;"class="btn primary">Save</button>',
          cancel_button : '<button class="btn">Cancel</button>',
          default_text  : '&nbsp'
        };

        if (selects[id]) {
          config.field_type     = 'select';
          config.select_options = selects[id];
        }

        editable.editInPlace(config);
      });
    }

    return {
      render: render
    }
  })();

  //////////////////////////////////////////////////////////////////////
  // terminal emulator
  var cli = (function() {
    var terminal;

    function init() {
      var prompt = [
        "<div class='line'>" +
          "<span class='prompt'>"+config.cliPrompt+"</span>" +
          "<input type='text' class='readLine active' />" +
        "</div>"
      ].join('');

      terminal = new ReadLine({
        htmlForInput : function() {return prompt},
        handler      : process
      });
    }

    function process(command, callback) {
      var cmd = command.split(' ')[0].toLowerCase();
      if (!cmds[cmd] === true) {
          callback("(error) ERR unknown command '"+cmd+"'");
          return;
      }

      $.ajax({
        url     : '/redis_infos/terminal?command='+command,
        success :  callback
      });
    }

    function focus() {
      terminal.focus();
    }

    var cmds = {
      'append'           : true,
      'auth'             : true,
      'bgrewriteaof'     : true,
      'bgsave'           : true,
      'blpop'            : true,
      'brpop'            : true,
      'brpoplpush'       : true,
      'config'           : true,
      'dbsize'           : true,
      'debug'            : true,
      'decr'             : true,
      'decrby'           : true,
      'del'              : true,
      'discard'          : true,
      'echo'             : true,
      'exec'             : true,
      'exists'           : true,
      'expire'           : true,
      'expireat'         : true,
      'flushall'         : true,
      'flushdb'          : true,
      'get'              : true,
      'getbit'           : true,
      'getrange'         : true,
      'getset'           : true,
      'hdel'             : true,
      'hexists'          : true,
      'hget'             : true,
      'hgetall'          : true,
      'hincrby'          : true,
      'hkeys'            : true,
      'hlen'             : true,
      'hmget'            : true,
      'hmset'            : true,
      'hset'             : true,
      'hsetnx'           : true,
      'hvals'            : true,
      'incr'             : true,
      'incrby'           : true,
      'info'             : true,
      'keys'             : true,
      'lastsave'         : true,
      'lindex'           : true,
      'linsert'          : true,
      'llen'             : true,
      'lpop'             : true,
      'lpush'            : true,
      'lpushx'           : true,
      'lrange'           : true,
      'lrem'             : true,
      'lset'             : true,
      'ltrim'            : true,
      'mget'             : true,
      'monitor'          : true,
      'move'             : true,
      'mset'             : true,
      'msetnx'           : true,
      'multi'            : true,
      'object'           : true,
      'persist'          : true,
      'publish'          : true,
      'ping'             : true,
      'quit'             : true,
      'randomkey'        : true,
      'rename'           : true,
      'renamenx'         : true,
      'rpop'             : true,
      'rpoplpush'        : true,
      'rpush'            : true,
      'rpushx'           : true,
      'sadd'             : true,
      'save'             : true,
      'scard'            : true,
      'sdiff'            : true,
      'sdiffstore'       : true,
      'select'           : true,
      'set'              : true,
      'setbit'           : true,
      'setex'            : true,
      'setnx'            : true,
      'setrange'         : true,
      'shutdown'         : true,
      'sinter'           : true,
      'sinterstore'      : true,
      'sismember'        : true,
      'slaveof'          : true,
      'smembers'         : true,
      'smove'            : true,
      'sort'             : true,
      'spop'             : true,
      'srandmember'      : true,
      'srem'             : true,
      'strlen'           : true,
      'sunion'           : true,
      'sunionstore'      : true,
      'sync'             : true,
      'ttl'              : true,
      'type'             : true,
      'watch'            : true,
      'zadd'             : true,
      'zcard'            : true,
      'zcount'           : true,
      'zincrby'          : true,
      'zinterstore'      : true,
      'zrange'           : true,
      'zrangebyscore'    : true,
      'zrank'            : true,
      'zrem'             : true,
      'zremrangebyrank'  : true,
      'zremrangebyscore' : true,
      'zrevrange'        : true,
      'zrevrangebyscore' : true,
      'zrevrank'         : true,
      'zscore'           : true,
      'zunionstore'      : true
    }

    return {
      focus : focus,
      init  : init
    }
  })();

  return  {
    init: init
  }
})();
