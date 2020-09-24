platform :ios, '9.0'

def common_pods
  pod 'FullStory', :http => 'https://ios-releases.fullstory.com/fullstory-1.7.0.tar.gz'
  pod 'Analytics', '~> 3.0'
end

target 'FullStoryMiddleware' do
  common_pods
end
  

target 'FullStoryMiddlewareTests' do
  common_pods
  pod 'OCMock', '~>3.6'
end

target 'FullStoryMiddlewareExample' do
  common_pods
  pod 'FullStorySegmentMiddleware', :path => '.'
end
  

