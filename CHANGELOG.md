## HEAD

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
