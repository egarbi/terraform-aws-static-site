// Global Content Delivery Network
// S3 + Cloudfront
// Content of this bucket will be populated manually
data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.site_name}${replace(var.domain, ".", "-")}/*"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn}"]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${var.site_name}${replace(var.domain, ".", "-")}"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn}"]
    }
  }
}

resource "aws_s3_bucket" "main" {
  bucket = "${var.site_name}${replace(var.domain, ".", "-")}"
  acl    = "public-read"

  policy = "${data.aws_iam_policy_document.s3_policy.json}"

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
