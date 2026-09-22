#!/usr/bin/env python3
"""Package the tested RAM payload using the vendor FIT layout; never flash it."""

import argparse
import hashlib
from pathlib import Path
import subprocess
import zlib


REPO_ROOT = Path(__file__).resolve().parents[2]
DELIVERABLES = Path(__file__).resolve().parent / "deliverables"
CONTAINER = "sercomm-toolchain"
REMOTE = "/tmp/elife_ramopts_fit_20260922"
RAW_SHA256 = "994310db616be38a2773a4355205049d6fa8a0172f91902da87bf4eb13633f7c"
V4_SHA256 = "1e5b3a0cc83bf9ceb5d451d8e64de398a76e186098af8fb9a56decf313a9a859"
NAME = "emmc_brcm_simple_ramopts_20260922"

CONTAINER_BUILD = r"""
import hashlib
import os
from pathlib import Path
import struct
import subprocess

sdk = Path("/build/asuswrt-merlin/release/src-rt-5.04behnd.4916")
boot = sdk / "bootloaders"
obj = boot / "obj/ramopts_uboot"
os.environ["PATH"] = str(obj / "scripts/dtc") + os.pathsep + os.environ["PATH"]
work = Path("/tmp/elife_ramopts_fit_20260922")
work.mkdir(exist_ok=True)
name = "emmc_brcm_simple_ramopts_20260922"
code = (obj / "u-boot-nodtb.bin").read_bytes()
dtb = (obj / "dts/dt.dtb").read_bytes()
raw = (obj / "u-boot.bin").read_bytes()
assert code + dtb == raw
assert hashlib.sha256(raw).hexdigest() == "994310db616be38a2773a4355205049d6fa8a0172f91902da87bf4eb13633f7c"
assert hashlib.sha256(dtb).hexdigest() == "54b013287992df323e2a90028d4cac1ed43daff3c6a693788939009eecf61a8a"
its = work / (name + ".its")
its.write_text(f'''/dts-v1/;
/ {{
    description = "Simple image with ATF and optional OP-TEE support";
    #address-cells = <1>;
    images {{
        uboot {{
            description = "U-Boot";
            data = /incbin/("{obj}/u-boot-nodtb.bin");
            os = "U-Boot";
            arch = "arm64";
            compression = "none";
            load = <0x1000000>;
            entry = <0x1000000>;
            hash-1 {{ algo = "sha256"; }};
        }};
        fdt_uboot {{
            description = "dtb";
            data = /incbin/("{obj}/dts/dt.dtb");
            type = "flat_dt";
            compression = "none";
            hash-1 {{ algo = "sha256"; }};
        }};
    }};
    configurations {{
        default = "conf_uboot";
        conf_uboot {{
            description = "BRCM 63xxx with uboot";
            fdt = "fdt_uboot";
            loadables = "uboot";
        }};
    }};
}};
''')


def run(*args):
    subprocess.run([str(arg) for arg in args], check=True)


mkimage = obj / "tools/mkimage"
first = work / "initial.itb"
image = work / (name + ".itb")
run(mkimage, "-f", its, "-E", first)
header_size = struct.unpack_from(">I", first.read_bytes(), 4)[0]
run(mkimage, "-p", hex(header_size + 4096), "-f", its, "-E", image)
blob = image.read_bytes()
header_size = struct.unpack_from(">I", blob, 4)[0]
signable = work / "header.bin"
signable.write_bytes(blob[:header_size])
signature = work / "header.sig"
key = sdk / "targets/keys/demo/GEN3/Krot-fld.pem"
public_key = work / "public.pem"
run("openssl", "pkey", "-in", key, "-pubout", "-out", public_key)
run("openssl", "dgst", "-sign", key, "-keyform", "pem", "-sha256",
    "-sigopt", "rsa_padding_mode:pss", "-sigopt", "rsa_pss_saltlen:-1",
    "-out", signature, signable)
run(boot / "build/work/fit_header_tool", "--sig", signature, image)

# Check that both the old v4 and new FIT use the same signing key and format.
for path in (work / "v4.itb", image):
    data = path.read_bytes()
    size = struct.unpack_from(">I", data, 4)[0]
    assert struct.unpack_from("<I", data, size)[0] == 0x46495453
    check_header = work / (path.stem + "_header.bin")
    check_sig = work / (path.stem + "_header.sig")
    check_header.write_bytes(data[:size])
    check_sig.write_bytes(data[size + 4:size + 4 + signature.stat().st_size])
    run("openssl", "dgst", "-verify", public_key, "-sha256",
        "-sigopt", "rsa_padding_mode:pss", "-sigopt", "rsa_pss_saltlen:-1",
        "-signature", check_sig, check_header)
run(mkimage, "-l", image)
"""


