using Amazon;
using Amazon.Runtime;
using Amazon.S3;
using Amazon.S3.Model;
using Amazon.S3.Util;

var endpoint = "http://192.168.1.114:9000"; // Update with your MinIO server address
var accessKey = Environment.GetEnvironmentVariable("MINIO_ROOT_USER") ?? "admin";
var secretKey = Environment.GetEnvironmentVariable("MINIO_ROOT_PASSWORD") ?? "kepler109!";

var config = new AmazonS3Config
{
    ServiceURL = endpoint,
    ForcePathStyle = true,
    AuthenticationRegion = "us-east-1"
};

using var s3 = new AmazonS3Client(
    new BasicAWSCredentials(accessKey, secretKey),
    config
);

var bucketName = "demo-bucket";
var objectKey = "hello.txt";

if (!await AmazonS3Util.DoesS3BucketExistV2Async(s3, bucketName))
{
    await s3.PutBucketAsync(new PutBucketRequest
    {
        BucketName = bucketName
    });
}

await s3.PutObjectAsync(new PutObjectRequest
{
    BucketName = bucketName,
    Key = objectKey,
    ContentBody = "Hello from MinIO via AWS SDK for .NET"
});

var objectResponse = await s3.GetObjectAsync(new GetObjectRequest
{
    BucketName = bucketName,
    Key = objectKey
});

using var reader = new StreamReader(objectResponse.ResponseStream);
var content = await reader.ReadToEndAsync();
Console.WriteLine($"Read object: {content}");

var buckets = await s3.ListBucketsAsync();
Console.WriteLine("Buckets:");
foreach (var bucket in buckets.Buckets)
{
    Console.WriteLine($"- {bucket.BucketName}");
}
