#
#  Be sure to run `pod spec lint MOFSPickerManager.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "MOFSPickerManager"
  s.version      = "2.1.4"
  s.summary      = "PickerManager for iOS"

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description  = <<-DESC
    iOS PickerView整合，一行代码调用（省市区三级联动+日期选择+普通选择）
                   DESC

  s.homepage     = "https://github.com/memoriesofsnows/MOFSPickerManagerDemo.git"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Licensing your code is important. See http://choosealicense.com for more info.
  #  CocoaPods will detect a license file if there is a named LICENSE*
  #  Popular ones are 'MIT', 'BSD' and 'Apache License, Version 2.0'.
  #

  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "LICENSE" }


  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the authors of the library, with email addresses. Email addresses
  #  of the authors are extracted from the SCM log. E.g. $ git log. CocoaPods also
  #  accepts just a name if you'd rather not provide an email address.
  #
  #  Specify a social_media_url where others can refer to, for example a twitter
  #  profile URL.
  #

  s.author             = { "memoriesofsnows" => "luoyuant@163.com" }
  # Or just: s.author    = "memoriesofsnows"
  # s.authors            = { "memoriesofsnows" => "" }
  s.social_media_url   = "http://www.jianshu.com/u/f4284f2cc646"

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If this Pod runs only on iOS or OS X, then specify the platform and
  #  the deployment target. You can optionally include the target after the platform.
  #

  # s.platform     = :ios
  s.platform     = :ios, "7.0"

  #  When using multiple platforms
  # s.ios.deployment_target = "7.0"
  # s.osx.deployment_target = "10.7"
  # s.watchos.deployment_target = "2.0"
  # s.tvos.deployment_target = "9.0"


  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the location from where the source should be retrieved.
  #  Supports git, hg, bzr, svn and HTTP.
  #

  s.source       = { :git => "https://github.com/memoriesofsnows/MOFSPickerManagerDemo.git", :tag => "#{s.version}" }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  CocoaPods is smart about how it includes source code. For source files
  #  giving a folder will include any swift, h, m, mm, c & cpp files.
  #  For header files it will include any header in the folder.
  #  Not including the public_header_files will make all headers public.
  #

  #-------------------------------1.0.7版本去掉 2018-02-05-----------------------
  # s.source_files  = "MOFSPickerManagerDemo/MOFSPickerManager/**/*.{h,m}", "MOFSPickerManagerDemo/GDataXMLNode/**/*.{h,m}"
  #-----------------------------------------------------------------------------
  s.source_files  = "MOFSPickerManagerDemo/MOFSPickerManager/**/*.{h,m}"
  s.exclude_files = "Classes/Exclude"

  # s.public_header_files = "Classes/**/*.h"


  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  A list of resources included with the Pod. These are copied into the
  #  target bundle with a build phase script. Anything else will be cleaned.
  #  You can preserve files from being cleaned, please don't preserve
  #  non-essential files like tests, examples and documentation.
  #

  # s.resource  = "icon.png"
  # s.resources = "Resources/*.png"
  s.resources = "MOFSPickerManagerDemo/MOFSPickerManager/**/*.{xml}"

  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"


  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Link your library with frameworks, or libraries. Libraries do not include
  #  the lib prefix of their name.
  #

  # s.framework  = "SomeFramework"
  # s.frameworks = "SomeFramework", "AnotherFramework"

  #s.library   = "xml2.2.tbd"

  #-------------------------------1.0.7版本去掉 2018-02-05-----------------------
  # s.libraries = "xml2"
  #-----------------------------------------------------------------------------

  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  #-------------------------------1.0.7版本去掉 2018-02-05-----------------------
  # s.requires_arc = false
  # s.requires_arc = ["MOFSPickerManagerDemo/MOFSPickerManager/**/*.{h,m}"]
  # s.module_name = "MOFSPickerManager"
  #-----------------------------------------------------------------------------

  # non_arc_files = 'MOFSPickerManagerDemo/GDataXMLNode/**/*.{h,m}'

  # s.exclude_files = non_arc_files

  # s.subspec 'no-arc' do |sp|

  # sp.source_files = non_arc_files

  # sp.requires_arc = false

  # end
  # s.requires_arc = ['MOFSPickerManagerDemo/MOFSPickerManager/**/*.{h,m}']

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }

  #-------------------------------1.0.7版本去掉 2018-02-05-----------------------
  #s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2", "OTHER_LINKER_FLAGS" => "-ObjC", "WEAK_REFERENCES_IN_MANUAL_RETAIN_RELEASE" => "Yes" }
  #-----------------------------------------------------------------------------

  # s.dependency "GDataXML"
  # "ALLOW_NON-MODULAR_INCLUDES_IN_FRAMEWORK_MODULES" => "YES"

end
