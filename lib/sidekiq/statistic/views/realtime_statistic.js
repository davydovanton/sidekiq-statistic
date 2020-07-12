const BASEURL = window.location.pathname;

const Elements = {
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

const Data = {
  excludedWorkers: [],
  failedChart: [],
  passedChart: []
}

const visibilityStatusClasses = {
  true: 'fa-eye',
  false: 'fa-eye-slash',
}

function toggleWorkerVisibility() {
  const toggleWorkerButton = $(this)
  const { name } = this

  const visibilityIcon = toggleWorkerButton.find('.worker__visibility-icon')
  const currentStatus = toggleWorkerButton.data('visible')
  const newStatus = !currentStatus

  visibilityIcon.toggleClass(`${visibilityStatusClasses[currentStatus]} ${visibilityStatusClasses[newStatus]}`)

  toggleWorkerButton.data('visible', newStatus)

  Data.failedChart.toggle(name)
  Data.passedChart.toggle(name)

  if (this.checked) {
    Data.excludedWorkers.push(this.name)
  } else {
    Data.excludedWorkers.splice($.inArray(this.name, Data.excludedWorkers), 1)
  }
}

let interval

function noVisibleWorkers() {
  return $(Elements.toggleVisibilityButton)
    .get()
    .every(element => $(element).data('visible') === false)
}

function updateChart() {
  if (noVisibleWorkers()) {
    return
  }

  requestJSON(Charts.paths.realtime, { data: { excluded: Data.excludedWorkers } })
    .done(function (data) {
      Data.failedChart.flow(data['failed'])
      Data.passedChart.flow(data['passed'])
    })
}

const setIntervalChart = () => {
  interval = setInterval(updateChart, 1000);
}

const stopRealtimeChart = () => {
  clearInterval(interval);
}

function toggleRealTime() {
  const startButton = $('.start-button')
  const stopButton = $('.stop-button')

  if (startButton.is(":visible")) {
    setIntervalChart()
    startButton.hide()
    stopButton.show()
  } else if (stopButton.is(":visible")) {
    stopRealtimeChart()
    stopButton.hide()
    startButton.show()
  }
}

const Listeners = {
  toggleVisibilityButton: () => $(Elements.toggleVisibilityButton).click(toggleWorkerVisibility),
  realtimeToggleButton: () => $(Elements.realtimeToggleButton).click(toggleRealTime)
}

const setEventListeners = () => {
  Object.keys(Listeners).forEach(listener => {
    Listeners[listener]();
  })
}

const initializeCharts = () => {
  requestJSON(Charts.paths.init)
    .done(function (response) {
      const options = Charts.options(response);

      Data.failedChart = c3.generate($.extend(options, { bindto: '.realtime__failed-chart' }));
      Data.passedChart = c3.generate($.extend(options, { bindto: '.realtime__passed-chart' }));

      setIntervalChart()
    })
}

const initialize = () => {
  initializeCharts();
  setEventListeners();
}

$(initialize);
