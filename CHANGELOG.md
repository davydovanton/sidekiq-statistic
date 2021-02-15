## HEAD

## v1.6.0
* 11.02.2021: Add a new endpoint (/sidekiq/api/statistic_by_last_job_status.json) *Rhian Moraes*
* 11.02.2021: /sidekiq/statistic: add two checkboxes to show/hide workers based on their last job status (#113) *Rhian Moraes*

## v1.5.1

* 06.02.2021: Generate new TAG to fix "version.rb" not updated in the previous one (#170) *Wender Freese*
* 02.02.2021: Fix tests (#167) *Kirill Tatchihin*
* 17.01.2021: Refactor middleware to break responsibilities (#165) *Wender Freese*

## v1.5.0

* 16.01.2021: Fully support dark mode (#164) *Wender Freese*
* 02.09.2020: Improve dark mode workers table links readability (#160) *V-Gutierrez*
* 25.08.2020: Refactor realtime statistic JS code (#159) *kostadriano*
* 24.08.2020: Fix translation pt-Br start/stop (#153) *brunnohenrique*
* 01.07.2020: Update workers toggle visibility button on RealTime (#156) *kostadriano*
* 06.12.2019: Avoid whites when generating colors (#141) *Wender Freese*
* 25.11.2019: Add line break in log visualization *Dmitriy*
* 25.11.2019: Fix high memory usage in Log Parser *Dmitriy*
* 04.10.2019: Fix UI problem when the number of workers increases too much (#140) *Guilherme Quirino*

## v1.4.0

* 13.09.2019: Replace `chart.js` to `c3.js` (#139) *Guilherme Quirino*
* 17.08.2019: Improve Date translations (#136) *Guilherme Quirino*
* 05.08.2019: Add translation to FR (#135) *Wender Freese*
* 02.08.2019: Add translation to JP (#133) *Emerson Araki*
* 30.06.2019: Fix UI problem in realtime graphics when hided/showed (#130) *Wender Freese*
* 28.06.2019: Fix UI problem in busy workers counter (#129) *Guilherme Quirino*
* 24.06.2019: Update `chart.js` to V2 (#128) *Guilherme Quirino*
* 11.05.2019: Add translations to PT-BR (#126) *Guilherme Quirino*
* 08.03.2019: Change LogParser regexp (#81) *Kirill Tatchihin*
* 03.02.2019: Change storing of last_runtime from date to timestamp (#87) *Kirill Tatchihin*
* 30.03.2017: Prevent excessive Redis memory usage (#107) *Gareth du Plooy*
* 08.04.2016: Add new option for displaying last N lines of log file (#91) *Nick Zhebrun*
* 20.11.2015: Convert value in redis time array to float (#76) *Anton Davydov*
* 20.11.2015: Add Ukrainian Localization (#85) *@POStroi*

## v1.2
* 15.11.2015: Update gemspec to allow usage with sidekiq 4 (#83) *Felix Bünemann*
* 21.10.2015: Fix charts initialize and Uncaught TypeError (#70, #79) *Anton Davydov*
* 17.10.2015: Fix worker's per day stats (#78) *Alexander Yunin*
* 28.09.2015: Use strftime to ensure date string format (#77) *@stan*
* 02.09.2015: Sort worker names in GUI (#69) *Anton Davydov*

## v1.1
* 29.08.2015: Create custom tooltip for charts on index page (fix #63) *Anton Davydov*
* 26.08.2015: Add queue to workers table in index page *Anton Davydov*
* 25.08.2015: Italian localization *Fabio Napoleoni*
* 25.08.2015: Fix worker naming for AJ mailers (fix #59) *Anton Davydov*
* 21.08.2015: Use dynamic path generation for json requests (fix #56) *Anton Davydov*
* 21.08.2015: Add button in log page for display only special job (#40) *Anton Davydov*
* 20.08.2015: Add German Localization (#54) *Felix Bünemann*
* 20.08.2015: Fix statistics display for nested worker classes (#48) *Felix Bünemann*

## v1.0
* 19.08.2015: Middleware refactoring (#45) *Mike Perham*
* 19.08.2015: Use redis lists for save all job runtimes *Anton Davydov*
* 12.08.2015: Add filters (by worker) for realtime charts *Anton Davydov*
* 11.08.2015: Realtime chart for each worker and job *Anton Davydov*
* 31.07.2015: Add JSON API *Anton Davydov*
* 29.07.2015: Add localizations for plugin *Anton Davydov*
* 28.07.2015: Read first 1_000 lines from changelog *Anton Davydov*
* 28.07.2015: Rename plugin to sidekiq-statistic *Anton Davydov*
* 23.07.2015: Use native redis hash instead json serialization *Anton Davydov*
* 15.07.2015: Improve integration with active job *Anton Davydov*
* 01.07.2015: New realisation for thread safe history middleware *Anton Davydov*
* 13.05.2015: Add ability to change any date range on any history page *Anton Davydov*
* 12.05.2015: Add last job status data parameter for each worker *Anton Davydov*
* 11.05.2015: Add page woth worker data table for each day *Anton Davydov*
* 28.04.2015: Formating worker date in web UI *Anton Davydov*
* 27.04.2015: Set specific color for any worker *Anton Davydov*
* 10.04.2015: Add search field on worker page *Anton Davydov*
* 04.04.2015: Fix livereload button in index page *Anton Davydov*
* 23.03.2015: Add max runtime column to worker web table *Anton Davydov*
* 19.03.2015: Add functionality for adding custom css and js files to web page *Anton Davydov*
* 18.03.2015: Add configuration class with log_file options *Anton Davydov*
* 16.03.2015: Add worker page where user can see log for this worker *Anton Davydov*
* 15.03.2015: Add worker statistic table to index history page *Anton Davydov*
* 08.03.2015: Add charts for each passed and failed jobs for each worker. *Anton Davydov*
* 08.03.2015: Add Statistic class which provide statistics for each day and each worker. *Anton Davydov*
* 08.03.2015: Save in redis json with failed and passed jobs for each worker. *Anton Davydov*
* 04.03.2015: Created simple midelware and static page. *Anton Davydov*
