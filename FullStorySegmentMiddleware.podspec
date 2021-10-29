Pod::Spec.new do |spec|
  spec.name         = 'FullStorySegmentMiddleware'
  spec.version      = '1.2.1'
  spec.summary      = 'Demonstrates the full potential of joining forces between Segment and FullStory.'
  spec.homepage     = 'https://github.com/fullstorydev/fullstory-segment-middleware-ios'
  spec.license      = { type: 'MIT', file: 'LICENSE' }
  spec.author       = { 'FullStory' => 'https://www.fullstory.com' }
  spec.source       = { git: 'https://github.com/fullstorydev/fullstory-segment-middleware-ios.git', tag: spec.version.to_s }
  
  spec.ios.deployment_target = '12.0'
  
  spec.source_files = 'FullStoryMiddleware'
  
  spec.dependency 'FullStory'
  spec.dependency 'Analytics'
end