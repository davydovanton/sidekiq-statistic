* 27.04.2015: Set specific color for any worker

  *Anton Davydov*
* 10.04.2015: Add search field on worker page

  *Anton Davydov*
* 04.04.2015: Fix livereload button in index page

  *Anton Davydov*
* 23.03.2015: Add max runtime column to worker web table

  *Anton Davydov*
* 19.03.2015: Add functionality for adding custom css and js files to web page

  *Anton Davydov*
* 18.03.2015: Add configuration class with log_file options

  *Anton Davydov*
* 16.03.2015: Add worker page where user can see log for this worker

  *Anton Davydov*
* 15.03.2015: Add worker statistic table to index history page

  *Anton Davydov*
* 08.03.2015: Add charts for each passed and failed jobs for each worker.

  *Anton Davydov*
* 08.03.2015: Add Statistic class which provide statistics
              for each day and each worker.

  Sidekiq::History::Statistic.new(0).workers_hash
  # =>[{"2015-03-07"=>{"HistoryWorker"=>{:failed=>1, :passed=>1}}}]

  *Anton Davydov*
* 08.03.2015: Save in redis json with failed and passed jobs for each worker.

  *Anton Davydov*
* 04.03.2015: Created simple midelware and static page.

  *Anton Davydov*
