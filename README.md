# Azure_ADC_Deploy
Used in a presentation given at E2EVC Berlin 2022

- Terraform Scipts to standup the infrastructure that is required
- - Terraform variables need to be amended to be specific to you
- An Azure Function App that is configured to allow deployment of a Citrix ADC via an API call
- ARM Template to provision a Citrix ADC

The Function App hosts an API that is written in powershell
There is a Test.ps1 powershell script that will submit API calls to the function

On a successful build you will be presented with the login name, login password and ip address of your ADC

On a successful query you will be presented with the ip address of your ADC

On a successful removal you will be notified that the ADC has been removed

