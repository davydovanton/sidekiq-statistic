$(function () {
  var Charts = {
    location: window.location.pathname,
    paths: {
      init: this.location + '/charts_initializer.json',
      realtime: this.location + '/charts.json'
    },
    options: function(columns) {
      return {
        data: {
          x: 'x',
          xFormat: '%H:%M:%S',
          columns: columns
        },
        axis: {
          x: {
            type: 'timeseries',
            tick: {
              count: 5,
              format: '%H:%M:%S'
            }
          }
        }
      }
    }
  }

  var failedChart
  var passedChart
  var interval
  var excludedWorkers = []

  function updateChart() {
    if ($('.worker__checkbox').length === $('.worker__checkbox:checked').length) {
      return
    }

    $.getJSON(Charts.paths.realtime, { excluded: excludedWorkers })
      .done(function (data) {
        failedChart.flow(data['failed'])
        passedChart.flow(data['passed'])
      })
  }

  function setIntervalChart() {
   interval =  setInterval(updateChart, 1000);
  }

  function stopRealtimeChart() {
    clearInterval(interval);
  }


  $('.realtime__toggle').click(function() {
    if(this.innerHTML === 'Stop'){
      stopRealtimeChart()
      this.innerHTML = 'Start'
      this.classList.add("active");
    } else if (this.innerHTML === 'Start') {
      setIntervalChart()
      this.innerHTML = 'Stop'
      this.classList.remove("active");
    }
  });

  $('.worker__checkbox').change(function() {
    var name = this.name

    failedChart.toggle(name)
    passedChart.toggle(name)

    if(this.checked) {
      excludedWorkers.push(this.name)
    } else {
      excludedWorkers.splice($.inArray(this.name, excludedWorkers), 1)
    }
  });

  $.getJSON(Charts.paths.init, function (response) {
    var options = Charts.options(response)
    failedChart = c3.generate($.extend(options, { bindto: '.realtime__failed-chart' }))
    passedChart = c3.generate($.extend(options, { bindto: '.realtime__passed-chart' }))
    setIntervalChart()
  })
})
