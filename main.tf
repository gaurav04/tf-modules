resource "aws_elasticache_subnet_group" "redis_cluster_subnet" {
  name = "redis-test-subnet"
  subnet_ids = ["subnet-2e986c45","subnet-bdf1abf1","subnet-e89ff393"]
}

resource "aws_elasticache_parameter_group" "redis_cluster_parameters" {
  family = "redis3.2"
  name   = "redis-test-params"  
  parameter {
    name  = "cluster-enabled"
    value = "yes"
  }
}


resource "aws_elasticache_parameter_group" "redis_cluster_parameters_six" {
  family = "redis6.x"
  name   = "redis-test-params-six"  
  parameter {
    name  = "cluster-enabled"
    value = "yes"
  }
}

variable "network" {
  
}

resource "aws_elasticache_replication_group" "RedisCluster" {
  count = "${var.network == "dev" ? 1 : 0}"
  node_type                     = "cache.t2.micro"
  port                          = "6379"
  engine_version                = "6.2.6"
  replication_group_description = "Test"
  replication_group_id          = "redis-test-${var.network}rn"
  parameter_group_name          = "${aws_elasticache_parameter_group.redis_cluster_parameters_six.name}"
  security_group_ids            = ["sg-5cb87e20"]
  automatic_failover_enabled    = true
  cluster_mode {
    num_node_groups         = 1
    replicas_per_node_group = 0
 }
  subnet_group_name = "${aws_elasticache_subnet_group.redis_cluster_subnet.name}"
}


resource "aws_elasticache_replication_group" "RedisCluster" {
  count = "${var.network != "dev" ? 1 : 0}"
  node_type                     = "cache.t2.micro"
  port                          = "6379"
  engine_version                = "3.2.6"
  replication_group_description = "Test"
  replication_group_id          = "redis-test-${var.network}rn"
  parameter_group_name          = "${aws_elasticache_parameter_group.redis_cluster_parameters.name}"
  security_group_ids            = ["sg-5cb87e20"]
  automatic_failover_enabled    = true
  cluster_mode {
    num_node_groups         = 1
    replicas_per_node_group = 0
  }
  subnet_group_name = "${aws_elasticache_subnet_group.redis_cluster_subnet.name}"
}
