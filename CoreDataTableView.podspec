Pod::Spec.new do |s|
  s.name         = "CoreDataTableView"
  s.version      = "0.0.1"
  s.summary      = "Eliminates boilerplate code involved with an NSFetchedResultsController and a UITableView."

  s.homepage     = "https://github.com/kevinrandrup/CoreDataTableView"
  s.license      = { :type => "MIT", :file => 'LICENSE' }
  s.author       = { "Kevin Randrup" => "kevinrandrup@gmail.com" }
  s.social_media_url = "https://twitter.com/kevinrandrup"
  s.platform     = :ios, '5.0'

  s.source       = { :git => "https://github.com/kevinrandrup/CoreDataTableView.git", :commit => "6455448e076cbb25ef38c0f1c7cab66cf1bff44e" }

  s.source_files  = 'Classes/CoreDataTableView.{h,m}'
  s.frameworks   = "UIKit", "CoreData"
  s.requires_arc = true

end