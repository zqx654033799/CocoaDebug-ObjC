
Pod::Spec.new do |s|
  s.name             = 'CocoaDebug'
  s.version          = '0.1.0'
  s.summary          = 'iOS Debug Tool ObjC.'

  s.homepage         = 'https://github.com/zqx654033799/CocoaDebug-ObjC'
  s.author           = { 'iPaperman' => 'zqx654033799@qq.com' }
  s.source           = { :git => 'https://github.com/zqx654033799/CocoaDebug-ObjC.git', :tag => s.version.to_s }
  s.license          = 'MIT'

  s.ios.deployment_target   = '9.0'

  s.subspec 'Classes' do |ss|
    ss.source_files         = 'CocoaDebug/Classes/**/*.{h,m,mm,c}'
    ss.public_header_files  = 'CocoaDebug/Classes/**/*.h'
    
    ss.requires_arc         = false
    ss.requires_arc         = [
                              'CocoaDebug/Classes/App/**/*.m',
                              'CocoaDebug/Classes/Categories/**/*.m',
                              'CocoaDebug/Classes/Core/**/*.m',
                              'CocoaDebug/Classes/CustomHTTPProtocol/**/*.m',
                              'CocoaDebug/Classes/LeaksFinder/**/*.m',
                              'CocoaDebug/Classes/Logs/**/*.m',
                              'CocoaDebug/Classes/Monitor/**/*.m',
                              'CocoaDebug/Classes/Network/**/*.m',
                              'CocoaDebug/Classes/Sandbox/**/*.m',
                              'CocoaDebug/Classes/Swizzling/**/*.m',
                              'CocoaDebug/Classes/Window/**/*.m',
                              'CocoaDebug/Classes/WeakTimer/**/*.m',
                              'CocoaDebug/Classes/UserDefaults/**/*.m',
                              'CocoaDebug/Classes/FBRetainCycleDetector/Filtering/*.mm',
                              'CocoaDebug/Classes/fishhook/**/*.c'
                              ]
    ss.frameworks           = 'UIKit', 'WebKit', 'CoreGraphics'
    ss.library              = 'c++'
    ss.prefix_header_file   = 'CocoaDebug/CocoaDebug_Prefix.pch'
  end
  s.resources               = 'CocoaDebug/Assets/**/*.png'
end
