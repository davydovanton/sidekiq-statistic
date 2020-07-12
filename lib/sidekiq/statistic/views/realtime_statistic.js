const BASEURL = window.location.pathname;

const ELEMENTS = {
  toggleVisibilityButton: '.worker__toggle-visibility',
  realtimeToggleButton: '.realtime__toggle'
}

const requestJSON = (url, config) =>
  $.ajax(
    `${BASEURL}/${url}`,
    {
      dataType: "json",
      ...config
    }
  );

const Charts = {
  paths: {
    init: 'charts_initializer.json',
    realtime: 'charts.json'
  },
  options: (columns) => ({
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
  })
}

$(function () {
  var failedChart
  var passedChart
  var interval
  var excludedWorkers = []

  function noVisibleWorkers() {
    return $(ELEMENTS.toggleVisibilityButton)
      .get()
      .every(element => $(element).data('visible') === false)
  }

  function updateChart() {
    if (noVisibleWorkers()) {
      return
    }

    requestJSON(Charts.paths.realtime, { data: { excluded: excludedWorkers } })
      .done(function (data) {
        failedChart.flow(data['failed'])
        passedChart.flow(data['passed'])
      })
  }

  function setIntervalChart() {
    interval = setInterval(updateChart, 1000);
  }

  function stopRealtimeChart() {
    clearInterval(interval);
  }

  $(ELEMENTS.realtimeToggleButton).click(function () {
    var startButton = $('.start-button')
    var stopButton = $('.stop-button')

    if (startButton.is(":visible")) {
      setIntervalChart()
      startButton.hide()
      stopButton.show()
    } else if (stopButton.is(":visible")) {
      stopRealtimeChart()
      stopButton.hide()
      startButton.show()
    }
  });

  var visibilityStatusClass = {
    true: 'fa-eye',
    false: 'fa-eye-slash',
  }

  $(ELEMENTS.toggleVisibilityButton).click(function () {
    var name = this.name
    var visibilityIcon = $(this).find('.worker__visibility-icon')
    var currentStatus = $(this).data('visible')
    var newStatus = !currentStatus

    visibilityIcon.toggleClass(`${visibilityStatusClass[currentStatus]} ${visibilityStatusClass[newStatus]}`)

    $(this).data('visible', newStatus)

    failedChart.toggle(name)
    passedChart.toggle(name)

    if (this.checked) {
      excludedWorkers.push(this.name)
    } else {
      excludedWorkers.splice($.inArray(this.name, excludedWorkers), 1)
    }
  });

  requestJSON(Charts.paths.init)
    .done(function (response) {
      var options = Charts.options(response)
      failedChart = c3.generate($.extend(options, { bindto: '.realtime__failed-chart' }))
      passedChart = c3.generate($.extend(options, { bindto: '.realtime__passed-chart' }))
      setIntervalChart()
    })
})
