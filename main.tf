// Global Content Delivery Network
// S3 + Cloudfront
// Content of those bucket has been populated manually
resource "aws_s3_bucket" "main" {
  bucket = "${var.site_name}${replace(var.domain, ".", "-")}"
  acl    = "public-read"

  policy = <<EOF
{
	"Version": "2008-10-17",
	"Id": "Policy1412590466126",
	"Statement": [
		{
			"Sid": "Stmt1412590461560",
			"Effect": "Allow",
			"Principal": {
				"AWS": "*"
			},
			"Action": "s3:GetObject",
			"Resource": "arn:aws:s3:::${var.site_name}${replace(var.domain, ".", "-")}/*"
		}
	]
}
EOF

  website {
    index_document = "index.html"
    error_document = "404.html"
  }
}

# Add record on DNS for minion instance
resource "aws_route53_record" "site" {
  zone_id = "${var.public_dns_zone}"
  name    = "${var.site_name}${var.domain}"
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.s3_distribution.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.s3_distribution.hosted_zone_id}"
    evaluate_target_health = true
  }
}

output "bucket" {
  value = "${aws_s3_bucket.main.id}"
}

output "bucket_arn" {
  value = "${aws_s3_bucket.main.arn}"
}
