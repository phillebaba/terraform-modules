provider "aws" {
  region = "us-east-1"
  alias = "acm"
}

locals {
  aliases = ["www.${var.domain_name}", "${var.domain_name}"]
  origin_id = "origin-${var.domain_name}"
}

# Route53
data "aws_route53_zone" "default" {
  name     = "${var.domain_name}"
}

resource "aws_route53_record" "www_route53_record" {
  zone_id = "${data.aws_route53_zone.default.zone_id}"
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.default.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.default.hosted_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "route53_record" {
  zone_id = "${data.aws_route53_zone.default.zone_id}"
  name    = "${var.domain_name}"
  type    = "A"

  alias {
    name                   = "${aws_route53_record.www_route53_record.name}"
    zone_id                = "${data.aws_route53_zone.default.zone_id}"
    evaluate_target_health = false
  }
}

# ACM
resource "aws_acm_certificate" "default" {
  provider                  = "aws.acm"
  domain_name               = "${var.domain_name}"
  subject_alternative_names = "${local.aliases}"
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "default" {
  provider        = "aws.acm"
  certificate_arn = "${aws_acm_certificate.default.arn}"
  validation_record_fqdns = ["${aws_route53_record.cert_validation_0.fqdn}", "${aws_route53_record.cert_validation_1.fqdn}"]
}

# Related to this issue in Terraform
# https://github.com/hashicorp/terraform/issues/12570
#resource "aws_route53_record" "cert_validation" {
#  count    = "${length(aws_acm_certificate.default.domain_validation_options)}"
#  name     = "${lookup(aws_acm_certificate.default.domain_validation_options[count.index], "resource_record_name")}"
#  type     = "${lookup(aws_acm_certificate.default.domain_validation_options[count.index], "resource_record_type")}"
#  records  = ["${lookup(aws_acm_certificate.default.domain_validation_options[count.index], "resource_record_value") }"]
#  zone_id  = "${data.aws_route53_zone.default.zone_id}"
#  ttl      = 60
#}

resource "aws_route53_record" "cert_validation_0" {
  name     = "${lookup(aws_acm_certificate.default.domain_validation_options[0], "resource_record_name")}"
  type     = "${lookup(aws_acm_certificate.default.domain_validation_options[0], "resource_record_type")}"
  records  = ["${lookup(aws_acm_certificate.default.domain_validation_options[0], "resource_record_value") }"]
  zone_id  = "${data.aws_route53_zone.default.zone_id}"
  ttl      = 60
}

resource "aws_route53_record" "cert_validation_1" {
  name     = "${lookup(aws_acm_certificate.default.domain_validation_options[1], "resource_record_name")}"
  type     = "${lookup(aws_acm_certificate.default.domain_validation_options[1], "resource_record_type")}"
  records  = ["${lookup(aws_acm_certificate.default.domain_validation_options[1], "resource_record_value") }"]
  zone_id  = "${data.aws_route53_zone.default.zone_id}"
  ttl      = 60
}


# CloudFront
resource "aws_cloudfront_distribution" "default" {
  enabled             = true
  is_ipv6_enabled     = false
  #default_root_object = "${var.index_document}"
  price_class         = "${var.price_class}"

  origin {
    domain_name = "${var.origin_domain_name}"
    origin_id   = "${local.origin_id}"

    custom_origin_config {
      http_port = 80
      https_port = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols = ["TLSv1.2"]
    }
  }

  aliases = "${local.aliases}"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${local.origin_id}"

    forwarded_values {
      query_string = false
      headers      = ["Access-Control-Request-Headers", "Access-Control-Request-Method", "Origin"]

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = "${aws_acm_certificate_validation.default.certificate_arn}"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1"
  }
}
