Pod::Spec.new do |s|

  s.name          = "EasyListView"
  s.version       = "1.3.0"
  s.summary       = "快速搭建静态及可重用列表"
  s.homepage      = "https://github.com/moliya/EasyListView"
  s.license       = "MIT"
  s.author        = {'Carefree' => '946715806@qq.com'}
  s.source        = { :git => "https://github.com/moliya/EasyListView.git", :tag => s.version}
  s.requires_arc  = true
  s.platform      = :ios, '9.0'
  s.swift_version = '5.0'
  s.dependency 'EasyCompatible'
  s.source_files = "Sources/**/*"
end
