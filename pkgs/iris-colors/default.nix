{ lib
, python3Packages
, fetchFromGitHub
}:

python3Packages.buildPythonApplication rec {
  pname = "iris-colors";
  version = "0.1.0-unstable-2026-08-05";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Harman1307";
    repo = "iris";
    rev = "d95d7252f0f5b84f7f6e7a5f7dbeef8a0be24e5b"; # TODO: pin verified commit/hash after upstream review
    hash = lib.fakeHash; # TODO: replace with real hash (nix build will report)
  };

  build-system = [ python3Packages.hatchling ];

  dependencies = with python3Packages; [
    pillow
    numpy
  ];

  # Iris is primarily a CLI; upstream tests not packaged/verified here.
  doCheck = false;

  meta = with lib; {
    description = "CLI wallpaper-driven color scheme generator with semantic colors";
    homepage = "https://github.com/Harman1307/iris";
    license = licenses.mit;
    mainProgram = "iris";
    platforms = platforms.linux;
  };
}
