resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "${var.site_name}${var.domain} Created by Terraform"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = "${aws_s3_bucket.main.id}.s3.amazonaws.com"
    origin_id   = "S3-${aws_s3_bucket.main.id}"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path}"
    }

  }

  enabled             = true
  comment             = "Created by terraform, dont edit manually!!"
  default_root_object = "index.html"

  aliases = ["${var.site_name}${var.domain}"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.main.id}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = "${var.acm_certificate_arn}"
    iam_certificate_id       = "${var.ssl_cert}"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1"
  }

  custom_error_response {
    error_code            = "404"
    error_caching_min_ttl = "0"
    response_code         = "${var.error_response_code}"
    response_page_path    = "${var.error_response_pagepath}"
  }
}
