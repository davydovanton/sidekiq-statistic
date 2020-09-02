## HEAD

- 02.09.2020: Improve dark mode workers table links readability(#160) _V-Gutierrez_
- 25.08.2020: Refactor realtime statistic JS code (#159) _kostadriano_
- 24.08.2020: Fix translation pt-Br start/stop (#153) _brunnohenrique_
- 01.07.2020: Update workers toggle visibility button on RealTime (#156) _kostadriano_
- 06.12.2019: Avoid whites when generating colors (#141) _Wender Freese_
- 25.11.2019: Add line break in log visualization _Dmitriy_
- 25.11.2019: Fix high memory usage in Log Parser _Dmitriy_
- 04.10.2019: Fix UI problem when the number of workers increases too much (#140) _Guilherme Quirino_

## 1.4.0

- 13.09.2019: Replace `chart.js` to `c3.js` (#139) _Guilherme Quirino_
- 17.08.2019: Improve Date translations (#136) _Guilherme Quirino_
- 05.08.2019: Add translation to FR (#135) _Wender Freese_
- 02.08.2019: Add translation to JP (#133) _Emerson Araki_
- 30.06.2019: Fix UI problem in realtime graphics when hided/showed (#130) _Wender Freese_
- 28.06.2019: Fix UI problem in busy workers counter (#129) _Guilherme Quirino_
- 24.06.2019: Update `chart.js` to V2 (#128) _Guilherme Quirino_
- 11.05.2019: Add translations to PT-BR (#126) _Guilherme Quirino_
- 08.03.2019: Change LogParser regexp (#81) _Kirill Tatchihin_
- 03.02.2019: Change storing of last*runtime from date to timestamp (#87) \_Kirill Tatchihin*
- 30.03.2017: Prevent excessive Redis memory usage (#107) _Gareth du Plooy_
- 08.04.2016: Add new option for displaying last N lines of log file (#91) _Nick Zhebrun_
- 20.11.2015: Convert value in redis time array to float (#76) _Anton Davydov_
- 20.11.2015: Add Ukrainian Localization (#85) _@POStroi_

## v1.2

- 15.11.2015: Update gemspec to allow usage with sidekiq 4 (#83) _Felix Bünemann_
- 21.10.2015: Fix charts initialize and Uncaught TypeError (#70, #79) _Anton Davydov_
- 17.10.2015: Fix worker's per day stats (#78) _Alexander Yunin_
- 28.09.2015: Use strftime to ensure date string format (#77) _@stan_
- 02.09.2015: Sort worker names in GUI (#69) _Anton Davydov_

## v1.1

- 29.08.2015: Create custom tooltip for charts on index page (fix #63) _Anton Davydov_
- 26.08.2015: Add queue to workers table in index page _Anton Davydov_
- 25.08.2015: Italian localization _Fabio Napoleoni_
- 25.08.2015: Fix worker naming for AJ mailers (fix #59) _Anton Davydov_
- 21.08.2015: Use dynamic path generation for json requests (fix #56) _Anton Davydov_
- 21.08.2015: Add button in log page for display only special job (#40) _Anton Davydov_
- 20.08.2015: Add German Localization (#54) _Felix Bünemann_
- 20.08.2015: Fix statistics display for nested worker classes (#48) _Felix Bünemann_

## v1.0

- 19.08.2015: Middleware refactoring (#45) _Mike Perham_
- 19.08.2015: Use redis lists for save all job runtimes _Anton Davydov_
- 12.08.2015: Add filters (by worker) for realtime charts _Anton Davydov_
- 11.08.2015: Realtime chart for each worker and job _Anton Davydov_
- 31.07.2015: Add JSON API _Anton Davydov_
- 29.07.2015: Add localizations for plugin _Anton Davydov_
- 28.07.2015: Read first 1*000 lines from changelog \_Anton Davydov*
- 28.07.2015: Rename plugin to sidekiq-statistic _Anton Davydov_
- 23.07.2015: Use native redis hash instead json serialization _Anton Davydov_
- 15.07.2015: Improve integration with active job _Anton Davydov_
- 01.07.2015: New realisation for thread safe history middleware _Anton Davydov_
- 13.05.2015: Add ability to change any date range on any history page _Anton Davydov_
- 12.05.2015: Add last job status data parameter for each worker _Anton Davydov_
- 11.05.2015: Add page woth worker data table for each day _Anton Davydov_
- 28.04.2015: Formating worker date in web UI _Anton Davydov_
- 27.04.2015: Set specific color for any worker _Anton Davydov_
- 10.04.2015: Add search field on worker page _Anton Davydov_
- 04.04.2015: Fix livereload button in index page _Anton Davydov_
- 23.03.2015: Add max runtime column to worker web table _Anton Davydov_
- 19.03.2015: Add functionality for adding custom css and js files to web page _Anton Davydov_
- 18.03.2015: Add configuration class with log*file options \_Anton Davydov*
- 16.03.2015: Add worker page where user can see log for this worker _Anton Davydov_
- 15.03.2015: Add worker statistic table to index history page _Anton Davydov_
- 08.03.2015: Add charts for each passed and failed jobs for each worker. _Anton Davydov_
- 08.03.2015: Add Statistic class which provide statistics for each day and each worker. _Anton Davydov_
- 08.03.2015: Save in redis json with failed and passed jobs for each worker. _Anton Davydov_
- 04.03.2015: Created simple midelware and static page. _Anton Davydov_
