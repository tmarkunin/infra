provider "google" {
  project = "${var.project}"
  region  = "${var.region}"
 }

resource "google_compute_instance" "db" {
    name         = "reddit-db"
    machine_type = "g1-small"
    zone         = "us-central1-a"
    tags = ["reddit-db"] 
    boot_disk {
       initialize_params {
        image =  "${var.db_disk_image}"    
         }  
     } 
  # определение сетевого интерфейса
  network_interface {
    # сеть, к которой присоединить данный интерфейс   
     network = "default" 
    # использовать ephemeral IP для доступа из Интернет
    access_config {}
}

 metadata = {
    ssh-keys =  "appuser:${file(var.public_key_path)}"
    }

}

resource "google_compute_firewall" "firewall_mongo" {
    name    = "allow-mongo-default"
 # Название сети, в которой действует правило
    network = "default"
 # Какой доступ разрешить
    allow {
      protocol = "tcp"
      ports    = ["27017"]
    }
 # Каким адресам разрешаем доступ
    source_tags = ["reddit-app"]
 # Правило применимо для инстансов с тегом …
   target_tags = ["reddit-db"]
}
  
resource "google_compute_firewall" "firewall_ssh" {
    name    = "allow-ssh-default"
 # Название сети, в которой действует правило
    network = "default"
 # Какой доступ разрешить
    allow {
      protocol = "tcp"
      ports    = ["22"]
    }
 # Каким адресам разрешаем доступ
    source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_address" "app_ip" {
    name = "reddit-app-ip" 
    region = "us-central1"

}
