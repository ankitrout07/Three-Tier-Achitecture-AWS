# Aurora MySQL Cluster
resource "aws_rds_cluster" "aurora" {
  cluster_identifier      = "${var.project_name}-aurora-cluster"
  engine                  = "aurora-mysql"
  engine_version          = "8.0.mysql_aurora.3.04.0"
  database_name           = "webappdb"
  master_username         = "admin"
  master_password         = var.db_password
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  db_subnet_group_name    = aws_db_subnet_group.main.name
  vpc_security_group_ids  = [aws_security_group.db_sg.id]
  skip_final_snapshot     = true

  tags = {
    Name = "${var.project_name}-aurora-cluster"
  }
}

# Aurora Cluster Instance
resource "aws_rds_cluster_instance" "aurora_instance" {
  identifier         = "${var.project_name}-aurora-instance"
  cluster_identifier = aws_rds_cluster.aurora.id
  instance_class     = var.db_instance_class
  engine             = aws_rds_cluster.aurora.engine
  engine_version     = aws_rds_cluster.aurora.engine_version

  tags = {
    Name = "${var.project_name}-aurora-instance"
  }
}
