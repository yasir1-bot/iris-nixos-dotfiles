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
    # v0.1.2 (2026-08-05); the previously pinned rev did not exist upstream.
    rev = "0b7daec66dc5f84dfc557f437c6b73a4b59399c0";
    hash = "sha256-l2X1TVTHfYCqDZJcvvgVLXU/9NXcNb2rGHiN3PgfswE=";
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
