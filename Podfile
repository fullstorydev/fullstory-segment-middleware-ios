platform :ios, '11.0'

def common_pods
  pod 'FullStory', :http => 'https://ios-releases.fullstory.com/fullstory-1.18.0.tar.gz'
  pod 'Analytics', '~> 4.1'
end

target 'FullStoryMiddleware' do
  common_pods
end

target 'FullStoryMiddlewareTests' do
  common_pods
  pod 'OCMock', '~> 3.6'
end

target 'FullStoryMiddlewareExample' do
  common_pods
  pod 'FullStorySegmentMiddleware', :path => '.'
end
