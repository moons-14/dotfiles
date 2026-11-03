"""Exercise installation and failed updates without network access."""

import hashlib
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


INSTALLER = Path(__file__).resolve().parents[1] / "modules/applications/vim/install-portable.sh"


class PortableInstallerTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.install_dir = self.root / "installed"
        self.source = self.root / "release"
        self.source.mkdir()
        self.mock_bin = self.root / "bin"
        self.mock_bin.mkdir()
        self.asset = "moons-nvim-linux-x86_64"
        self.env = os.environ | {
            "PATH": f"{self.mock_bin}:{os.defpath}",
            "MOONS_NVIM_INSTALL_DIR": str(self.install_dir),
            "TEST_RELEASE": str(self.source),
            "TEST_ARCH": "x86_64",
        }
        self.write_mock("uname", '#!/bin/sh\nif [ "$1" = -s ]; then echo Linux; else echo "$TEST_ARCH"; fi\n')
        self.write_mock("curl", """#!/usr/bin/env python3
import os
from pathlib import Path
import shutil
import sys
args = sys.argv[1:]
if os.environ.get("TEST_DOWNLOAD_FAIL"):
    sys.exit(22)
url = next(arg for arg in args if arg.startswith("https://"))
target = args[args.index("-o") + 1]
shutil.copyfile(Path(os.environ["TEST_RELEASE"]) / url.rsplit("/", 1)[1], target)
""")

    def write_mock(self, name, content):
        path = self.mock_bin / name
        path.write_text(content)
        path.chmod(0o755)

    def make_release(self, content):
        (self.source / self.asset).write_bytes(content)
        digest = hashlib.sha256(content).hexdigest()
        (self.source / f"{self.asset}.sha256").write_text(f"{digest}  {self.asset}\n")

    def run_installer(self):
        return subprocess.run(
            ["/bin/sh", str(INSTALLER)], env=self.env,
            capture_output=True, text=True, check=False,
        )

    def test_install_and_update_preserve_previous_executable(self):
        self.make_release(b"first version\n")
        result = self.run_installer()
        self.assertEqual(result.returncode, 0, result.stderr)
        target = self.install_dir / "moons-nvim"
        self.assertEqual(target.read_bytes(), b"first version\n")
        self.assertTrue(os.access(target, os.X_OK))
        self.make_release(b"second version\n")
        result = self.run_installer()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(target.read_bytes(), b"second version\n")
        self.assertEqual((self.install_dir / "moons-nvim.previous").read_bytes(), b"first version\n")
        self.assertEqual(list(self.install_dir.glob(".moons-nvim.*")), [])

    def test_corrupt_download_does_not_replace_existing_version(self):
        self.make_release(b"original\n")
        self.assertEqual(self.run_installer().returncode, 0)
        (self.source / self.asset).write_bytes(b"corrupted\n")
        self.assertNotEqual(self.run_installer().returncode, 0)
        self.assertEqual((self.install_dir / "moons-nvim").read_bytes(), b"original\n")
        self.assertFalse((self.install_dir / "moons-nvim.previous").exists())
        self.assertEqual(list(self.install_dir.glob(".moons-nvim.*")), [])

    def test_failed_download_does_not_replace_existing_version(self):
        self.make_release(b"original\n")
        self.assertEqual(self.run_installer().returncode, 0)
        self.env["TEST_DOWNLOAD_FAIL"] = "1"
        self.assertNotEqual(self.run_installer().returncode, 0)
        self.assertEqual((self.install_dir / "moons-nvim").read_bytes(), b"original\n")
        self.assertEqual(list(self.install_dir.glob(".moons-nvim.*")), [])

    def test_unsupported_architecture_is_rejected(self):
        self.env["TEST_ARCH"] = "riscv64"
        result = self.run_installer()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Unsupported CPU architecture", result.stderr)
        self.assertFalse(self.install_dir.exists())


if __name__ == "__main__":
    unittest.main()
