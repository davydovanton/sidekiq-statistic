const BASEURL = window.location.pathname;

const Elements = {
  toggleVisibilityButton: '.worker__toggle-visibility',
  realtimeToggleButton: '.realtime__toggle-button'
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
  const visible = !currentStatus

  visibilityIcon.toggleClass(`${visibilityStatusClasses[currentStatus]} ${visibilityStatusClasses[visible]}`)

  toggleWorkerButton.data('visible', visible)

  Data.failedChart.toggle(name)
  Data.passedChart.toggle(name)

  if (!visible) {
    Data.excludedWorkers.push(this.name)
  } else {
    Data.excludedWorkers.splice($.inArray(this.name, Data.excludedWorkers), 1)
  }
}

class ChartsUpdateService {
  intervalId = null

  static start(interval = 1000) {
    this.intervalId = setInterval(updateChart, interval)
  }

  static stop() {
    clearInterval(this.intervalId)
  }
}

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

function toggleRealTime() {
  const toggleRealtimeButton = $(this)

  const { start, stop, started } = toggleRealtimeButton.data();

  const buttonText = {
    true: stop,
    false: start
  }

  const toggleButton = value => {
    toggleRealtimeButton.text(buttonText[value])
    toggleRealtimeButton.data('started', value)
  }

  if (started) {
    ChartsUpdateService.stop()
  }
  else {
    ChartsUpdateService.start()
  }

  toggleButton(!started)
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

      ChartsUpdateService.start()
    })
}

const initialize = () => {
  initializeCharts();
  setEventListeners();
}

$(initialize);
