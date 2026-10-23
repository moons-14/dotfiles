{
  description = "Network lab and hardware console environment";

  includes = [
    "services.docker"
    "applications.nanokvm-usb"
  ];
}
