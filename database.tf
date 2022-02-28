# Copyright © 2020, Oracle and/or its affiliates. 
# All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "random_password" "autonomous_database_password" {
  length           = 16
  min_numeric      = 1
  min_lower        = 1
  min_upper        = 1
  min_special      = 1
  override_special = "_#"
  keepers = {
    uuid = "uuid()"
  }
}

resource "oci_database_autonomous_database" "autonomous_database" {
  admin_password              = random_password.autonomous_database_password.result
  compartment_id              = var.compartment_ocid
  db_name                     = format("%sDB%s", upper(var.proj_abrv), var.size)
  cpu_core_count              = var.adb_cpu_core_count[var.size]
  data_storage_size_in_tbs    = var.adb_storage_size_in_tbs
  db_version                  = var.adb_db_version[var.size]
  db_workload                 = "OLTP"
  display_name                = format("%sDB_%s", upper(var.proj_abrv), var.size)
  is_free_tier                = local.is_always_free
  is_auto_scaling_enabled     = local.is_always_free ? false : true
  license_model               = local.is_always_free ? "LICENSE_INCLUDED" : var.adb_license_model
  whitelisted_ips             = local.is_always_free ? [oci_core_vcn.vcn.id] : null
  nsg_ids                     = local.adb_private_endpoint ? [oci_core_network_security_group.security_group_adb[0].id] : null
  private_endpoint_label      = local.adb_private_endpoint ? "ADBPrivateEndpoint" : null
  subnet_id                   = local.adb_private_endpoint ? oci_core_subnet.subnet_private[0].id : null
  is_mtls_connection_required = false
  // This should be variabled but there's an issue with creating DG on initial creation
  is_data_guard_enabled       = false
  lifecycle {
    ignore_changes = all
  }
}