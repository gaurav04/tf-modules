locals {
  family = {
    "6.2" = "redis6.x"
    "3.2.6" = "redis3.2"
  }
}

variable "engine_version" {
  default = "3.2.6"
}

resource "aws_elasticache_subnet_group" "redis_cluster_subnet" {
  name = "redis-test-subnet"
  subnet_ids = ["subnet-2e986c45","subnet-bdf1abf1","subnet-e89ff393"]
}

resource "aws_elasticache_parameter_group" "redis_cluster_parameters" {
  family = "${lookup(local.family, var.engine_version)}"
  name   = "${var.engine_version == 6.2 ? "redis-rcl-params-vsix" : "redis-rcl-params"}"

  parameter {
    name  = "cluster-enabled"
    value = "yes"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_elasticache_replication_group" "RedisCluster" {
  node_type                     = "cache.t2.micro"
  port                          = "6379"
  engine_version                = "${var.engine_version}"
  replication_group_description = "Test"
  replication_group_id          = "redis-test-rn"
  parameter_group_name          = "${aws_elasticache_parameter_group.redis_cluster_parameters.name}"
  security_group_ids            = ["sg-5cb87e20"]
  automatic_failover_enabled    = true
  cluster_mode {
    num_node_groups         = 1
    replicas_per_node_group = 0
  }
  subnet_group_name = "${aws_elasticache_subnet_group.redis_cluster_subnet.name}"
  apply_immediately = true
}
