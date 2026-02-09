locals {
  instance-user-data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install apache2 -y
    systemctl start apache2
    systemctl enable apache2
    echo "<h1>VPC Region: ${var.region}</h1>" > /var/www/html/index.html
    echo "<h1>Private IP: $(hostname -I)</h1>" >> /var/www/html/index.html
  EOF
}
