provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "kubernetes_namespace" "hive" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "hive_metastore" {
  name       = "hive-metastore"
  namespace  = kubernetes_namespace.hive.metadata[0].name
  chart      = "./hive-emr-on-eks-main/hive-metastore-chart"
  # repository = "" # Remove the repository field in this case
  version    = "0.0.4" # Keep the version for clarity

  values = [
    yamlencode({
      env = {
        HIVE_DB_EXTERNAL = "true"
        HIVE_DB_DRIVER   = "com.mysql.cj.jdbc.Driver"
        HIVE_CONF_PARAMS = "hive.metastore.schema.verification:true;datanucleus.autoCreateSchema:true;datanucleus.schema.autoCreateTables:true"
        HIVE_DB_JDBC_URL  = "jdbc:mysql://hive-metastore-db.cv0mmcsqql0c.us-west-2.rds.amazonaws.com:3306/metastore?createDatabaseIfNotExist=true"
        HIVE_DB_USER     = "admin"
        HIVE_DB_PASS     = "Rudresh$16$25"
        HIVE_WAREHOUSE_DIR = "s3://iceberg-pipeline-760561616948-us-west-2/warehouse"
      },
      service = {
        type = var.service_type # Make service type configurable
      }
    })
  ]
}