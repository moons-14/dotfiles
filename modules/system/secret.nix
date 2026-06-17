_:
let
  commonSyetemSecrets = ../../secrets/common/system.yaml;
in
{
  sops.secrets = {
    "users/moons/hashedPassword" = {
      sopsFile = commonSyetemSecrets;

      # need before user creation
      neededForUsers = true;
    };
  };
}
