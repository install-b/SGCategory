
Pod::Spec.new do |s|

  s.name         = "SGCategory"
  s.version      = "1.0.2"
  s.summary      = "common category"

  s.description  = "common category for Foundation and UIKit classes"

  s.homepage     = "https://github.com/install-b/SGCategory"

  s.license      = "MIT"

  s.author       = { "ShangenZhang" => "645256685@qq.com" }

  s.platform     = :ios, "8.0"

  s.source       = { :git => "https://github.com/install-b/SGCategory.git", :tag => s.version }
  s.requires_arc = true

  s.source_files = 'Classes/*.h'
  s.public_header_files = "Classes/*.h"

  #s.default_subspec = 'SGUIKitCategory'

  s.subspec 'SGFoundationCateory' do |f|

    f.framework = "Foundation"
    f.source_files = 'Classes/Foundation/**/*.{h,m}'
    f.public_header_files = 'Classes/Foundation/**/*.h'

  end

  s.subspec 'SGUIKitCategory' do |u|

    u.framework = "UIKit"
    u.source_files = 'Classes/UIKit/**/*.{h,m}'
    u.public_header_files = 'Classes/UIKit/**/*.h'
   
  end

end
