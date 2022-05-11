#!/usr/bin/env ruby

require 'rubygems'
require 'aws-sdk-s3'

local_file = ARGV[0]
mime_type  = ARGV[1] || "application/octet-stream"

ACCESS_KEY_ID     = ENV.fetch('AWS_KEY')
SECRET_ACCESS_KEY = ENV.fetch('AWS_SECRET')
BUCKET            = ENV.fetch('AWS_BUCKET')
REGION            = ENV.fetch('AWS_REGION', 'us-east-1')

s3 = Aws::S3::Resource.new(region: REGION,
                           access_key_id:     ACCESS_KEY_ID,
                           secret_access_key: SECRET_ACCESS_KEY)

my_bucket = s3.bucket(BUCKET)

name = File.basename local_file
obj = my_bucket.object(name)

print "\nUploading #{local_file} as '#{name}' to '#{BUCKET}'..."
obj.upload_file(local_file)
puts " Done!"

puts "Shows all files in '#{BUCKET}'"
my_bucket.objects.limit(50).each do |obj|
  puts "  #{obj.key} => #{obj.etag}"
end

# * Create Bucket with Block all public access
# * Create IAM user to access the bucket
# * Create Policy for Programmatic Access:
#     - https://aws.amazon.com/blogs/security/writing-iam-policies-how-to-grant-access-to-an-amazon-s3-bucket/
#     - https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_examples_s3_rw-bucket.html
#     - {
#         "Version": "2012-10-17",
#         "Statement": [
#           {
#             "Effect": "Allow",
#             "Action": [
#               "s3:ListBucket"
#             ],
#             "Resource": [
#               "arn:aws:s3:::<bucket-name>"
#             ]
#           },
#           {
#             "Effect": "Allow",
#             "Action": [
#               "s3:PutObject",
#               "s3:GetObject",
#               "s3:DeleteObject"
#             ],
#             "Resource": [
#               "arn:aws:s3:::<bucket-name>/*"
#             ]
#           }
#         ]
#       }
# * Add the Policy to the IAM user.
# * Allow CORS requests to ActiveText: https://mikerogers.io/2018/11/03/configuring-cors-on-s3-for-activestorage
# <?xml version="1.0" encoding="UTF-8"?>
# <CORSConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
# <CORSRule>
#     <AllowedOrigin>*</AllowedOrigin>
#     <AllowedMethod>GET</AllowedMethod>
#     <MaxAgeSeconds>3000</MaxAgeSeconds>
#     <AllowedHeader>Authorization</AllowedHeader>
# </CORSRule>
# <CORSRule>
#     <AllowedOrigin>*</AllowedOrigin>
#     <AllowedMethod>PUT</AllowedMethod>
#     <AllowedMethod>POST</AllowedMethod>
#     <MaxAgeSeconds>3000</MaxAgeSeconds>
#     <AllowedHeader>*</AllowedHeader>
# </CORSRule>
# </CORSConfiguration>
#
# JSON Version:
#[
#     {
#         "AllowedHeaders": [
#             "Authorization"
#         ],
#         "AllowedMethods": [
#             "GET"
#         ],
#         "AllowedOrigins": [
#             "*"
#         ],
#         "ExposeHeaders": [],
#         "MaxAgeSeconds": 3000
#     },
#     {
#         "AllowedHeaders": [
#             "*"
#         ],
#         "AllowedMethods": [
#             "PUT",
#             "POST"
#         ],
#         "AllowedOrigins": [
#             "*"
#         ],
#         "ExposeHeaders": [],
#         "MaxAgeSeconds": 3000
#     }
# ]
