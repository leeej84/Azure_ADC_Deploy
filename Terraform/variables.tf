# subscription ids
variable "subscription_id" {
  type    = string
  default = "8817c809-4996-4b1c-a7c2-41e960bae57d"
}

# automation
variable "default_location" {
  type    = string
  default = "uksouth"
}

variable "rg" {
  type    = string
  default = "rg-e2evc"
}

variable "nsg_e2evc" {
  type    = string
  default = "nsg-e2evc"
}

variable "vnet_e2evc" {
  type    = string
  default = "vnet-e2evc"
}

variable "st_automation_storage" {
  type    = string
  default = "ste2evc"
}

variable "functionapp_e2evc" {
  type    = string
  default = "fa-e2evc"
}

variable "la_e2evc" {
  type    = string
  default = "la-e2evc"
}

variable "la_in_e2evc" {
  type    = string
  default = "la-in-e2evc"
}

variable "asp_e2evc" {
  type    = string
  default = "asp-e2evc"
}

variable "functionapp_provisioning_settings" {
  type = map(any)
  default = {
    PSWorkerInProcConcurrencyUpperBound = "40"
    FUNCTIONS_WORKER_PROCESS_COUNT      = "40"
  }
}