def run(*args, **kwargs):
    return subprocess.run([str(arg) for arg in args], check=True, **kwargs)


def prop(path, node, key, kind="s"):
    return subprocess.check_output(
        ["fdtget", "-t", kind, str(path), node, key], text=True
    ).strip()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output-dir", type=Path, required=True,
                        help="Separate directory for newly packaged FITs")
    args = parser.parse_args()
    if not __debug__:
        raise RuntimeError("Run without -O: artifact assertions must remain enabled")
    raw = (DELIVERABLES / "uboot_emmc_ramopts.bin").read_bytes()
    old = DELIVERABLES / "brcm_simple.itb"
    assert hashlib.sha256(raw).hexdigest() == RAW_SHA256
    assert hashlib.sha256(old.read_bytes()).hexdigest() == V4_SHA256
    output = args.output_dir / (NAME + ".itb")
    padded_path = args.output_dir / (NAME + "_padded.itb")
    if output.exists() or padded_path.exists():
        raise RuntimeError("Refusing to overwrite previously packaged artifacts")
    mounted = subprocess.check_output([
        "podman", "inspect", CONTAINER, "--format",
        '{{range .Mounts}}{{if eq .Destination "/build/asuswrt-merlin"}}{{.Source}}{{end}}{{end}}',
    ], text=True).strip()
    if Path(mounted).resolve() != REPO_ROOT:
        raise RuntimeError("Container does not mount this repository")
    args.output_dir.mkdir(parents=True, exist_ok=True)
    run("podman", "exec", CONTAINER, "mkdir", "-p", REMOTE)
    run("podman", "cp", old, CONTAINER + ":" + REMOTE + "/v4.itb")
    run("podman", "exec", "-i", CONTAINER, "python3", "-",
        input=CONTAINER_BUILD, text=True)
    run("podman", "cp", CONTAINER + ":" + REMOTE + "/" + NAME + ".itb", output)
    blob = output.read_bytes()
    payloads = []
    for node in ("/images/uboot", "/images/fdt_uboot"):
        offset = int(prop(output, node, "data-position", "x"), 16)
        size = int(prop(output, node, "data-size", "x"), 16)
        assert offset + size <= len(blob)
        data = blob[offset:offset + size]
        expected_hash = bytes(int(v, 16) for v in prop(
            output, node + "/hash-1", "value", "bx").split())
        assert hashlib.sha256(data).digest() == expected_hash
        payloads.append(data)
    assert b"".join(payloads) == raw, "Packaged payload differs from RAM-tested binary"
    for node, key, kind in (
        ("/", "description", "s"),
        ("/images/uboot", "load", "x"),
        ("/images/uboot", "entry", "x"),
        ("/images/uboot", "os", "s"),
        ("/images/uboot", "arch", "s"),
        ("/images/uboot", "compression", "s"),
        ("/images/fdt_uboot", "type", "s"),
        ("/images/fdt_uboot", "compression", "s"),
        ("/configurations", "default", "s"),
        ("/configurations/conf_uboot", "fdt", "s"),
        ("/configurations/conf_uboot", "loadables", "s"),
    ):
        assert prop(output, node, key, kind) == prop(old, node, key, kind)
    padded = blob + b"\xff" * (-len(blob) % 512)
    assert len(padded) <= 0x200000, "FIT exceeds the available boot0 region"
    padded_path.write_bytes(padded)
    assert padded_path.read_bytes()[:len(blob)] == blob
    print("PASS: FIT hashes, signatures, loader metadata, and tested payload identity")
    for path in (output, padded_path):
        data = path.read_bytes()
        print(f"{path.name}: size={len(data)} ({len(data):#x}), "
              f"crc32={zlib.crc32(data):08x}, sha256={hashlib.sha256(data).hexdigest()}")
    print(f"boot0 start LBA=0x1000, block count={len(padded) // 512:#x}, "
          f"exclusive end LBA={0x1000 + len(padded) // 512:#x}")


if __name__ == "__main__":
    main()
