# Lambda@Edge for increasing SSL and Headers security for CloudFront distributions

## RESTRICTIONS

<https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/edge-functions-restrictions.html#lambda-at-edge-restrictions-region>

1. You must use a numbered version of the Lambda function, not $LATEST or aliases.
2. The Lambda function must be in the US East (N. Virginia) Region.
3. The IAM execution role associated with the Lambda function must allow the service principals lambda.amazonaws.com and edgelambda.amazonaws.com
4. Supports up to Node.js 14 or Python 3.8
5. Lambda@Edge functions can read, edit, remove, or add any of the following CloudFront headers:

   - CloudFront-Forwarded-Proto
   - CloudFront-Is-Desktop-Viewer
   - CloudFront-Is-Mobile-Viewer
   - CloudFront-Is-SmartTV-Viewer
   - CloudFront-Is-Tablet-Viewer
   - CloudFront-Viewer-Country¹

   Note the following:

   - If you want CloudFront to add these headers, you must configure CloudFront to add them using a cache policy or origin request policy.
   - CloudFront adds the headers after the viewer request event, which means they are not available to Lambda@Edge in a viewer request function.
   - If the viewer request includes headers that have these names, and you configured CloudFront to add these headers using a cache policy or origin request policy, then CloudFront overwrites the header values that were in the viewer request. Viewer-facing functions see the header value from the viewer request, while origin-facing functions see the header value that CloudFront added.
   - ¹CloudFront-Viewer-Country header – If a viewer request function adds this header, it fails validation and CloudFront returns HTTP status code 502 (Bad Gateway) to the viewer.

,,, and more ...

## OUTPUTS

lambda_arn = "arn:aws:lambda:us-east-1:458838185766:function:HSTS_Headers"
lambda_id = "HSTS_Headers"
lambda_invoke_arn = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:458838185766:function:HSTS_Headers/invocations"
lambda_version = "1"
lambda_version_for_cloud_front_functions = "arn:aws:lambda:us-east-1:458838185766:function:HSTS_Headers:1"
