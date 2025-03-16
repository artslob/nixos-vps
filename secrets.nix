let
  vps =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG1maMdLslN32frKSs489iz+9vMmnox7Sxop5LSJjUU/";
  personal_projects =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICFNSePweS1I3ucce46M50qXbr0330RUOMG9ZiGchvxN";

  all = [
    vps
    personal_projects
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBiAvme/Pup3RUJRZIrQAfUqVH0XGAmr173XHtYeF669"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGJLGER9xJoAmr0FjphcectmJRyMwRuZodFVHgm4INq9"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBNx5a3WMd3VVY42Gtz2rUvb+8WK8yZjsk5O3q4TqRmD"
  ];
in {
  "secrets/secret1.age".publicKeys = all;
  "secrets/test-github-runner-token.age".publicKeys = all;
  "secrets/wireguard-private-key.age".publicKeys = all;
}
