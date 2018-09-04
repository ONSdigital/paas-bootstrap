output "cc_database_name" {
  value = "${mysql_database.cc.name}"
}

output "uaa_database_name" {
  value = "${mysql_database.uaa.name}"
}

output "bbs_database_name" {
  value = "${mysql_database.bbs.name}"
}

output "routing_api_database_name" {
  value = "${mysql_database.routing_api.name}"
}

output "policy_server_database_name" {
  value = "${mysql_database.policy_server.name}"
}

output "silk_controller_database_name" {
  value = "${mysql_database.silk_controller.name}"
}

output "locket_database_name" {
  value = "${mysql_database.locket.name}"
}
