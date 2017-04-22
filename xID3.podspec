Pod::Spec.new do |s|
  s.name = 'xID3'
  s.version = '0.1.0'
  s.license = { :type => 'Apache License 2.0', :file => 'LICENSE' }
  s.summary = 'A short description of xID3.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/te-th/xID3'
  s.authors = { 'PROJECT_OWNER' => 'USER_EMAIL' }
  s.source = { :git => 'https://github.com/te-th/xID3.git', :tag => s.version }
  s.ios.deployment_target = '8.0'
  s.source_files = 'Source/*.swift'
  s.resource_bundles = {
    'xID3' => ['Resources/**/*.{png}']
  }
end
