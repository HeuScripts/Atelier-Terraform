data "template_file" "output" {
  template = file("./output.tpl")
  vars = {
    ip = data.azurerm_public_ip.myterraformpublicip.ip_address
    pass = random_password.password.result
    minute = time_static.myterraformtime.minute
    hour = time_static.myterraformtime.hour
    day = time_static.myterraformtime.day
    month = time_static.myterraformtime.month
    year = time_static.myterraformtime.year
  }
  depends_on = [
    azurerm_virtual_machine.myterraformvm,
    azurerm_public_ip.myterraformpublicip
  ]
}

output "info" { 
    value = data.template_file.output.rendered
    depends_on = [time_sleep.wait_20_seconds]
}
resource "local_file" "output" {
  content  = data.template_file.output.rendered
  filename = "1-output.txt"
  depends_on = [
    azurerm_virtual_machine.myterraformvm,
    time_sleep.wait_20_seconds
  ]
}

resource "time_static" "myterraformtime" {  
  depends_on = [
    azurerm_virtual_machine.myterraformvm,
    azurerm_public_ip.myterraformpublicip
  ]
}

resource "time_sleep" "wait_20_seconds" {
  depends_on = [azurerm_virtual_machine.myterraformvm]
  create_duration = "20s"
}