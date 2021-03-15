// Configure the Google Cloud provider
provider "google" {
 credentials = file("Project-e59a94f4f298.json")
 project     = "tough-racer-302813"
 region      = "europe-north1"
}

// Terraform plugin for creating random ids
resource "random_id" "instance_id" {
 byte_length = 8
}

// A single Compute Engine instance
resource "google_compute_instance" "dev" {
 //name         = "instance-dev-${random_id.instance_id.hex}"
 name         = "instance-dev-001"
 machine_type = "e2-medium"
 zone         = "europe-north1-a"


 boot_disk {
   initialize_params {
     image = "debian-cloud/debian-10"
   }
}
metadata = {
   ssh-keys = "root:${file("~/.ssh/id_rsa.pub")}"
 }

//metadata_startup_script = "sudo apt-get update; sudo apt-get install -y maven git; git clone https://github.com/andgre/boxfuse11.git; cd ./boxfuse11; mvn war:war;"

 network_interface {
   network = "default"

   access_config {
     // Include this section to give the VM an external ip address
   }
}


provisioner "remote-exec" {
    inline = [
      "apt-get update",
      "apt-get install -y maven git",
      "git clone https://github.com/andgre/boxfuse11.git",
      "pwd",
      "cd ./boxfuse11",
      "mvn war:war",
    ]

}


provisioner "local-exec" {
  command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@${google_compute_instance.dev.network_interface.0.access_config.0.nat_ip}:~/boxfuse11/target/hello-1.0.war /tmp/hello-1.0.war"
}


connection {
    host        = google_compute_instance.dev.network_interface.0.access_config.0.nat_ip //self.network_interface[0].access_config[0].nat_ip
    type        = "ssh"
    user        = "root"
    private_key = "${file("~/.ssh/id_rsa")}"
    timeout     = "30s"
  }

}
/*
// A variable for extracting the external IP address of the instance
output "dev_ip_addr" {
 value = google_compute_instance.dev.network_interface.0.access_config.0.nat_ip
}
output "vars_env" {
value = google_compute_instance.default
}
*/
// A single Compute Engine instance

resource "google_compute_instance" "prod" {
 //name         = "instance-dev-${random_id.instance_id.hex}"
 name         = "instance-prod-001"
 machine_type = "e2-medium"
 zone         = "europe-north1-a"
 depends_on = [google_compute_instance.dev]

 boot_disk {
   initialize_params {
     image = "ubuntu-os-cloud/ubuntu-2004-lts"
   }
}
metadata = {
   ssh-keys = "root:${file("~/.ssh/id_rsa.pub")}"
 }

 network_interface {
   network = "default"

   access_config {
     // Include this section to give the VM an external ip address
   }
}

provisioner "remote-exec" {
    inline = [
      "apt-get update &&",
      "apt-get install -y tomcat9",
    ]

connection {
    host        = google_compute_instance.prod.network_interface.0.access_config.0.nat_ip //self.network_interface[0].access_config[0].nat_ip
    type        = "ssh"
    user        = "root"
    private_key = "${file("~/.ssh/id_rsa")}"
    timeout     = "90s"
  }
}

provisioner "local-exec" {
  command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null /tmp/hello-1.0.war root@${google_compute_instance.prod.network_interface.0.access_config.0.nat_ip}:/var/lib/tomcat9/webapps/hello-1.0.war"
}


}
output "prod_ip_addr" {
 value = google_compute_instance.prod.network_interface.0.access_config.0.nat_ip
}
/*
resource "google_compute_instance" "dev" {
 name         = "instance-dev-001"
 machine_type = "e2-medium"
 zone         = "europe-north1-a"


 boot_disk {
   initialize_params {
     image = "debian-cloud/debian-10"
   }
}

 network_interface {
   network = "default"
   access_config {
     // Include this section to give the VM an external ip address
   }
}
desired_status = "TERMINATED"
}
*/