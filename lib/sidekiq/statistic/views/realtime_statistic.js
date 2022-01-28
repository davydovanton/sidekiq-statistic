const BASEURL = window.location.pathname;

const requestJSON = (url, config) =>
  fetch(
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

const Elements = {
  toggleVisibilityButton: '.worker__toggle-visibility',
  realtimeToggleButton: '.realtime__toggle-button'
}

const Listeners = {
  toggleVisibilityButton: function() {
    document.querySelector(Elements.toggleVisibilityButton).addEventListener('click', toggleWorkerVisibility)
  },
  realtimeToggleButton: function() {
    document.querySelector(Elements.realtimeToggleButton).addEventListener('click', toggleRealTime)
  },
}

class ChartsUpdateService {
  intervalId = null

  static start(interval = 1000) {
    this.intervalId = setInterval(updateCharts, interval)
  }

  static stop() {
    clearInterval(this.intervalId)
  }
}

const initialize = () => {
  initializeCharts();
  setEventListeners();
}

const initializeCharts = () => {
  requestJSON(Charts.paths.init)
    .then(response => response.json())
    .then(function (response) {
      const options = Charts.options(response);

      Data.failedChart = c3.generate({ ...options, ...{ bindto: '.realtime__failed-chart' } });
      Data.passedChart = c3.generate({ ...options, ...{ bindto: '.realtime__passed-chart' } });

      ChartsUpdateService.start()
    })
}

const setEventListeners = () => {
  Object.keys(Listeners).forEach(listener => {
    Listeners[listener]();
  })
}

function toggleWorkerVisibility(event) {
  const toggleWorkerButton = event.target
  const { name } = this

  const currentStatus = toggleWorkerButton.dataset.visible;
  const visible = !currentStatus;
  const visibilityIcon = toggleWorkerButton.querySelector('.worker__visibility-icon');
  if(visibilityIcon) {
    visibilityIcon.classList.toggle(visibilityStatusClasses[currentStatus]);
    visibilityIcon.classList.toggle(visibilityStatusClasses[visible]);
  }
  toggleWorkerButton.dataset.visible = visible;

  Data.failedChart.toggle(name)
  Data.passedChart.toggle(name)

  if (!visible) {
    Data.excludedWorkers.push(this.name)
  } else {
    Data.excludedWorkers.splice(Data.excludedWorkers.indexOf(this.name), 1)
  }
}

function toggleRealTime(event) {
  const toggleRealtimeButton = event.target;
  const { start, stop, started } = toggleRealtimeButton.data();

  const buttonText = {
    true: stop,
    false: start
  }

  const toggleButton = value => {
    toggleRealtimeButton.text(buttonText[value])
    toggleRealtimeButton.dataset.started = value
  }

  if (started) {
    ChartsUpdateService.stop()
  }
  else {
    ChartsUpdateService.start()
  }

  toggleButton(!started)
}

const visibilityStatusClasses = {
  true: 'fa-eye',
  false: 'fa-eye-slash',
}

const noVisibleWorkers = () =>
  Array
    .from(document.querySelectorAll(Elements.toggleVisibilityButton))
    .every(element => element.dataset.visible === false)

const updateCharts = () => {
  if (noVisibleWorkers()) {
    return
  }

  requestJSON(Charts.paths.realtime, { data: { excluded: Data.excludedWorkers } })
    .then(response => response.json())
    .then(function (data) {
      Data.failedChart.flow(data['failed'])
      Data.passedChart.flow(data['passed'])
    })
}

const docReady = (callback) => {
  if (document.readyState !== "loading") callback();
  else document.addEventListener("DOMContentLoaded", callback);
}

docReady(() => initialize());
