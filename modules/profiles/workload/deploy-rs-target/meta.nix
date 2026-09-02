{
  description = "NixOS deploy-rs deployment target";

  includes = [
    "services.openssh"
    "users.nixdeploy"
  ];
}
