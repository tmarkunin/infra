provider "google" {
  project = "${var.project}"
  region  = "${var.region}"
 }

resource "google_compute_instance" "app" {
    name         = "reddit-app"
    machine_type = "g1-small"
    zone         = "us-central1-a"
    tags = ["reddit-app"] 
    boot_disk {
       initialize_params {
        image =  "${var.disk_image}"    
         }  
     } 
  # определение сетевого интерфейса
  network_interface {
    # сеть, к которой присоединить данный интерфейс   
     network = "default" 
    # использовать ephemeral IP для доступа из Интернет
    access_config {}  
}

provisioner "file" {
    source      = "files/puma.service"
    destination = "/tmp/puma.service" 
 connection {
   type     = "ssh"
   user     = "appuser"
   host = self.network_interface.0.access_config.0.nat_ip
   agent = false
   private_key = "${file("~/.ssh/appuser")}"
 }


}
provisioner "remote-exec" {
    script = "files/deploy.sh" 
 connection {
   type     = "ssh"
   user     = "appuser"
   agent = false
   host = self.network_interface.0.access_config.0.nat_ip
   private_key = "${file("~/.ssh/appuser")}"
 }


} 
 
  metadata = {
    ssh-keys =  "appuser:${file(var.public_key_path)}"
    }

}

resource "google_compute_firewall" "firewall_puma" {
    name    = "allow-puma-default"
 # Название сети, в которой действует правило
    network = "default"
 # Какой доступ разрешить
    allow {
      protocol = "tcp"
      ports    = ["9292"]
    }
 # Каким адресам разрешаем доступ
    source_ranges = ["0.0.0.0/0"]
 # Правило применимо для инстансов с тегом …
   target_tags = ["reddit-app"]
}
  
