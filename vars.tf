# Copyright © 2020, Oracle and/or its affiliates. 
# All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

// Basic Hidden
variable "tenancy_ocid" {}
variable "compartment_ocid" {
  default = ""
}
variable "region" {}

// Extra Hidden
variable "current_user_ocid" {
  default = ""
}
variable "fingerprint" {
  default = ""
}
variable "private_key_path" {
  default = ""
}

// General Configuration
variable "proj_abrv" {
  default = "apexpoc"
}
variable "size" {
    default = "ALF"
}
variable "adb_license_model" {
  default = "BRING_YOUR_OWN_LICENSE"
}

// Additional Resources
variable "prov_object_storage" {
  description = "Provision Object Storage Bucket"
  default = "false"
}

variable "prov_data_safe" {
  description = "Provision Data Safe"
  default = "false"
}

variable "prov_oic" {
  description = "Provision Oracle Integration Cloud"
  default = "false"
}

variable "enable_lb_logging" {
  description = "Enable Load Balancer Logging"
  default = "false"
}

//The sizing is catering for schema.yaml visibility
//Default is ALF (size) though this boolean is false
//Check the locals at bottom for logic
variable "always_free" {
  default = "false"
}

variable "adb_cpu_core_count" {
  type = map
  default = {
    "L"   = 4
    "M"   = 2
    "S"   = 1
    "ALF" = 1
  }
}

variable "adb_dataguard" {
  type = map
  default = {
    "L"   = true
    "M"   = true
    "S"   = false
    "ALF" = false
  }
}

variable "flex_lb_min_shape" {
  type = map
  default = {
    "L"   = 100
    "M"   = 100
    "S"   = 10
    "ALF" = 10
  }
}

variable "flex_lb_max_shape" {
  type = map
  default = {
    "L"   = 1250
    "M"   = 1250
    "S"   = 480
    "ALF" = 10
  }
}

// Number of ORDS Servers; Scalable x3 (excl. ALF)
variable "compute_instances" {
  type = map
  default = {
    "L"   = 3
    "M"   = 2
    "S"   = 1
    "ALF" = 1
  }
}

// Scalable x2 (excl. ALF)
variable "compute_flex_shape_ocpus" {
  type = map
  default = {
    "L"   = 4
    "M"   = 2
    "S"   = 1
    "ALF" = 1
  }
}

variable "adb_storage_size_in_tbs" {
  default = 1
}

variable "adb_db_version" {
  type = map
  default = {
    "L"   = "19c"
    "M"   = "19c"
    "S"   = "19c"
    "ALF" = "21c"
  }
}

variable "compute_os" {
  default = "Oracle Autonomous Linux"
}

variable "linux_os_version" {
  default = "7.9"
}

variable "bastion_user" {
  default = "opc"
}

// VCN Configurations Variables
variable "vcn_cidr" {
  default = "10.0.0.0/16"
}

variable "vcn_is_ipv6enabled" {
  default = true
}

variable "public_subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  default = "10.0.2.0/24"
}

# Dictionary Locals
locals {
  compute_flexible_shapes = [
    "VM.Standard.E3.Flex",
    "VM.Standard.E4.Flex",
    "VM.Standard.A1.Flex",
    "VM.Optimized3.Flex"
  ]
}

# Dynamic Vars
locals {
  sizing               = var.always_free ? "ALF" : var.size
  is_paid              = local.sizing != "ALF" ? true : false
  adb_private_endpoint = local.sizing != "ALF" ? true  : false
  compute_shape        = local.sizing != "ALF" ? "VM.Standard.E3.Flex" : "VM.Standard.E2.1.Micro"
  is_flexible_shape    = contains(local.compute_flexible_shapes, local.compute_shape)
  compartment_ocid     = var.compartment_ocid != "" ? var.compartment_ocid : var.tenancy_ocid
}
