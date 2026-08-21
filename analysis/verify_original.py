#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import pathlib
import struct
import sys

EXPECTED_SHA256 = "bd86770c05e8a290d9b729f8922c3f3f8fde737e8463c79d4bf4dbc4d86ce017"
EXPECTED_MAGIC = b"\xcf\xfa\xed\xfe"  # MH_MAGIC_64, little-endian bytes
GATE_KEY = b"__sys_ui_shown"

# Static landmark recovered from the supplied build. __TEXT vmaddr/fileoff are both 0,
# so these virtual addresses are file offsets in this exact binary.
KEY_HELPER_CALLSITE = 0x2EB284
KEY_HELPER_TARGET = 0x31BA48

# `svc #0x80` encoding observed throughout the protected text section.
SVC_80 = b"\x01\x10\x00\xd4"


def decode_arm64_bl_target(blob: bytes, pc: int) -> int:
    insn = struct.unpack_from("<I", blob, pc)[0]
    if (insn >> 26) != 0b100101:
        raise AssertionError(f"0x{pc:x}: expected ARM64 BL, got 0x{insn:08x}")
    imm26 = insn & 0x03FFFFFF
    if imm26 & (1 << 25):
        imm26 -= 1 << 26
    return pc + (imm26 << 2)


def main() -> int:
    path = pathlib.Path(sys.argv[1] if len(sys.argv) > 1 else "original/PinterestPatch.dylib")
    if not path.exists():
        print(f"[SKIP] {path} is not present. Upload the supplied original dylib to run binary checks.")
        print(f"[INFO] expected SHA-256: {EXPECTED_SHA256}")
        return 0

    blob = path.read_bytes()
    digest = hashlib.sha256(blob).hexdigest()
    assert digest == EXPECTED_SHA256, f"SHA-256 mismatch: {digest}"
    assert blob[:4] == EXPECTED_MAGIC, f"unexpected Mach-O magic: {blob[:4].hex()}"

    # The key was reconstructed from protected code; it should not simply be a plaintext artifact.
    plaintext_count = blob.count(GATE_KEY)

    target = decode_arm64_bl_target(blob, KEY_HELPER_CALLSITE)
    assert target == KEY_HELPER_TARGET, (
        f"key-helper landmark changed: BL@0x{KEY_HELPER_CALLSITE:x} -> 0x{target:x}, "
        f"expected 0x{KEY_HELPER_TARGET:x}"
    )

    svc_count = blob.count(SVC_80)

    print(f"[OK] SHA-256: {digest}")
    print(f"[OK] Mach-O arm64/64-bit magic: {blob[:4].hex()}")
    print(f"[OK] key-helper BL: 0x{KEY_HELPER_CALLSITE:x} -> 0x{target:x}")
    print(f"[INFO] plaintext occurrences of {GATE_KEY!r}: {plaintext_count}")
    print(f"[INFO] raw svc #0x80 encodings: {svc_count}")
    print("[MODEL] observed preference key hypothesis: __sys_ui_shown")
    print("[MODEL] predicted predicate: gate = !boolForKey(\"__sys_ui_shown\")")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
